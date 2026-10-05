"""Find the code that reads or writes one per-thread (TLS) slot of NSUNSC.exe.

The game reaches its per-thread render state as `TLS[index][slot]` with the
slot offset loaded as an immediate (`mov r32, imm32`), so a slot's users are the
instructions carrying that immediate in .text. Prints each hit with the
instructions that follow, marking stores.

  python scan_tls_slot.py 0x32d0
"""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent
sys.path.insert(0, str(ROOT / 'vendor'))

import capstone  # noqa: E402
import pefile  # noqa: E402

EXE = Path(r'C:\Program Files (x86)\Steam\steamapps\common\NARUTO X BORUTO Ultimate Ninja STORM CONNECTIONS\NSUNSC.exe')


if __name__ == '__main__':
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('slot', type=lambda s: int(s, 0))
    ap.add_argument('--after', type=int, default=6, help='instructions to show after the hit')
    args = ap.parse_args()
    pe = pefile.PE(str(EXE), fast_load=True)
    text = next(s for s in pe.sections if s.Name.rstrip(b'\0') == b'.text')
    base = pe.OPTIONAL_HEADER.ImageBase + text.VirtualAddress
    data = text.get_data()
    md = capstone.Cs(capstone.CS_ARCH_X86, capstone.CS_MODE_64)
    needle = args.slot.to_bytes(4, 'little')
    pos, hits = 0, 0
    while True:
        pos = data.find(needle, pos)
        if pos < 0:
            break
        # mov r32, imm32 is B8+r (1 byte before) or 41 B8+r (2 bytes before).
        for back in (1, 2):
            start = pos - back
            first = next(md.disasm(data[start:start + 16], base + start), None)
            if first and first.mnemonic == 'mov' and first.size == back + 4 and '[' not in first.op_str \
                    and first.op_str.endswith(f', {args.slot:#x}'):
                hits += 1
                lines, writes = [], False
                for ins in md.disasm(data[start:start + 80], base + start):
                    lines.append(f'  {ins.address:#x}: {ins.mnemonic} {ins.op_str}')
                    if ins.mnemonic.startswith('mov') and ins.op_str.split(',')[0].strip().endswith(']') and len(lines) > 1:
                        writes = True
                    if len(lines) > args.after:
                        break
                print(('WRITE ' if writes else 'read  ') + f'{base + start:#x}')
                print('\n'.join(lines))
                break
        pos += 1
    print(f'{hits} uses of TLS slot {args.slot:#x}')
