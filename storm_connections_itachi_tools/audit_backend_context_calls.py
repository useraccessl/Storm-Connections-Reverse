"""List selected indirect-call byte offsets made by backend vtable methods.

This static audit helper reports candidate context operations in NSUNSC.exe.
An offset match alone does not identify the base object's interface.
"""
from __future__ import annotations

import struct
import sys
import argparse
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent / "vendor"))
import pefile  # type: ignore
from capstone import Cs, CS_ARCH_X86, CS_MODE_64, CS_OP_MEM  # type: ignore

EXE = Path(
    r"C:\Program Files (x86)\Steam\steamapps\common\NARUTO X BORUTO Ultimate Ninja STORM CONNECTIONS\NSUNSC.exe"
)
BACKEND_VTABLE = 0x141BAE0C0
BACKEND_METHOD_COUNT = 55
INTERESTING_CONTEXT_SLOTS = {
    0x38, 0x40, 0x48, 0x50, 0x58, 0x60, 0x68, 0x70, 0x78, 0x80,
    0x88, 0x90, 0x98, 0x108, 0x110, 0x118, 0x120,
    0x128, 0x130, 0x138, 0x140, 0x148, 0x150, 0x158,
    0x160, 0x168, 0x170, 0x178, 0x180, 0x188, 0x190,
    0x198, 0x1A0, 0x1A8, 0x1B0, 0x1B8, 0x1C0, 0x1C8,
    0x1D0, 0x1D8, 0x1E0, 0x1E8, 0x1F0, 0x1F8, 0x200,
    0x208, 0x210, 0x218, 0x220, 0x228, 0x230,
}


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--all-code",
        action="store_true",
        help="scan every unwind-described function instead of only backend vtable methods",
    )
    args = parser.parse_args()
    data = EXE.read_bytes()
    pe = pefile.PE(data=data, fast_load=True)
    base = pe.OPTIONAL_HEADER.ImageBase
    pe.parse_data_directories(
        directories=[pefile.DIRECTORY_ENTRY["IMAGE_DIRECTORY_ENTRY_EXCEPTION"]]
    )
    ranges = [
        (entry.struct.BeginAddress, entry.struct.EndAddress)
        for entry in pe.DIRECTORY_ENTRY_EXCEPTION
    ]
    table_offset = pe.get_offset_from_rva(BACKEND_VTABLE - base)
    md = Cs(CS_ARCH_X86, CS_MODE_64)
    md.detail = True
    seen: set[tuple[int, int]] = set()

    if args.all_code:
        methods = [
            (-1, base + begin, (begin, end)) for begin, end in ranges
        ]
    else:
        methods = []
        for index in range(BACKEND_METHOD_COUNT):
            method_va = struct.unpack_from("<Q", data, table_offset + index * 8)[0]
            method_rva = method_va - base
            region = next(
                (item for item in ranges if item[0] <= method_rva < item[1]), None
            )
            if region is not None:
                methods.append((index, method_va, region))

    for index, method_va, region in methods:
        key = (index, method_va)
        if key in seen:
            continue
        seen.add(key)
        begin, end = region
        offset = pe.get_offset_from_rva(begin)
        code = data[offset : offset + end - begin]
        for instruction in md.disasm(code, base + begin):
            if instruction.mnemonic not in {"call", "jmp"}:
                continue
            for operand in instruction.operands:
                if operand.type != CS_OP_MEM:
                    continue
                slot = operand.mem.disp
                if slot in INTERESTING_CONTEXT_SLOTS:
                    prefix = (
                        f"backend[{index:02d}] slot=0x{index * 8:03x} "
                        if index >= 0
                        else "all-code "
                    )
                    print(
                        prefix
                        + f"method=0x{method_va:x} call=0x{instruction.address:x} "
                        f"target_vtable_byte_offset=0x{slot:x} "
                        f"instruction={instruction.mnemonic} {instruction.op_str}"
                    )


if __name__ == "__main__":
    main()
