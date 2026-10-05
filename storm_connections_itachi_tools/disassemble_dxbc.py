"""Disassemble a game DXBC shader with the installed D3D compiler DLL."""

from __future__ import annotations

import argparse
import ctypes
from pathlib import Path


def disassemble(bytecode: bytes, compiler_path: Path) -> str:
    dll = ctypes.WinDLL(str(compiler_path))
    fn = dll.D3DDisassemble
    fn.argtypes = (ctypes.c_void_p, ctypes.c_size_t, ctypes.c_uint,
                   ctypes.c_char_p, ctypes.POINTER(ctypes.c_void_p))
    fn.restype = ctypes.c_long
    src = ctypes.create_string_buffer(bytecode)
    blob = ctypes.c_void_p()
    hr = fn(src, len(bytecode), 0, None, ctypes.byref(blob))
    if hr < 0 or not blob.value:
        raise OSError(f"D3DDisassemble failed: 0x{hr & 0xffffffff:08x}")
    try:
        vtable = ctypes.cast(blob, ctypes.POINTER(ctypes.POINTER(ctypes.c_void_p))).contents
        get_pointer = ctypes.WINFUNCTYPE(ctypes.c_void_p, ctypes.c_void_p)(vtable[3])
        get_size = ctypes.WINFUNCTYPE(ctypes.c_size_t, ctypes.c_void_p)(vtable[4])
        return ctypes.string_at(get_pointer(blob), get_size(blob)).decode("utf-8", "replace")
    finally:
        release = ctypes.WINFUNCTYPE(ctypes.c_ulong, ctypes.c_void_p)(vtable[2])
        release(blob)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("dxbc", type=Path)
    parser.add_argument("--compiler", type=Path, required=True)
    parser.add_argument("--output", type=Path)
    args = parser.parse_args()
    result = disassemble(args.dxbc.read_bytes(), args.compiler)
    if args.output:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(result, encoding="utf-8")
    else:
        print(result)
