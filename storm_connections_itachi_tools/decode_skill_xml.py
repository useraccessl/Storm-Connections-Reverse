"""Decode the two Amaterasu nuccChunkBinary XML payloads for inspection."""

from pathlib import Path
import struct


ROOT = Path(__file__).resolve().parent
SOURCE = ROOT / "chunks/2efb_amt_x/nuccChunkBinary"
OUTPUT = ROOT / "skill_xml"
OUTPUT.mkdir(parents=True, exist_ok=True)
for name in ("2efb_amt_e_begin00", "2efb_amt_e_hit00"):
    data = (SOURCE / f"{name}.bin").read_bytes()
    size = struct.unpack_from(">I", data)[0]
    if size > len(data) - 4:
        raise ValueError(f"Invalid XML length in {name}")
    xml = data[4:4 + size].decode("cp932")
    if "<" not in xml:
        raise ValueError(f"No XML in {name}")
    xml = xml.replace('encoding="Shift_JIS"', 'encoding="UTF-8"', 1)
    (OUTPUT / f"{name}.xml").write_text(xml, encoding="utf-8")
    print(name, len(xml), "characters")
