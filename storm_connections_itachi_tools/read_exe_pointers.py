"""Print 64-bit pointers stored in NSUNSC.exe (a vtable, a function table).

  python read_exe_pointers.py 0x141b9baf8 8      # eight consecutive slots
"""

from __future__ import annotations

import argparse
import struct
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent
sys.path.insert(0, str(ROOT / 'vendor'))

import pefile  # noqa: E402

EXE = Path(r'C:\Program Files (x86)\Steam\steamapps\common\NARUTO X BORUTO Ultimate Ninja STORM CONNECTIONS\NSUNSC.exe')

if __name__ == '__main__':
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('address', type=lambda s: int(s, 0))
    ap.add_argument('count', type=int, nargs='?', default=8)
    args = ap.parse_args()
    pe = pefile.PE(str(EXE), fast_load=True)
    raw = pe.get_data(args.address - pe.OPTIONAL_HEADER.ImageBase, 8 * args.count)
    for n in range(args.count):
        print(f'{args.address + 8 * n:#x} [+{8 * n:#04x}]: {struct.unpack_from("<Q", raw, 8 * n)[0]:#x}')
