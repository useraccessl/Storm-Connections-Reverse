"""Native render-state encoding of NSUNSC.exe, decoded from its D3D11 builders.

The engine keeps a 0xd0-byte packed state block per material/draw:
  +0x00 u64  rasterizer bits      (builder 0x141423b70)
  +0x08 f32  SlopeScaledDepthBias
  +0x0c f32  DepthBiasClamp
  +0x20 u32  depth/stencil bits   (builder 0x141423a40)
  +0x24 u16  front-face stencil, +0x26 u16 back-face stencil, +0x28 u8 stencil ref
  +0x29 u8   AlphaToCoverageEnable
  +0x30 u64 x8 per-target blend   (builder 0x1414238f0)
  +0xb8 u32  primitive topology (D3D value), +0xbc f32 x4 blend factor
Blend modes are 4-bit codes into two 13-entry tables (0x14126bc70).
Run with --verify to re-read every table from the installed executable.
"""

from __future__ import annotations

import struct

# raw factor code -> D3D11_BLEND (helper 0x141412940; out of range -> ONE)
BLEND_FACTOR = [1, 2, 3, 4, 5, 6, 9, 10, 7, 8, 11, 14, 15, 14, 15, 16, 17, 18, 19]
D3D11_BLEND = {1: 'Zero', 2: 'One', 3: 'SrcColor', 4: 'InvSrcColor', 5: 'SrcAlpha', 6: 'InvSrcAlpha',
               7: 'DstAlpha', 8: 'InvDstAlpha', 9: 'DstColor', 10: 'InvDstColor', 11: 'SrcAlphaSat',
               14: 'BlendFactor', 15: 'InvBlendFactor', 16: 'Src1Color', 17: 'InvSrc1Color',
               18: 'Src1Alpha', 19: 'InvSrc1Alpha'}
# raw op code -> D3D11_BLEND_OP (helper 0x141412a80; out of range -> ADD)
D3D11_BLEND_OP = {0: 'Add', 1: 'Subtract', 2: 'ReversedSubtract', 3: 'Min', 4: 'Max'}
# raw comparison code -> D3D11_COMPARISON_FUNC (helper 0x141412b50)
D3D11_COMPARISON = ['Never', 'Less', 'Equal', 'LessEqual', 'Greater', 'NotEqual', 'GreaterEqual', 'AlwaysPass']
# raw cull code -> D3D11_CULL_MODE (helper 0x141412c00)
D3D11_CULL = {0: 'NoCull', 1: 'Front', 2: 'Back', 3: 'Back'}

# 4-bit blend mode -> (src raw, op raw, dst raw); tables at 0x141b91150 / 0x141b911f0
COLOR_MODE_TABLE_VA = 0x141b91150
ALPHA_MODE_TABLE_VA = 0x141b911f0
COLOR_MODES = [(1, 0, 0), (4, 0, 5), (4, 0, 1), (4, 2, 1), (0, 0, 4), (4, 2, 4), (8, 0, 9),
               (8, 0, 1), (8, 2, 1), (8, 0, 0), (6, 0, 0), (1, 0, 5), (1, 0, 1)]
ALPHA_MODES = [(1, 0, 0), (4, 0, 5), (4, 0, 1), (4, 2, 1), (0, 0, 4), (4, 2, 4), (8, 0, 9),
               (8, 0, 1), (8, 2, 1), (0, 0, 1), (0, 0, 0), (1, 0, 5), (1, 0, 1)]


def factor_name(raw: int) -> str:
    return D3D11_BLEND[BLEND_FACTOR[raw] if 0 <= raw < len(BLEND_FACTOR) else 2]


def blend_mode(code: int, alpha: bool = False) -> tuple[str, str, str] | None:
    """(source, destination, operation) for a 4-bit mode code, RenderDoc-style names."""
    table = ALPHA_MODES if alpha else COLOR_MODES
    if not 0 <= code < len(table):
        return None
    src, op, dst = table[code]
    return factor_name(src), factor_name(dst), D3D11_BLEND_OP.get(op, 'Add')


def decode_blend_entry(value: int) -> dict:
    return {
        'enable': bool(value & 1),
        'rgb': (factor_name((value >> 1) & 31), factor_name((value >> 6) & 31), D3D11_BLEND_OP.get((value >> 11) & 7, 'Add')),
        'alpha': (factor_name((value >> 14) & 31), factor_name((value >> 19) & 31), D3D11_BLEND_OP.get((value >> 24) & 7, 'Add')),
        'write_mask': (value >> 27) & 0xff,
    }


def decode_depth(value: int) -> dict:
    func = (value >> 2) & 0xf
    return {
        'enable': bool(value & 1), 'write': bool(value & 2),
        'function': D3D11_COMPARISON[func] if func < 8 else 'Less',
        'stencil_enable': bool(value & 0x40),
        'stencil_read_mask': (value >> 7) & 0xff, 'stencil_write_mask': (value >> 15) & 0xff,
    }


def decode_raster(value: int) -> dict:
    bias = (value >> 4) & 0xffffffff
    return {
        'solid': bool(value & 1), 'cull': D3D11_CULL[(value >> 1) & 3],
        'front_counter_clockwise': bool(value & 8),
        'depth_bias': bias - (1 << 32) if bias & 0x80000000 else bias,
        'multisample': bool(value >> 36 & 1),
    }


def nud_cull_code(cull_mode: int) -> int:
    """0x141272000: NUD cull word -> raw cull code."""
    if cull_mode in (0, 0x408):
        return 0
    return 1 if cull_mode == 0x404 else 2


def nud_material_state(material: dict) -> dict:
    """State a NUD material sets in 0x141270830 (inventory field names).

    `dest_factor` holds the colour mode in bits 0-3 and the alpha mode in
    bits 4-7; `source_factor` bit 2 clears depth write. Blend enable and the
    write mask are not material fields: unless the material claims them they
    are taken from the pass-level state at execution time (0x141400360).
    Blend enable therefore follows the sort bucket, which 0x141241450 derives
    from `source_factor` (copied to material+0x48): bit 0 clear -> bucket 0
    (front to back, blending off in a 0x141219480 layer); otherwise bucket 2
    (back to front), or bucket 1 / 3 when bit 1 is set (bit 3 picks 3).
    """
    dst, src = material.get('dest_factor', 0), material.get('source_factor', 0)
    bucket = 0 if not src & 1 else 2 if not src & 2 else 3 if src & 8 else 1
    return {
        'rgb': blend_mode(dst & 0xf), 'alpha': blend_mode((dst >> 4) & 0xf, alpha=True),
        'sort_bucket': bucket, 'blend_enabled': bucket != 0,
        'depth_write': not (src >> 2) & 1,
        'state_preset': (src >> 5) & 7,
        'cull': D3D11_CULL[nud_cull_code(material.get('cull_mode', 0))],
        'front_counter_clockwise': True,
        'topology': 'TriangleStrip',
    }


if __name__ == '__main__':
    import argparse

    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--verify', action='store_true')
    if ap.parse_args().verify:
        from disasm_batch import Image

        img = Image()
        for name, va, table in (('colour', COLOR_MODE_TABLE_VA, COLOR_MODES), ('alpha', ALPHA_MODE_TABLE_VA, ALPHA_MODES)):
            native = [struct.unpack('<3i', img.read(va + i * 12, 12)) for i in range(len(table))]
            assert native == table, f'{name} mode table differs: {native}'
        default = struct.unpack('<Q', img.read(0x141badd30, 8))[0]
        assert decode_blend_entry(default) == {'enable': False, 'rgb': ('One', 'Zero', 'Add'),
                                               'alpha': ('One', 'Zero', 'Add'), 'write_mask': 15}, default
        print('PASS: blend mode tables and default blend entry match the executable')
    for code in range(len(COLOR_MODES)):
        print(f'mode {code:2d}: colour {blend_mode(code)}  alpha {blend_mode(code, alpha=True)}')
