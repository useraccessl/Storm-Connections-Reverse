"""List the instructions of a code range of NSUNSC.exe that write a structure field.

  python find_field_writes.py 0x1405e0000 0x1405f0000 0x100 [--reads]

Prints every instruction between the two addresses whose destination (or, with
--reads, any operand) is memory at `register + offset`, with the function that
holds it. The range is disassembled linearly from each function start found in
the exception directory, so data between functions is never decoded as code.
"""

from __future__ import annotations

import argparse
import struct
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent
sys.path.insert(0, str(ROOT / 'vendor'))

import pefile  # noqa: E402
from capstone import CS_ARCH_X86, CS_MODE_64, CS_OP_MEM, Cs  # noqa: E402

EXE = Path(r'C:\Program Files (x86)\Steam\steamapps\common\NARUTO X BORUTO Ultimate Ninja STORM CONNECTIONS\NSUNSC.exe')

if __name__ == '__main__':
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('start')
    ap.add_argument('end')
    ap.add_argument('offset')
    ap.add_argument('--reads', action='store_true', help='also list instructions that only read the field')
    args = ap.parse_args()
    start, end, offset = int(args.start, 0), int(args.end, 0), int(args.offset, 0)
    pe = pefile.PE(str(EXE), fast_load=True)
    base = pe.OPTIONAL_HEADER.ImageBase
    directory = pe.OPTIONAL_HEADER.DATA_DIRECTORY[3]
    table = pe.get_data(directory.VirtualAddress, directory.Size)
    md = Cs(CS_ARCH_X86, CS_MODE_64)
    md.detail = True
    for at in range(0, len(table) - 11, 12):
        begin, finish, _ = struct.unpack_from('<III', table, at)
        if base + finish <= start or base + begin >= end:
            continue
        for ins in md.disasm(pe.get_data(begin, finish - begin), base + begin):
            for position, operand in enumerate(ins.operands):
                if operand.type == CS_OP_MEM and operand.mem.disp == offset and operand.mem.base and not operand.mem.index:
                    if ins.reg_name(operand.mem.base) in ('rsp', 'rbp', 'rip'):
                        continue
                    written = position == 0 and not ins.mnemonic.startswith(('cmp', 'test', 'comis', 'ucomis', 'push'))
                    if written or args.reads:
                        print(f'{ins.address:#x} (function {base + begin:#x}): {ins.mnemonic} {ins.op_str}')
