"""Decode original effect ANM curves, preserving indices and raw values.

Curve formats cross-checked against maxcabd/cc2_xfbin_blender_anm
xfbin_lib/xfbin/structure/br/br_anm.py. These effect chunks use the
20-byte header confirmed by NSUNSC.exe 0x14134a473 (version > 0x65).
"""
import json
import struct
import argparse
from pathlib import Path
from xfbin_chunks import parse
from inspect_page_refs import table, resolve

ROOT = Path(__file__).resolve().parent
# Key classes of the factory 0x141367040 (anm_key_classes.py); 15 and 29 are
# read as unsigned shorts (0x141394da0 interpolates, 0x141394e20 holds), 16 as
# signed (0x141394ee0).
FORMATS = {5:'3f',6:'i3f',8:'3f',10:'i4f',11:'f',12:'if',15:'H',
           16:'3h',17:'4h',20:'3B',21:'3f',22:'f',24:'f',26:'3f',27:'4h',29:'H'}

def decode(body, ref, chunk=None, legacy=False, resolvers=None):
    """ref(i) is the name the animation gives a reference (an instance name: one
    clump can be instanced twice as `x_01`, `x_02`); chunk(i), when given, is the
    (type, name) of the chunk that reference points to. legacy: chunk version
    <= 0x65, whose 16-byte header has no frame step (reader 0x14134a350 then
    uses 3000 / 30 = 100 ticks).

    resolvers: per kind of reference, a (ref, chunk) pair replacing the defaults:
    'clump' (the clump of a clump block), 'member' (its coordinates / materials and
    its models), 'other' (objects outside the clumps and the extra coordinates). The
    reader 0x14134a350 resolves them differently (journal R86)."""
    resolvers = resolvers or {}
    clump_ref, clump_chunk = resolvers.get('clump', (ref, chunk))
    member_ref, member_chunk = resolvers.get('member', (ref, chunk))
    other_ref, other_chunk = resolvers.get('other', (ref, chunk))
    pos = 0
    def read(fmt):
        nonlocal pos
        result = struct.unpack_from('>'+fmt, body, pos)
        pos += struct.calcsize('>'+fmt)
        return result
    if legacy:
        frames, entries, loop, nc, no, nop, np = read('I6H')
        step = 100
    else:
        frames, step, entries, loop, nc, no, nop, np = read('2I6H')
    clumps = []
    for _ in range(nc):
        ci, nb, nm = read('IHH')
        bones = [read('I')[0] for _ in range(nb)]
        models = [read('I')[0] for _ in range(nm)]
        clump = {'name':clump_ref(ci),'bones':[member_ref(i) for i in bones],'models':[member_ref(i) for i in models]}
        if chunk:
            clump.update({'chunk':clump_chunk(ci)[1],'boneChunks':[list(member_chunk(i)) for i in bones],
                          'modelChunks':[list(member_chunk(i)) for i in models]})
        clumps.append(clump)
    other_refs = [read('I')[0] for _ in range(no)]
    others = [other_ref(i) for i in other_refs]
    parents = [read('hHhH') for _ in range(np)]
    other_coords = [other_ref(read('I')[0]) for _ in range(nop)]
    result = []
    for _ in range(entries):
        ci, bi, et, count = read('h3H')
        headers = [read('3Hh') for _ in range(count)]
        curves = []
        for idx, fmt, nk, flags in headers:
            if fmt not in FORMATS:
                raise ValueError(f'unsupported curve {fmt:x} at {pos:x}')
            values = [read(FORMATS[fmt]) for _ in range(nk)]
            pos = (pos+3)&~3
            curves.append({'index':idx,'format':fmt,'flags':flags,'values':values})
        target = others[bi] if ci == -1 else clumps[ci]['bones'][bi]
        entry = {'target':target,'type':et,'clump_index':ci,'bone_index':bi,'curves':curves}
        if chunk and ci != -1:
            entry['chunk'] = clumps[ci]['boneChunks'][bi][1]
        elif chunk:
            # An object outside the clumps (camera, light): the chunk the reference points to.
            entry['chunkType'], entry['chunk'] = other_chunk(other_refs[bi])
        result.append(entry)
    if pos != len(body):
        raise ValueError(f'{len(body)-pos} unaccounted bytes at {pos:x}')
    return {'duration_ticks':frames,'frame_step_ticks':step,'loop':loop,'clumps':clumps,
            'other_coords':other_coords,'parents':parents,'entries':result}

if __name__ == '__main__':
    ap = argparse.ArgumentParser()
    ap.add_argument('xfbin', nargs='?', type=Path, default=ROOT/'extracted/data/effect/2efb_amt.xfbin')
    ap.add_argument('--output', type=Path, default=ROOT/'effect_animation.json')
    args = ap.parse_args()
    data, chunks = parse(args.xfbin)
    types, paths, names, maps, indices = table(data)
    counts = struct.unpack_from('>10I',data,28)
    ref_start = ((68+counts[1]+counts[3]+counts[5]+3)&~3)+counts[7]
    ref_pairs = [struct.unpack_from('>II',data,ref_start+i*8) for i in range(counts[9])]
    page_refs = {}
    cursor = 0
    for c in chunks:
        if c['type'] == 'nuccChunkPage':
            nr = struct.unpack_from('>I',data,c['offset']+4)[0]
            page_refs[c['page']] = ref_pairs[cursor:cursor+nr]
            cursor += nr
    output = {}
    for chunk in chunks:
        if chunk['type'] != 'nuccChunkAnm':
            continue
        body = data[chunk['offset']:chunk['offset']+chunk['size']]
        version = struct.unpack_from('>H',data,chunk['offset']-4)[0]
        if version <= 0x65:
            raise ValueError('legacy 16-byte ANM header is not handled by this decoder')
        if version <= 0x67:
            ref = lambda i: resolve((types,paths,names,maps,indices),chunk['page']+i)[2]
        else:
            ref = lambda i: names[page_refs[chunk['page']][i][0]]
        output[chunk['name']] = decode(body,ref)
        print(chunk['name'],len(output[chunk['name']]['entries']),'entries')
        for entry in output[chunk['name']]['entries']:
            print(' ',entry['target'],'type',entry['type'],
                  [(c['index'],hex(c['format']),len(c['values']),c['values'][:1]) for c in entry['curves']])
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(output,indent=2)+'\n')
