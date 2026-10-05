"""Find functions that write a given set of structure displacements.

Linear-sweeps every function of the unwind table inside an address window and
lists those containing a memory write (mov / movss / movaps ... with a memory
destination) to each requested `[reg + disp]`. Used to locate initializers of
runtime objects whose update code is already known.

  python find_field_writers.py 0x141270000 0x1413a0000 0x60 0x64 0x78 0x184
"""

from __future__ import annotations

import argparse

from disasm_batch import Image  # also puts the vendored capstone on sys.path

from capstone.x86 import X86_OP_MEM, X86_REG_RBP, X86_REG_RSP  # noqa: E402


def writers(image: Image, start: int, end: int, displacements: set[int]) -> list[tuple[int, dict[int, list[int]]]]:
    out = []
    for begin, finish, _ in image.funcs:
        va = image.base + begin
        if not (start <= va < end):
            continue
        offset = image.off(va)
        if offset is None:
            continue
        hits: dict[int, list[int]] = {}
        for ins in image.md.disasm(image.data[offset:offset + (finish - begin)], va):
            if not ins.operands or not ins.mnemonic.startswith(('mov', 'and', 'or', 'add', 'sub')):
                continue
            target = ins.operands[0]
            if target.type != X86_OP_MEM or target.mem.base in (X86_REG_RSP, X86_REG_RBP, 0):
                continue
            if target.mem.index == 0 and target.mem.disp in displacements:
                hits.setdefault(target.mem.disp, []).append(ins.address)
        if set(hits) == displacements:
            out.append((va, hits))
    return out


if __name__ == '__main__':
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('start', type=lambda s: int(s, 16))
    ap.add_argument('end', type=lambda s: int(s, 16))
    ap.add_argument('displacements', nargs='+', type=lambda s: int(s, 16))
    args = ap.parse_args()
    image = Image()
    for va, hits in writers(image, args.start, args.end, set(args.displacements)):
        print(f'{va:#x}', {hex(d): [hex(a) for a in addresses[:3]] for d, addresses in sorted(hits.items())})
