"""Map NSUNSC.exe into this process and call its functions directly.

The verifiers of the first sessions copied one leaf routine at a time into
executable memory, which only works for position-independent code that calls
nothing. This maps the whole image at its preferred base instead, so any
routine that is pure computation can be called with its real callees, its
real constants and its real globals:

  * headers and sections are copied to their virtual addresses (the file is
    not packed; no relocation is applied, so the preferred base must be free);
  * imports of the C runtime and kernel32 are bound; every other import points
    at a trap that reports and exits;
  * nothing of the game is initialised: no entry point, no static constructor,
    no TLS callback. Globals hold what the file holds. A caller builds the few
    objects its routine reads (see `verify_skill_actor_native.py`);
  * function-local statics initialise themselves on first use: the three CRT
    helpers behind MSVC's thread-safe initialisation are replaced by
    single-threaded equivalents and the thread-local epoch they compare with
    is read from a private block instead of this process's TLS.

A routine that reaches the renderer, the allocator, the file system or a
vtable of an object nobody built will crash the Python process: call only
what the disassembly shows to be computation.
"""

from __future__ import annotations

import ctypes
import os
import struct
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent
sys.path.insert(0, str(ROOT / 'vendor'))

import pefile  # noqa: E402

EXE = Path(r'C:\Program Files (x86)\Steam\steamapps\common\NARUTO X BORUTO Ultimate Ninja STORM CONNECTIONS\NSUNSC.exe')

# MSVC thread-safe static initialisation (`_Init_thread_header`, `_Init_thread_footer`)
# and `atexit`, as called around every function-local static of the game.
INIT_THREAD_HEADER = 0x141441c00
INIT_THREAD_FOOTER = 0x141441ba0
ATEXIT = 0x1414419a8
TLS_INDEX = 0x149752c10          # _tls_index
EPOCH_OFFSET = 0x3428            # _Init_thread_epoch inside the module's TLS block
BOUND_LIBRARIES = ('api-ms-win-crt-', 'vcruntime140', 'msvcp140', 'kernel32', 'ucrtbase')

_kernel = ctypes.WinDLL('kernel32', use_last_error=True)
_kernel.VirtualAlloc.argtypes = [ctypes.c_void_p, ctypes.c_size_t, ctypes.c_ulong, ctypes.c_ulong]
_kernel.VirtualAlloc.restype = ctypes.c_void_p
_kernel.VirtualFree.argtypes = [ctypes.c_void_p, ctypes.c_size_t, ctypes.c_ulong]
_kernel.LoadLibraryW.argtypes = [ctypes.c_wchar_p]
_kernel.LoadLibraryW.restype = ctypes.c_void_p
_kernel.GetProcAddress.argtypes = [ctypes.c_void_p, ctypes.c_char_p]
_kernel.GetProcAddress.restype = ctypes.c_void_p


class NativeImage:
    def __init__(self, exe: Path = EXE):
        self.pe = pefile.PE(str(exe), fast_load=True)
        header = self.pe.OPTIONAL_HEADER
        self.base = header.ImageBase
        self.size = header.SizeOfImage
        address = _kernel.VirtualAlloc(self.base, self.size, 0x3000, 0x40)     # commit | reserve, execute-read-write
        if address != self.base:
            raise RuntimeError(f'the preferred base {self.base:#x} of the game image is not free in this process '
                               f'(error {ctypes.get_last_error()}); relocation is not implemented')
        raw = exe.read_bytes()
        ctypes.memmove(self.base, raw, header.SizeOfHeaders)
        for section in self.pe.sections:
            count = min(section.SizeOfRawData, section.Misc_VirtualSize)
            ctypes.memmove(self.base + section.VirtualAddress, raw[section.PointerToRawData:section.PointerToRawData + count], count)
        text = next(s for s in self.pe.sections if s.Name.rstrip(b'\0') == b'.text')
        self.text = (self.base + text.VirtualAddress, raw[text.PointerToRawData:text.PointerToRawData + text.SizeOfRawData])
        self._keep: list = []
        self._bind_imports()
        self._single_threaded_statics()

    # -- memory ---------------------------------------------------------------
    def read(self, address: int, count: int) -> bytes:
        return ctypes.string_at(address, count)

    def write(self, address: int, data: bytes) -> None:
        ctypes.memmove(address, data, len(data))

    def unpack(self, layout: str, address: int) -> tuple:
        return struct.unpack(layout, self.read(address, struct.calcsize(layout)))

    def pack(self, layout: str, address: int, *values) -> None:
        self.write(address, struct.pack(layout, *values))

    def block(self, size: int) -> int:
        """A zeroed read-write block outside the image, kept for the image's life."""
        buffer = ctypes.create_string_buffer(size)
        self._keep.append(buffer)
        return ctypes.addressof(buffer)

    def function(self, address: int, result, *arguments):
        """The game routine at `address` as a callable (Microsoft x64 convention)."""
        return ctypes.WINFUNCTYPE(result, *arguments)(address)

    # -- set-up ---------------------------------------------------------------
    def _bind_imports(self) -> None:
        self.pe.parse_data_directories(directories=[pefile.DIRECTORY_ENTRY['IMAGE_DIRECTORY_ENTRY_IMPORT']])

        def trap():
            print('native_image: the routine called an import that is not bound', flush=True)
            os._exit(86)

        self._trap = ctypes.WINFUNCTYPE(None)(trap)
        trap_address = ctypes.cast(self._trap, ctypes.c_void_p).value
        self.bound, self.unbound = 0, 0
        for entry in self.pe.DIRECTORY_ENTRY_IMPORT:
            library = entry.dll.decode('ascii')
            handle = _kernel.LoadLibraryW(library) if library.lower().startswith(BOUND_LIBRARIES) else None
            for symbol in entry.imports:
                target = _kernel.GetProcAddress(handle, symbol.name) if handle and symbol.name else None
                self.pack('<Q', symbol.address, target or trap_address)
                if target:
                    self.bound += 1
                else:
                    self.unbound += 1

    def _single_threaded_statics(self) -> None:
        # header: the guard becomes -1, the caller runs the initialiser;
        # footer: the guard becomes INT_MIN, never above the epoch again.
        self.write(INIT_THREAD_HEADER, bytes.fromhex('c701ffffffffc3'))
        self.write(INIT_THREAD_FOOTER, bytes.fromhex('c70100000080c3'))
        self.write(ATEXIT, bytes.fromhex('31c0c3'))
        # `mov rcx|rax, gs:[0x58]` (the thread's TLS array) -> the address of a
        # private array whose every entry is one private block.
        block = self.block(0x8000)
        self.pack('<i', block + EPOCH_OFFSET, -5)          # any guard still 0 is "not initialised yet"
        array = self.base + 0xF00                          # slack of the header page, within rel32 reach
        for slot in range(16):
            self.pack('<Q', array + 8 * slot, block)
        self.pack('<I', TLS_INDEX, 0)
        start, code = self.text
        self.tls_sites = 0
        for pattern, opcode in ((bytes.fromhex('65488b0c2558000000'), b'\x48\x8d\x0d'),
                                (bytes.fromhex('65488b042558000000'), b'\x48\x8d\x05')):
            at = code.find(pattern)
            while at >= 0:
                site = start + at
                self.write(site, opcode + struct.pack('<i', array - (site + 7)) + b'\x66\x90')
                self.tls_sites += 1
                at = code.find(pattern, at + 1)


if __name__ == '__main__':
    image = NativeImage()
    print(f'image mapped at {image.base:#x}, {image.size:#x} bytes; {image.bound} imports bound, '
          f'{image.unbound} trapped; {image.tls_sites} TLS reads redirected')
    # Smoke test: the reference update rate getter and the game's random generator.
    rate = image.function(0x1405911a0, ctypes.c_uint32)()
    seed = image.function(0x14132d580, None, ctypes.c_uint32)
    draw = image.function(0x14132d200, ctypes.c_uint32)
    seed(5489)
    first = draw()
    print(f'reference rate {rate}; MT19937 seeded 5489 first output {first} (reference 3499211612)')
    assert rate == 30 and first == 3499211612
    print('PASS')
