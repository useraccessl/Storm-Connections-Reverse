"""Find the vtable(s) of a C++ class of NSUNSC.exe from its RTTI name.

  python rtti_vtable.py ccSkillActorArrow [--slots 12]

MSVC x64 layout: the type descriptor holds the mangled name (`.?AVname@@`) at
+0x10; a complete object locator references it by RVA at +0x0C; the vtable's
slot -1 points at the locator. Prints each vtable with its first slots.
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


def vtables(pe: pefile.PE, name: str) -> list[tuple[int, int]]:
    """[(vtable address, offset of the subobject in the class)] for class `name`."""
    base = pe.OPTIONAL_HEADER.ImageBase
    needle = f'.?AV{name}@@\0'.encode('ascii')
    descriptor = None
    sections = [(s, s.get_data()) for s in pe.sections]
    for section, data in sections:
        pos = data.find(needle)
        if pos >= 0:
            descriptor = section.VirtualAddress + pos - 0x10
            break
    if descriptor is None:
        raise SystemExit(f'no RTTI type descriptor for {name}')
    out = []
    for section, data in sections:
        if section.Name.rstrip(b'\0') != b'.rdata':
            continue
        pos = 0
        target = struct.pack('<I', descriptor)
        while True:
            pos = data.find(target, pos)
            if pos < 0:
                break
            locator = section.VirtualAddress + pos - 0x0c           # signature, offset, cdOffset, pTypeDescriptor
            signature, offset = struct.unpack_from('<II', data, pos - 0x0c) if pos >= 0x0c else (None, None)
            if signature == 1:
                pointer = struct.pack('<Q', base + locator)
                at = 0
                while True:
                    at = data.find(pointer, at)
                    if at < 0:
                        break
                    out.append((base + section.VirtualAddress + at + 8, offset))
                    at += 8
            pos += 4
    return out


if __name__ == '__main__':
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('names', nargs='+')
    ap.add_argument('--slots', type=int, default=12)
    args = ap.parse_args()
    pe = pefile.PE(str(EXE), fast_load=True)
    base = pe.OPTIONAL_HEADER.ImageBase
    for name in args.names:
        for address, offset in vtables(pe, name):
            raw = pe.get_data(address - base, 8 * args.slots)
            slots = [struct.unpack_from('<Q', raw, 8 * n)[0] for n in range(args.slots)]
            print(f'{name}: vtable {address:#x} (subobject +{offset:#x})')
            print('    ' + ' '.join(f'+{8 * n:02x}:{value:#x}' for n, value in enumerate(slots)))
