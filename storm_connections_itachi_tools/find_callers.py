"""List the call / jmp rel32 sites that target a function of NSUNSC.exe.

  python find_callers.py 0x141246600 [--context 8]

Scans .text for E8 / E9 displacements landing on the target and prints, for
each site, the containing function (unwind table) and the instructions before
the call (argument setup).
"""

from __future__ import annotations

import argparse
import bisect
import struct
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent
sys.path.insert(0, str(ROOT / 'vendor'))

import capstone  # noqa: E402
import pefile  # noqa: E402

EXE = Path(r'C:\Program Files (x86)\Steam\steamapps\common\NARUTO X BORUTO Ultimate Ninja STORM CONNECTIONS\NSUNSC.exe')


def load():
    pe = pefile.PE(str(EXE), fast_load=True)
    pe.parse_data_directories(directories=[pefile.DIRECTORY_ENTRY['IMAGE_DIRECTORY_ENTRY_EXCEPTION']])
    base = pe.OPTIONAL_HEADER.ImageBase
    text = next(s for s in pe.sections if s.Name.rstrip(b'\0') == b'.text')
    starts = sorted(base + e.struct.BeginAddress for e in pe.DIRECTORY_ENTRY_EXCEPTION)
    return base + text.VirtualAddress, text.get_data(), starts


def callers(target: int, text_base: int, data: bytes) -> list[tuple[int, str]]:
    out = []
    for opcode, kind in ((0xE8, 'call'), (0xE9, 'jmp')):
        pos = 0
        while True:
            pos = data.find(bytes([opcode]), pos)
            if pos < 0 or pos + 5 > len(data):
                break
            rel = struct.unpack_from('<i', data, pos + 1)[0]
            if text_base + pos + 5 + rel == target:
                out.append((text_base + pos, kind))
            pos += 1
    return sorted(out)


if __name__ == '__main__':
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('target', type=lambda s: int(s, 0))
    ap.add_argument('--context', type=int, default=6)
    args = ap.parse_args()
    text_base, data, starts = load()
    md = capstone.Cs(capstone.CS_ARCH_X86, capstone.CS_MODE_64)
    sites = callers(args.target, text_base, data)
    for site, kind in sites:
        index = bisect.bisect_right(starts, site) - 1
        function = starts[index] if index >= 0 else 0
        print(f'{kind} at {site:#x} in function {function:#x}')
        # Decode from the function start so the context lines are real instructions.
        begin = max(function, site - 0x400) if function else site - 64
        lines = [f'    {i.address:#x}: {i.mnemonic} {i.op_str}'
                 for i in md.disasm(data[begin - text_base:site - text_base + 5], begin)]
        print('\n'.join(lines[-args.context - 1:]))
    print(f'{len(sites)} sites')
