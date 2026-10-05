"""Extract the exact shared NUT textures referenced by Itachi's Amaterasu."""

from pathlib import Path

from xfbin_chunks import parse, u32


HERE = Path(__file__).resolve().parent
SOURCE = HERE / "extracted/data/effect/1efcmn.xfbin"
OUTPUT = HERE / "textures/1efcmn"
NAMES = {"1efc_smk11", "1efc_film_clash00", "1efc_part03",
         "1efc_shock02", "1efc_fire04", "1efc_wav05", "1efc_falloff02"}


def main() -> None:
    data, chunks = parse(SOURCE)
    OUTPUT.mkdir(parents=True, exist_ok=True)
    found = set()
    for chunk in chunks:
        if chunk["type"] != "nuccChunkTexture" or chunk["name"] not in NAMES:
            continue
        start = chunk["offset"]
        size = u32(data, start + 8)
        nut = data[start + 12:start + 12 + size]
        if not nut.startswith(b"NTP3"):
            raise ValueError(f"Invalid NUT: {chunk['name']}")
        (OUTPUT / f"{chunk['name']}.nut").write_bytes(nut)
        found.add(chunk["name"])
        print(f"{chunk['name']}: {size} bytes")
    if found != NAMES:
        raise ValueError(f"Missing shared textures: {NAMES - found}")


if __name__ == "__main__":
    main()
