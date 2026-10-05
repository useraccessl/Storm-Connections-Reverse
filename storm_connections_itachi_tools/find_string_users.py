"""Find the code that references a string of NSUNSC.exe (RIP-relative lea / mov).

  python find_string_users.py nuccChunkCoord.cpp

The game's allocator calls carry the source file path (`D:\\next5\\...\\x.cpp`),
so the users of such a string are the functions of that source file. Prints
the start of each matching string and, for each reference, the containing
function from the unwind table.
"""

from __future__ import annotations

import argparse
import bisect
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
    args = ap.parse_args()
    pe = pefile.PE(str(EXE), fast_load=True)
    pe.parse_data_directories(directories=[pefile.DIRECTORY_ENTRY['IMAGE_DIRECTORY_ENTRY_EXCEPTION']])
    base = pe.OPTIONAL_HEADER.ImageBase
    starts = sorted(base + e.struct.BeginAddress for e in pe.DIRECTORY_ENTRY_EXCEPTION)
    text = next(s for s in pe.sections if s.Name.rstrip(b'\0') == b'.text')
    code, code_base = text.get_data(), base + text.VirtualAddress
    needle = args.text.encode('ascii')
    targets = {}
    for section in pe.sections:
        data = section.get_data()
        pos = 0
        while True:
            pos = data.find(needle, pos)
            if pos < 0:
                break
            begin = data.rfind(b'\0', 0, pos) + 1
            end = data.find(b'\0', pos)
            targets[base + section.VirtualAddress + begin] = data[begin:end].decode('ascii', 'replace')
            pos = end
    for address, value in sorted(targets.items()):
        print(f'{address:#x}: {value!r}')
        # Any 4-byte displacement d at code offset p with p + 4 + d == target.
        hits = []
        for p in range(len(code) - 4):
            if code_base + p + 4 + struct.unpack_from('<i', code, p)[0] == address:
                site = code_base + p
                index = bisect.bisect_right(starts, site) - 1
                hits.append((starts[index] if index >= 0 else 0, site))
        for function, site in hits:
            print(f'    used at {site:#x} in function {function:#x}')
