"""Find the table of string pointers of NSUNSC.exe that contains a given string.

  python find_pointer_table.py RandomRoll

Enumerations of the game's script loaders are arrays of `const char*`; the
index of a name in its array is the value the loader stores. Prints the array
around each pointer to the string, with indices relative to the first entry
that looks like the start of the table.
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
    ap.add_argument('text')
    ap.add_argument('--stride', type=int, default=8, help='bytes between two names of the table')
    args = ap.parse_args()
    pe = pefile.PE(str(EXE), fast_load=True)
    base = pe.OPTIONAL_HEADER.ImageBase
    sections = [(s, s.get_data()) for s in pe.sections]

    def string_at(va: int) -> str | None:
        for s, data in sections:
            start = base + s.VirtualAddress
            if start <= va < start + len(data):
                end = data.find(b'\0', va - start)
                raw = data[va - start:end]
                if 0 < len(raw) < 80 and all(32 <= b < 127 for b in raw):
                    return raw.decode('ascii')
        return None

    needle = args.text.encode('ascii') + b'\0'
    for s, data in sections:
        pos = data.find(needle)
        while pos >= 0:
            if pos == 0 or data[pos - 1] == 0:
                target = struct.pack('<Q', base + s.VirtualAddress + pos)
                for t, tdata in sections:
                    at = tdata.find(target)
                    while at >= 0:
                        first = at
                        while first >= args.stride and string_at(struct.unpack_from('<Q', tdata, first - args.stride)[0]):
                            first -= args.stride
                        print(f'table at {base + t.VirtualAddress + first:#x} (stride {args.stride}):')
                        cursor, index = first, 0
                        while cursor + 8 <= len(tdata):
                            name = string_at(struct.unpack_from('<Q', tdata, cursor)[0])
                            if name is None:
                                break
                            print(f'    {index:3d} ({index:#04x})  {name}')
                            cursor += args.stride
                            index += 1
                        at = tdata.find(target, at + 8)
            pos = data.find(needle, pos + 1)
