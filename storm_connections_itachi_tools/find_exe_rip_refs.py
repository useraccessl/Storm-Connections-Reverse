"""Find x64 instructions with RIP-relative operands to an executable VA."""
from __future__ import annotations

import argparse
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent / "vendor"))
import pefile  # type: ignore
from capstone import Cs, CS_ARCH_X86, CS_MODE_64, CS_OP_MEM  # type: ignore
from capstone.x86_const import X86_REG_RIP  # type: ignore
from disasm_exe import EXE


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("target", type=lambda value: int(value, 0))
    args = parser.parse_args()
    data = EXE.read_bytes()
    pe = pefile.PE(data=data, fast_load=True)
    base = pe.OPTIONAL_HEADER.ImageBase
    pe.parse_data_directories(
        directories=[pefile.DIRECTORY_ENTRY["IMAGE_DIRECTORY_ENTRY_EXCEPTION"]]
    )
    md = Cs(CS_ARCH_X86, CS_MODE_64)
    md.detail = True
    seen: set[int] = set()
    count = 0
    for entry in pe.DIRECTORY_ENTRY_EXCEPTION:
        begin = entry.struct.BeginAddress
        end = entry.struct.EndAddress
        offset = pe.get_offset_from_rva(begin)
        for insn in md.disasm(data[offset : offset + end - begin], base + begin):
            if insn.address in seen:
                continue
            seen.add(insn.address)
            for operand in insn.operands:
                if operand.type != CS_OP_MEM or operand.mem.base != X86_REG_RIP:
                    continue
                resolved = insn.address + insn.size + operand.mem.disp
                if resolved == args.target:
                    print(f"{insn.address:016x}: {insn.mnemonic:8s} {insn.op_str}")
                    count += 1
    print(f"matches={count}")


if __name__ == "__main__":
    main()
