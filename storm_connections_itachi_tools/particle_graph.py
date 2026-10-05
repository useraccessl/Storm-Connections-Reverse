"""Resolve original particle emitter, billboard, and attachment links."""

from __future__ import annotations

import json
import struct
from pathlib import Path

from inspect_page_refs import resolve, table
from inspect_particle import parse_particle
from xfbin_chunks import parse


ROOT = Path(__file__).resolve().parent
XFBIN = ROOT / "extracted/data/effect/2efb_amt.xfbin"
OUT = ROOT / "particle_graph.json"


def chunk_graph(data: bytes, table_data, chunk: dict, source_dir=None) -> dict:
    body = data[chunk["offset"]:chunk["offset"] + chunk["size"]]
    source = (Path(source_dir) if source_dir else ROOT / "chunks/2efb_amt/nuccChunkParticle") / (chunk["name"] + ".bin")
    if body != source.read_bytes():
        raise ValueError("XFBIN particle chunk differs from extracted data")
    parsed = parse_particle(source)
    emitter_count = parsed["sections"][0]["count"]
    emitters = {i: {"index": i, "resources": [], "attachments": [], "force_fields": []}
                for i in range(1, emitter_count + 1)}
    for record in parsed["sections"][0]["emitters"]:
        i = record["words_0_64"][1]
        if i not in emitters:
            raise ValueError(f"unexpected emitter id {i}")
        # Raw numbers have not yet been assigned physical meanings.
        emitters[i]["raw_words_0_64"] = record["words_0_64"]
    sections = parsed["sections"]
    for n in range(sections[1]["count"]):
        words = struct.unpack_from(">8I", body, sections[1]["file_offset"] + n * 32)
        local_ref, emitter_id = words[:2]
        if emitter_id not in emitters:
            raise ValueError(f"resource assigned to missing emitter {emitter_id}")
        kind, path, name = resolve(table_data, chunk["page"] + local_ref)
        emitters[emitter_id]["resources"].append({"page_index": local_ref,
                                                     "type": kind, "name": name,
                                                     "path": path})
    if sections[2]["size"] != sections[2]["count"] * 56:
        raise ValueError("unknown attachment stride")
    for n in range(sections[2]["count"]):
        words = struct.unpack_from(">14I", body, sections[2]["file_offset"] + n * 56)
        coord_ref, emitter_id, clump_ref = words[0], words[1], words[12]
        if emitter_id not in emitters:
            raise ValueError(f"attachment assigned to missing emitter {emitter_id}")
        coord = resolve(table_data, chunk["page"] + coord_ref)
        clump = resolve(table_data, chunk["page"] + clump_ref)
        if coord[0] != "nuccChunkCoord" or clump[0] != "nuccChunkClump":
            raise ValueError(f"attachment references wrong chunk types: {coord}, {clump}")
        emitters[emitter_id]["attachments"].append({"coord": coord[2], "clump": clump[2],
                                                      "coord_page_index": coord_ref,
                                                      "clump_page_index": clump_ref})
    if sections[3]["size"] != sections[3]["count"] * 112:
        raise ValueError("unknown force-field stride")
    for n in range(sections[3]["count"]):
        words = struct.unpack_from(">28I", body, sections[3]["file_offset"] + n * 112)
        ref, emitter_id = words[:2]
        kind, path, name = resolve(table_data, chunk["page"] + ref)
        emitters[emitter_id]["force_fields"].append({"page_index": ref,
                                                       "type": kind, "name": name})
    return {"name": chunk["name"], "emitters": list(emitters.values()),
            "section_counts": [s["count"] for s in sections]}


def main() -> None:
    data, chunks = parse(XFBIN)
    table_data = table(data)
    graphs = [chunk_graph(data, table_data, chunk) for chunk in chunks
              if chunk["type"] == "nuccChunkParticle"]
    OUT.write_text(json.dumps(graphs, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    for graph in graphs:
        print(graph["name"])
        for emitter in graph["emitters"]:
            resources = ", ".join(r["name"] for r in emitter["resources"])
            print(f"  {emitter['index']}: {resources}; attachments={len(emitter['attachments'])}")


if __name__ == "__main__":
    main()
