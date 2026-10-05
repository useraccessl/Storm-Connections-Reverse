"""Read CRI CPK file indexes without changing the game installation.

Only metadata is read. This script does not extract or decode payloads.
"""

from __future__ import annotations

import argparse
import json
import struct
from pathlib import Path


def _u(data: bytes, offset: int, size: int) -> int:
    return int.from_bytes(data[offset : offset + size], "big")


def _cstring(data: bytes, offset: int) -> str:
    end = data.find(b"\0", offset)
    if end < 0:
        raise ValueError("unterminated UTF string")
    return data[offset:end].decode("utf-8", errors="replace")


def _value(data: bytes, offset: int, kind: int, strings: int, blobs: int):
    widths = {0: 1, 1: 1, 2: 2, 3: 2, 4: 4, 5: 4, 6: 8, 7: 8, 8: 4, 9: 8, 10: 4, 11: 8}
    if kind not in widths:
        raise ValueError(f"unknown UTF type {kind}")
    width = widths[kind]
    if kind == 10:
        value = _cstring(data, strings + _u(data, offset, 4))
    elif kind == 11:
        start, length = _u(data, offset, 4), _u(data, offset + 4, 4)
        value = {"offset": blobs + start, "length": length}
    elif kind == 8:
        value = struct.unpack_from(">f", data, offset)[0]
    elif kind == 9:
        value = struct.unpack_from(">d", data, offset)[0]
    else:
        value = _u(data, offset, width)
    return value, width


def parse_utf(data: bytes):
    if data[:4] != b"@UTF":
        raise ValueError("not an @UTF table")
    # Offsets in @UTF are relative to byte 8 of the table.
    row_start = 8 + _u(data, 8, 4)
    strings = 8 + _u(data, 12, 4)
    blobs = 8 + _u(data, 16, 4)
    count = _u(data, 24, 2)
    row_width = _u(data, 26, 2)
    rows = _u(data, 28, 4)
    columns = []
    cursor = 32
    for _ in range(count):
        flag = data[cursor]
        name = _cstring(data, strings + _u(data, cursor + 1, 4))
        cursor += 5
        storage, kind = flag & 0xF0, flag & 0x0F
        constant = None
        if storage == 0x30:
            constant, width = _value(data, cursor, kind, strings, blobs)
            cursor += width
        columns.append((name, storage, kind, constant))
    result = []
    for row in range(rows):
        pos = row_start + row * row_width
        item = {}
        for name, storage, kind, constant in columns:
            if storage == 0x50:
                item[name], width = _value(data, pos, kind, strings, blobs)
                pos += width
            elif storage == 0x30:
                item[name] = constant
            elif storage == 0x10:
                item[name] = 0
            else:
                raise ValueError(f"unknown UTF storage 0x{storage:02x}")
        result.append(item)
    return result


def read_chunk(handle, offset: int, expected: bytes):
    handle.seek(offset)
    header = handle.read(16)
    if header[:4] != expected:
        raise ValueError(f"expected {expected!r} at 0x{offset:x}, got {header[:4]!r}")
    size = int.from_bytes(header[8:16], "little")
    if size > 100_000_000:
        raise ValueError(f"implausible table size: {size}")
    return parse_utf(handle.read(size))


def list_archive(path: Path):
    with path.open("rb") as handle:
        header = read_chunk(handle, 0, b"CPK ")[0]
        toc_offset = header.get("TocOffset", 0)
        if not toc_offset:
            raise ValueError("archive has no TOC")
        entries = read_chunk(handle, toc_offset, b"TOC ")
    return header, entries


def _cc2_decrypt(payload: bytearray):
    x, y, z, w = 0x154F048D, 0x02B3D1CD, 0x43A3D2F9, 0x617E9602
    for offset in range(0, len(payload), 4):
        t = x ^ ((x << 11) & 0xFFFFFFFF)
        t ^= t >> 8
        nxt = (w ^ (w >> 19) ^ t) & 0xFFFFFFFF
        key = nxt.to_bytes(4, "little")
        for i in range(min(4, len(payload) - offset)):
            payload[offset + i] ^= key[i]
        x, y, z, w = y, z, w, nxt


def _decompress_crilayla(data: bytes, expected: int) -> bytes:
    if not data.startswith(b"CRILAYLA"):
        raise ValueError("not a CRILAYLA payload")
    output_length, header_offset = struct.unpack_from("<II", data, 8)
    if output_length + 0x100 != expected:
        raise ValueError("unexpected CRILAYLA output size")
    raw_header = data[0x10 + header_offset : 0x110 + header_offset]
    if len(raw_header) != 0x100:
        raise ValueError("truncated CRILAYLA header")
    output = bytearray(expected)
    output[:0x100] = raw_header
    input_pos = len(data) - 0x100 - 1
    bit_pool = bits_left = 0

    def bits(count: int) -> int:
        nonlocal input_pos, bit_pool, bits_left
        value = 0
        while count:
            if bits_left == 0:
                if input_pos < 0:
                    raise ValueError("truncated CRILAYLA bitstream")
                bit_pool = data[input_pos]
                input_pos -= 1
                bits_left = 8
            take = min(count, bits_left)
            value = (value << take) | ((bit_pool >> (bits_left - take)) & ((1 << take) - 1))
            bits_left -= take
            count -= take
        return value

    written = 0
    while written < output_length:
        dest = expected - 1 - written
        if bits(1):
            source = dest + bits(13) + 3
            length = 3
            for width in (2, 3, 5, 8):
                part = bits(width)
                length += part
                if part != (1 << width) - 1:
                    break
            else:
                while True:
                    part = bits(8)
                    length += part
                    if part != 255:
                        break
            if source >= expected or written + length > output_length:
                raise ValueError("invalid CRILAYLA backreference")
            for _ in range(length):
                output[expected - 1 - written] = output[source]
                source -= 1
                written += 1
        else:
            output[dest] = bits(8)
            written += 1
    return bytes(output)


def extract_entry(archive: Path, header: dict, entry: dict, root: Path):
    relative = Path(str(entry.get("DirName", ""))) / str(entry["FileName"])
    if relative.is_absolute() or ".." in relative.parts:
        raise ValueError(f"unsafe archive path: {relative}")
    size = int(entry["FileSize"])
    expected = int(entry["ExtractSize"])
    if size > 50_000_000 or expected > 100_000_000:
        raise ValueError(f"asset exceeds extraction limit: {relative}")
    baseline = min(int(header["ContentOffset"]), int(header["TocOffset"]))
    offset = baseline + int(entry["FileOffset"])
    with archive.open("rb") as handle:
        handle.seek(offset)
        payload = bytearray(handle.read(size))
    if len(payload) != size:
        raise ValueError(f"truncated asset: {relative}")
    if not (payload.startswith(b"CRILAYLA") or payload.startswith(b"NUCC")):
        _cc2_decrypt(payload)
    if payload.startswith(b"CRILAYLA"):
        result = _decompress_crilayla(payload, expected)
    elif size == expected:
        result = bytes(payload)
    else:
        raise ValueError(f"unknown compression for {relative}: {payload[:8].hex()}")
    if not result.startswith(b"NUCC"):
        raise ValueError(f"unexpected extracted signature for {relative}: {result[:8].hex()}")
    target = root / relative
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_bytes(result)
    return target


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("archives", nargs="+", type=Path)
    parser.add_argument("--filter", default="")
    parser.add_argument("--json", action="store_true")
    parser.add_argument("--extract-dir", type=Path)
    args = parser.parse_args()
    for path in args.archives:
        try:
            header, entries = list_archive(path)
            matches = [e for e in entries if args.filter.lower() in (str(e.get("DirName", "")) + "/" + str(e.get("FileName", ""))).lower()]
            if args.extract_dir:
                if not args.filter:
                    raise ValueError("--extract-dir requires --filter")
                for entry in matches:
                    target = extract_entry(path, header, entry, args.extract_dir)
                    print(f"extracted {target}")
                continue
            if args.json:
                print(json.dumps({"archive": str(path), "header": header, "matches": matches}, ensure_ascii=False))
            else:
                print(f"{path.name}: {len(entries)} files, {len(matches)} matches")
                for e in matches:
                    print(f"  {e.get('DirName', '')}/{e.get('FileName', '')}")
        except Exception as exc:
            print(f"{path.name}: ERROR {exc}")


if __name__ == "__main__":
    main()
