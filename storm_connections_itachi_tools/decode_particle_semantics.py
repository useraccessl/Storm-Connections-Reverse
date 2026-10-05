"""Decode only fields whose uses were traced in the original executable.

No guessed seconds, spatial units, shape names, or default start events.
See particle_runtime_notes.md for evidence addresses.
"""
import json
import struct
from pathlib import Path

ROOT = Path(__file__).resolve().parent


def decode_events(section):
    data = bytes.fromhex(section['raw_hex'])
    cursor = 0
    entries = []
    for index in range(section['count']):
        count = struct.unpack_from('>I', data, cursor)[0]
        size = (4 + count * 4 + 7) & ~7
        if cursor + size > len(data):
            raise ValueError('event entry exceeds section')
        events = []
        for n in range(count):
            word = struct.unpack_from('>I', data, cursor + 4 + n * 4)[0]
            events.append({'raw': f'0x{word:08x}',
                           'clock_threshold_ms': word & 0x0fffffff,
                           'action': ('start_emission' if word & 0x80000000 else
                                      'stop_emission_and_notify_particles' if word & 0x40000000 else
                                      'stop_emission'),
                           'start_flag': bool(word & 0x80000000),
                           'stop_flag': bool(word & 0x40000000),
                           'other_flags': f'0x{word & 0x30000000:08x}'})
        entries.append({'emitter_id': index + 1, 'events': events,
                        'padding_hex': data[cursor + 4 + count * 4:cursor + size].hex()})
        cursor += size
    if cursor != len(data):
        raise ValueError(f'unconsumed event bytes: {len(data)-cursor}')
    return entries


def main():
    source = json.loads((ROOT / 'particle_records_typed.json').read_text())
    graphs = {g['name']: g for g in json.loads((ROOT / 'particle_graph.json').read_text())}
    output = []
    for chunk in source:
        name = Path(chunk['source']).stem
        events = decode_events(chunk['sections'][4])
        emitters = []
        for record, event, graph in zip(chunk['sections'][0]['records'], events,
                                        graphs[name]['emitters'], strict=True):
            raw = bytes.fromhex(record['raw_hex'])
            f = lambda off: struct.unpack_from('>f', raw, off)[0]
            h = lambda off: struct.unpack_from('>h', raw, off)[0]
            emitters.append({
                'id': record['emitter_id'],
                'resources': [r['name'] for r in graph['resources']],
                'emission_mode_byte_0x10': raw[0x10],
                'emission_kind': 'direct_count' if raw[0x10] == 1 else 'rate_accumulator',
                'shape_selector_0x11': raw[0x11],
                'direction_selector_0x12': raw[0x12],
                'orientation_selector_0x13': raw[0x13],
                'rotation_selector_0x14': raw[0x14],
                'config_flags_0x16': struct.unpack_from('>H', raw, 0x16)[0],
                'simulation_step_override_0x15': raw[0x15] & 0x3f,
                'emission_duration_counter_0x1c': h(0x1c),
                'emission_quantity_0x20': f(0x20),
                'spawn_radius_0x24': f(0x24),
                'spawn_radial_random_fraction_0x28': f(0x28),
                'base_lifetime_counter_0x2c': h(0x2c),
                'lifetime_random_multiplier_0x30': f(0x30),
                'speed_base_0x34': f(0x34),
                'speed_random_multiplier_0x38': f(0x38),
                'direction_angles_0x3c_0x40': [f(0x3c), f(0x40)],
                'direction_angle_ranges_0x44_0x48': [f(0x44), f(0x48)],
                'fade_in_lifetime_fraction_0x4c': f(0x4c),
                'fade_out_lifetime_fraction_0x50': f(0x50),
                'spawn_scalar_base_0x54': f(0x54),
                'spawn_scalar_random_range_0x58': f(0x58),
                'size_start_0x5c': [f(0x5c+i*4) for i in range(3)],
                'size_random_multipliers_0x68': [f(0x68+i*4) for i in range(3)],
                'size_middle_0x74': [f(0x74+i*4) for i in range(3)],
                'size_end_0x80': [f(0x80+i*4) for i in range(3)],
                'size_middle_life_fraction_0x8c': f(0x8c),
                'color_start_0x90': [f(0x90+i*4) for i in range(4)],
                'color_middle_0xa0': [f(0xa0+i*4) for i in range(4)],
                'color_end_0xb0': [f(0xb0+i*4) for i in range(4)],
                'color_middle_life_fraction_0xc0': f(0xc0),
                'event_entry': event,
            })
        output.append({'name': name, 'emitters': emitters})
    (ROOT / 'particle_semantics.json').write_text(json.dumps(output, indent=2)+'\n', encoding='utf-8')
    for chunk in output:
        print(chunk['name'])
        for e in chunk['emitters']:
            print(e['id'], ','.join(e['resources']), e['emission_kind'],
                  e['emission_quantity_0x20'], 'life', e['base_lifetime_counter_0x2c'],
                  'events', e['event_entry']['events'])


if __name__ == '__main__':
    main()
