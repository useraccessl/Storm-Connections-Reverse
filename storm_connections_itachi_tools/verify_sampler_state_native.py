"""Native check of the NUD sampler state conversion.

Runs the game's own converters (NSUNSC.exe mapped by native_image.py) over
every byte value and compares them with the tables the importer uses:

  0x1412720a0  NUD wrap code      -> engine address enum
  0x141412810  engine address enum -> D3D11_TEXTURE_ADDRESS_MODE
  0x141272030  NUD filter codes   -> engine filter enum
  0x141bae530  engine filter enum -> D3D11_FILTER (table read by 0x141425e50)

0x141425e50 builds the D3D11_SAMPLER_DESC from the packed description: the
border colour is left at zero, MipLODBias, MinLOD and MaxLOD come from the
description floats.
"""

from __future__ import annotations

import ctypes
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent
sys.path.insert(0, str(ROOT / 'vendor'))

from native_image import NativeImage  # noqa: E402
from shader_port import address_mode, nud_filter  # noqa: E402

D3D11_ADDRESS = {1: 'wrap', 2: 'mirror', 3: 'clamp', 4: 'border', 5: 'mirror_once'}
OUT = ROOT / 'captured_assets' / 'procedural' / 'sampler_state_native_verification.json'


def main() -> int:
    image = NativeImage()
    wrap_code = image.function(0x1412720a0, ctypes.c_uint32, ctypes.c_uint32)
    address = image.function(0x141412810, ctypes.c_uint32, ctypes.c_uint32)
    native = {}
    for code in range(256):
        native[code] = D3D11_ADDRESS[address(wrap_code(code))]
    engine = {value: D3D11_ADDRESS[address(value)] for value in range(16)}
    filters = [image.unpack('<I', 0x141bae530 + 4 * i)[0] for i in range(10)]
    failures = []
    for code in range(256):
        expected = address_mode(code)
        if native[code] != expected:
            failures.append((code, native[code], expected))
    # Filter: 0x141272030(minify code, magnify code) over every pair of bytes.
    filter_kind = image.function(0x141272030, ctypes.c_uint32, ctypes.c_uint32, ctypes.c_uint32)
    kinds = {}
    for minify in range(256):
        for magnify in range(256):
            kind = filter_kind(minify, magnify)
            kinds[kind] = kinds.get(kind, 0) + 1
            if kind != nud_filter(minify, magnify):
                failures.append(('filter', minify, magnify, kind, nud_filter(minify, magnify)))
    print('NUD filter codes -> engine filter (native), pairs per result:', dict(sorted(kinds.items())))
    distinct = {}
    for code, mode in native.items():
        distinct.setdefault(mode, []).append(code)
    print('NUD wrap code -> D3D11 address mode (native):')
    for mode, codes in distinct.items():
        shown = codes if len(codes) <= 8 else f'{len(codes)} codes (every other value)'
        print(f'  {mode:12s} {shown}')
    print('engine address enum -> D3D11:', engine)
    print('engine filter enum -> D3D11_FILTER:', [f'{value:#x}' for value in filters])
    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(json.dumps({'nud_wrap_code': native, 'engine_address_enum': engine, 'engine_filter_table': filters,
                               'filter_pairs_checked': 65536, 'filter_pairs_per_result': kinds, 'failures': failures}, indent=1))
    print(f'WROTE: {OUT}')
    print('PASS' if not failures else f'FAIL: {failures[:8]}')
    return 1 if failures else 0


if __name__ == '__main__':
    sys.exit(main())
