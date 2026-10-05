"""Print the upward caller tree of NSUNSC.exe functions, naming vtable owners via RTTI.

Follows rel32 call/jmp sites to their unwind function and reports absolute
pointers to the function (vtable slots) with the owning RTTI class when found.
"""

from __future__ import annotations

import argparse

from disasm_batch import Image
from xrefs import rtti_name, scan


def vtable_owner(img: Image, slot_va: int) -> str | None:
    for back in range(0, 0x400, 8):
        name = rtti_name(img, slot_va - back)
        if name:
            return f'{name} slot {back:#x}'
    return None


def walk(img: Image, target: int, depth: int, max_depth: int, fanout: int, seen: set[int]) -> None:
    if target in seen:
        print('  ' * depth + f'{target:#x} (seen)')
        return
    seen.add(target)
    r = scan(img, [target])[target]
    fns = sorted({f for _, f in r['call'] + r['jmp'] if f != '?'})
    owners = [o for o in (vtable_owner(img, p) for p in r['ptr'][:4]) if o]
    more = f' (+{len(fns) - fanout} more)' if len(fns) > fanout else ''
    line = f'{target:#x} <- {len(fns)} fn{more}'
    if r['ptr']:
        line += ' ptr@' + ','.join(f'{p:#x}' for p in r['ptr'][:4])
    if owners:
        line += ' ' + ' | '.join(owners)
    print('  ' * depth + line)
    if depth >= max_depth:
        return
    for f in fns[:fanout]:
        walk(img, int(f, 16), depth + 1, max_depth, fanout, seen)


if __name__ == '__main__':
    ap = argparse.ArgumentParser()
    ap.add_argument('targets', nargs='+', type=lambda s: int(s, 0))
    ap.add_argument('--depth', type=int, default=4)
    ap.add_argument('--fanout', type=int, default=4)
    args = ap.parse_args()
    image = Image()
    for t in args.targets:
        walk(image, t, 0, args.depth, args.fanout, set())
