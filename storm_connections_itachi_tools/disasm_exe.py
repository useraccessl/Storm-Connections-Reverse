"""Display a selected NSUNSC.exe x64 code range for format analysis."""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent / "vendor"))
import pefile  # type: ignore
from capstone import Cs, CS_ARCH_X86, CS_MODE_64  # type: ignore


EXE = Path(r"C:\Program Files (x86)\Steam\steamapps\common\NARUTO X BORUTO Ultimate Ninja STORM CONNECTIONS\NSUNSC.exe")


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("address", type=lambda s: int(s, 0))
    ap.add_argument("--bytes", type=lambda s: int(s, 0), default=0x100)
    ap.add_argument("--function", action="store_true", help="Use the PE unwind function range containing the address")
    args = ap.parse_args()
    data = EXE.read_bytes()
    pe = pefile.PE(data=data, fast_load=True)
    rva = args.address - pe.OPTIONAL_HEADER.ImageBase
    if args.function:
        pe.parse_data_directories(directories=[pefile.DIRECTORY_ENTRY['IMAGE_DIRECTORY_ENTRY_EXCEPTION']])
        entry=next(e.struct for e in pe.DIRECTORY_ENTRY_EXCEPTION if e.struct.BeginAddress<=rva<e.struct.EndAddress)
        begin,end,unwind=entry.BeginAddress,entry.EndAddress,entry.UnwindData
        # Optimized functions can have chained unwind entries for interior
        # regions; follow them to the real function prologue.
        import struct
        for _ in range(16):
            info=pe.get_offset_from_rva(unwind)
            flags=data[info]>>3
            if not flags&4: break
            chain=info+((4+data[info+2]*2+3)&~3)
            parent_begin,parent_end,unwind=struct.unpack_from('<3I',data,chain)
            begin=min(begin,parent_begin)
            end=max(end,parent_end)
        else: raise ValueError('Unwind chain too long')
        # Include sibling regions chained to this same prologue, rather than
        # returning only its tiny prologue or the queried interior region.
        for candidate in pe.DIRECTORY_ENTRY_EXCEPTION:
            part=candidate.struct
            part_begin=part.BeginAddress
            part_unwind=part.UnwindData
            for _ in range(16):
                info=pe.get_offset_from_rva(part_unwind)
                if not (data[info]>>3)&4: break
                chain=info+((4+data[info+2]*2+3)&~3)
                parent_begin,parent_end,part_unwind=struct.unpack_from('<3I',data,chain)
                part_begin=min(part_begin,parent_begin)
            if part_begin==begin: end=max(end,part.EndAddress)
        rva=begin
        args.address=pe.OPTIONAL_HEADER.ImageBase+rva
        args.bytes=end-begin
    offset = pe.get_offset_from_rva(rva)
    md = Cs(CS_ARCH_X86, CS_MODE_64)
    md.detail = True
    for insn in md.disasm(data[offset:offset + args.bytes], args.address):
        print(f"{insn.address:016x}: {insn.mnemonic:8s} {insn.op_str}")
