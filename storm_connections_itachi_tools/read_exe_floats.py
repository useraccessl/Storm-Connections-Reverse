"""Print float32 values stored in NSUNSC.exe at the given virtual addresses.

  python read_exe_floats.py 0x141b93918 4      # four consecutive floats
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
    ap.add_argument('pairs', nargs='+', help='address [count] ...')
    args = ap.parse_args()
    pe = pefile.PE(str(EXE), fast_load=True)
    base = pe.OPTIONAL_HEADER.ImageBase
    items = args.pairs
    i = 0
    while i < len(items):
        address = int(items[i], 0)
        count = 1
        if i + 1 < len(items) and not items[i + 1].lower().startswith('0x'):
            count = int(items[i + 1])
            i += 1
        i += 1
        raw = pe.get_data(address - base, 4 * count)
        print(f'{address:#x}:', [struct.unpack_from('<f', raw, 4 * n)[0] for n in range(count)])
