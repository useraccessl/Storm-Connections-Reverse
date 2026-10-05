"""Locate x64 RIP-relative references to NUCC particle strings in NSUNSC.exe."""

from __future__ import annotations

import argparse
import struct
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent / "vendor"))
import pefile  # type: ignore
from capstone import Cs, CS_ARCH_X86, CS_MODE_64  # type: ignore


EXE = Path(r"C:\Program Files (x86)\Steam\steamapps\common\NARUTO X BORUTO Ultimate Ninja STORM CONNECTIONS\NSUNSC.exe")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("needle")
    args = ap.parse_args()
    data = EXE.read_bytes()
    pe = pefile.PE(data=data, fast_load=True)
    base = pe.OPTIONAL_HEADER.ImageBase
    matches = []
    pos = 0
    needle = args.needle.encode("ascii")
    while True:
        pos = data.find(needle, pos)
        if pos < 0:
            break
        matches.append((pos, base + pe.get_rva_from_offset(pos)))
        pos += len(needle)
    print("string matches", [(hex(off), hex(va)) for off, va in matches])
    md = Cs(CS_ARCH_X86, CS_MODE_64)
    for section in pe.sections:
        if not (section.Characteristics & 0x20000000):
            continue
        blob = section.get_data()
        section_va = base + section.VirtualAddress
        for string_offset, target in matches:
            hits = []
            for rel in range(len(blob) - 4):
                displacement = struct.unpack_from("<i", blob, rel)[0]
                if section_va + rel + 4 + displacement == target:
                    hits.append(rel)
            print("text candidates", hex(string_offset), len(hits))
            for rel in hits[:20]:
                begin = max(0, rel - 20)
                end = min(len(blob), rel + 40)
                print("  candidate", hex(section_va + rel))
                for insn in md.disasm(blob[begin:end], section_va + begin):
                    print(f"    {insn.address:016x}: {insn.mnemonic} {insn.op_str}")


if __name__ == "__main__":
    main()
