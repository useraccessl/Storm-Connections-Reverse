"""Find x64 instructions that access selected structure offsets in NSUNSC.exe."""
from __future__ import annotations

import argparse
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent / "vendor"))
import pefile  # type: ignore
from capstone import Cs, CS_ARCH_X86, CS_MODE_64, CS_OP_MEM  # type: ignore
from disasm_exe import EXE


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("offsets", nargs="+", type=lambda value: int(value, 0))
    parser.add_argument("--writes-only", action="store_true")
    args = parser.parse_args()

    data = EXE.read_bytes()
    pe = pefile.PE(data=data, fast_load=True)
    base = pe.OPTIONAL_HEADER.ImageBase
    md = Cs(CS_ARCH_X86, CS_MODE_64)
    md.detail = True
    found = 0
    pe.parse_data_directories(
        directories=[pefile.DIRECTORY_ENTRY["IMAGE_DIRECTORY_ENTRY_EXCEPTION"]]
    )
    seen: set[int] = set()
    for entry in pe.DIRECTORY_ENTRY_EXCEPTION:
        begin = entry.struct.BeginAddress
        end = entry.struct.EndAddress
        offset = pe.get_offset_from_rva(begin)
        for insn in md.disasm(data[offset : offset + end - begin], base + begin):
            if insn.address in seen:
                continue
            seen.add(insn.address)
            if args.writes_only and insn.mnemonic not in {
                "mov", "movaps", "movups", "movdqa", "movdqu", "and", "or",
                "xor", "bts", "btr", "btc", "stosb", "stosd", "stosq",
            }:
                continue
            for op_index, operand in enumerate(insn.operands):
                if operand.type != CS_OP_MEM or operand.mem.disp not in args.offsets:
                    continue
                if args.writes_only and op_index != 0:
                    continue
                print(f"{insn.address:016x}: {insn.mnemonic:8s} {insn.op_str}")
                found += 1
                break
    print(f"matches={found}")


if __name__ == "__main__":
    main()
