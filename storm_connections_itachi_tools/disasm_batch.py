"""Disassemble several NSUNSC.exe functions in one pass, with annotations.

Loads the executable once, resolves each address to its unwind function range,
and annotates RIP-relative operands with their absolute VA, import name, ASCII
string or pointed-to qword. Writes one .asm per function when --out is given.
"""

from __future__ import annotations

import argparse
import struct
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent / "vendor"))
import pefile  # type: ignore
from capstone import Cs, CS_ARCH_X86, CS_MODE_64  # type: ignore
from capstone.x86 import X86_OP_MEM, X86_OP_IMM, X86_REG_RIP  # type: ignore

EXE = Path(r"C:\Program Files (x86)\Steam\steamapps\common\NARUTO X BORUTO Ultimate Ninja STORM CONNECTIONS\NSUNSC.exe")


class Image:
    def __init__(self, path: Path = EXE):
        self.data = path.read_bytes()
        self.pe = pefile.PE(data=self.data, fast_load=True)
        self.base = self.pe.OPTIONAL_HEADER.ImageBase
        self.pe.parse_data_directories(directories=[
            pefile.DIRECTORY_ENTRY['IMAGE_DIRECTORY_ENTRY_EXCEPTION'],
            pefile.DIRECTORY_ENTRY['IMAGE_DIRECTORY_ENTRY_IMPORT'],
        ])
        self.imports: dict[int, str] = {}
        for entry in getattr(self.pe, 'DIRECTORY_ENTRY_IMPORT', []):
            dll = entry.dll.decode(errors='replace')
            for imp in entry.imports:
                name = imp.name.decode(errors='replace') if imp.name else f'ord{imp.ordinal}'
                self.imports[imp.address] = f'{dll}!{name}'
        self.funcs = sorted((e.struct.BeginAddress, e.struct.EndAddress, e.struct.UnwindData)
                            for e in self.pe.DIRECTORY_ENTRY_EXCEPTION)
        self.md = Cs(CS_ARCH_X86, CS_MODE_64)
        self.md.detail = True
        self.sections = [(s.VirtualAddress, s.VirtualAddress + max(s.Misc_VirtualSize, s.SizeOfRawData),
                          s.PointerToRawData, s.SizeOfRawData, s.Characteristics) for s in self.pe.sections]

    def off(self, va: int) -> int | None:
        rva = va - self.base
        for start, end, raw, rawsize, _ in self.sections:
            if start <= rva < end:
                delta = rva - start
                return raw + delta if delta < rawsize else None
        return None

    def is_code(self, va: int) -> bool:
        rva = va - self.base
        return any(start <= rva < end and ch & 0x20000000 for start, end, _, _, ch in self.sections)

    def read(self, va: int, size: int) -> bytes | None:
        o = self.off(va)
        return None if o is None else self.data[o:o + size]

    def qword(self, va: int) -> int | None:
        b = self.read(va, 8)
        return struct.unpack('<Q', b)[0] if b and len(b) == 8 else None

    def cstring(self, va: int, limit: int = 96) -> str | None:
        b = self.read(va, limit)
        if not b:
            return None
        end = b.find(b'\0')
        if end < 4:
            return None
        s = b[:end]
        if all(0x20 <= c < 0x7f for c in s):
            return s.decode()
        return None

    def _root(self, unwind: int, begin: int) -> tuple[int, int]:
        for _ in range(16):
            info = self.pe.get_offset_from_rva(unwind)
            if not (self.data[info] >> 3) & 4:
                break
            chain = info + ((4 + self.data[info + 2] * 2 + 3) & ~3)
            pbegin, _pend, unwind = struct.unpack_from('<3I', self.data, chain)
            begin = min(begin, pbegin)
        return begin, unwind

    def function_range(self, va: int) -> tuple[int, int]:
        rva = va - self.base
        hit = next(((b, e, u) for b, e, u in self.funcs if b <= rva < e), None)
        if hit is None:
            raise ValueError(f'{va:#x} not in an unwind range')
        begin, _ = self._root(hit[2], hit[0])
        end = hit[1]
        for b, e, u in self.funcs:
            if self._root(u, b)[0] == begin:
                end = max(end, e)
        return self.base + begin, self.base + end

    def thunk_target(self, va: int) -> str | None:
        b = self.read(va, 6)
        if b and b[:2] == b'\xff\x25':
            slot = va + 6 + struct.unpack_from('<i', b, 2)[0]
            return self.imports.get(slot)
        return None

    def annotate(self, insn) -> str:
        notes = []
        for op in insn.operands:
            if op.type == X86_OP_MEM and op.mem.base == X86_REG_RIP:
                target = insn.address + insn.size + op.mem.disp
                note = f'{target:#x}'
                if target in self.imports:
                    note += f' {self.imports[target]}'
                else:
                    s = self.cstring(target)
                    if s is not None and insn.mnemonic == 'lea':
                        note += f' "{s}"'
                    elif insn.mnemonic != 'lea':
                        q = self.qword(target)
                        if q is not None and self.base <= q < self.base + 0x10000000:
                            note += f' -> {q:#x}'
                notes.append(note)
            elif op.type == X86_OP_IMM and insn.mnemonic in ('call', 'jmp'):
                t = self.thunk_target(op.imm)
                if t:
                    notes.append(t)
        return ('  ; ' + ' | '.join(notes)) if notes else ''

    def disasm(self, va: int, size: int) -> list[str]:
        o = self.off(va)
        out = []
        for insn in self.md.disasm(self.data[o:o + size], va):
            out.append(f'{insn.address:016x}: {insn.mnemonic:8s} {insn.op_str}{self.annotate(insn)}')
        return out

    def leaf(self, va: int, limit: int = 0x400) -> list[str]:
        """Frameless function without an unwind entry: read up to the int3 padding."""
        out = []
        for line in self.disasm(va, limit):
            if line.split(': ', 1)[1].startswith('int3'):
                break
            out.append(line)
        return out

    def function(self, va: int) -> tuple[int, list[str]]:
        try:
            begin, end = self.function_range(va)
        except ValueError:
            return va, self.leaf(va)
        return begin, self.disasm(begin, end - begin)


if __name__ == '__main__':
    ap = argparse.ArgumentParser()
    ap.add_argument('addresses', nargs='+', type=lambda s: int(s, 0))
    ap.add_argument('--out', type=Path, help='Directory receiving one fn_<va>.asm per function')
    ap.add_argument('--bytes', type=lambda s: int(s, 0), help='Raw byte count instead of unwind range')
    args = ap.parse_args()
    img = Image()
    if args.out:
        args.out.mkdir(parents=True, exist_ok=True)
    for va in args.addresses:
        if args.bytes:
            begin, lines = va, img.disasm(va, args.bytes)
        else:
            begin, lines = img.function(va)
        text = '\n'.join(lines)
        if args.out:
            path = args.out / f'fn_{begin:x}.asm'
            path.write_text(text + '\n', encoding='utf-8')
            print(f'{va:#x} -> {path.name} ({len(lines)} insns)')
        else:
            print(f'; ===== function {begin:#x} (query {va:#x}) =====')
            print(text)
            print()
