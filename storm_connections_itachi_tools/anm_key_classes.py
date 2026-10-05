"""Map nuccAnm curve formats to the key classes NSUNSC.exe instantiates.

The key factory 0x141367040 switches on the curve format (5..29) and builds
one key object per curve. This prints, per format: the case address, the
source line of its allocation, the object size, the vtable(s) it installs and
that vtable's first slots (the sampling methods the controllers call: +08
float, +18 vector, +20 matrix).

  python anm_key_classes.py
"""

from __future__ import annotations

import struct
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent
sys.path.insert(0, str(ROOT / 'vendor'))

import capstone  # noqa: E402
import pefile  # noqa: E402

EXE = Path(r'C:\Program Files (x86)\Steam\steamapps\common\NARUTO X BORUTO Ultimate Ninja STORM CONNECTIONS\NSUNSC.exe')
FACTORY, TABLE, FIRST, COUNT = 0x141367040, 0x141367728, 5, 25

if __name__ == '__main__':
    pe = pefile.PE(str(EXE), fast_load=True)
    base = pe.OPTIONAL_HEADER.ImageBase
    read = lambda va, size: pe.get_data(va - base, size)
    md = capstone.Cs(capstone.CS_ARCH_X86, capstone.CS_MODE_64)
    cases = [base + struct.unpack_from('<I', read(TABLE, 4 * COUNT), 4 * n)[0] for n in range(COUNT)]
    seen = {}
    for n, case in enumerate(cases):
        fmt = FIRST + n
        if case in seen:
            print(f'format {fmt:2d} ({fmt:#04x}): same as format {seen[case]}')
            continue
        seen[case] = fmt
        line = size = None
        vtables, calls = [], []
        for ins in md.disasm(read(case, 0x120), case):
            if ins.mnemonic == 'mov' and ins.op_str.startswith('r8d, 0x') and line is None:
                line = int(ins.op_str.split(', ')[1], 16)
            if ins.mnemonic == 'lea' and ins.op_str.startswith('ecx, [r8') and size is None and line is not None:
                tail = ins.op_str.split('[r8')[1].rstrip(']').replace(' ', '')
                size = line + (int(tail, 16) if tail else 0)
            if ins.mnemonic == 'mov' and ins.op_str.startswith('ecx, 0x') and size is None and line is not None:
                size = int(ins.op_str.split(', ')[1], 16)
            if ins.mnemonic == 'lea' and 'rip' in ins.op_str:
                target = ins.address + ins.size + int(ins.op_str.split('rip ')[1].rstrip(']').replace(' ', ''), 16)
                if 0x141b90000 <= target < 0x141bb0000 and target != 0x141ba0ee0:
                    vtables.append(target)
            if ins.mnemonic == 'call' and ins.op_str.startswith('0x'):
                calls.append(ins.op_str)
            if ins.mnemonic == 'jmp' and ins.op_str.startswith('0x1413676'):
                break
        slots = ''
        if vtables:
            raw = read(vtables[-1], 8 * 6)
            slots = ' '.join(f'+{8 * i:02x}:{struct.unpack_from("<Q", raw, 8 * i)[0]:#x}' for i in range(6))
        print(f'format {fmt:2d} ({fmt:#04x}): case {case:#x} line {line} size {size} vtables {[hex(v) for v in vtables]} '
              f'calls {calls[:4]}\n      {slots}')
