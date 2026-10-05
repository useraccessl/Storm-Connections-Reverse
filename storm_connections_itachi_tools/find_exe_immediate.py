"""Find the instructions of NSUNSC.exe that carry a 32-bit immediate.

  python find_exe_immediate.py 0x3350544e          # 'NTP3' read as a little-endian dword

Prints each site with the containing function (unwind table) and the
instruction, for immediates used in comparisons or moves.
"""

from __future__ import annotations

import argparse
import bisect
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent
sys.path.insert(0, str(ROOT / 'vendor'))

import capstone  # noqa: E402
import pefile  # noqa: E402

EXE = Path(r'C:\Program Files (x86)\Steam\steamapps\common\NARUTO X BORUTO Ultimate Ninja STORM CONNECTIONS\NSUNSC.exe')

if __name__ == '__main__':
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('value', type=lambda s: int(s, 0))
    args = ap.parse_args()
    pe = pefile.PE(str(EXE), fast_load=True)
    pe.parse_data_directories(directories=[pefile.DIRECTORY_ENTRY['IMAGE_DIRECTORY_ENTRY_EXCEPTION']])
    base = pe.OPTIONAL_HEADER.ImageBase
    starts = sorted(base + e.struct.BeginAddress for e in pe.DIRECTORY_ENTRY_EXCEPTION)
    text = next(s for s in pe.sections if s.Name.rstrip(b'\0') == b'.text')
    code, code_base = text.get_data(), base + text.VirtualAddress
    md = capstone.Cs(capstone.CS_ARCH_X86, capstone.CS_MODE_64)
    needle = (args.value & 0xffffffff).to_bytes(4, 'little')
    pos = 0
    while True:
        pos = code.find(needle, pos)
        if pos < 0:
            break
        # The immediate is the tail of its instruction: try the plausible instruction starts.
        for back in range(1, 8):
            start = pos - back
            ins = next(md.disasm(code[start:start + 16], code_base + start), None)
            if ins and ins.size == back + 4 and f'{args.value:#x}' in ins.op_str:
                index = bisect.bisect_right(starts, ins.address) - 1
                print(f'{ins.address:#x} in function {starts[index]:#x}: {ins.mnemonic} {ins.op_str}')
                break
        pos += 1
