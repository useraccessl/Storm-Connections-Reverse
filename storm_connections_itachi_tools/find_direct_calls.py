"""Find candidate x64 E8 call sites in executable sections (validate in disassembly)."""
import argparse
import struct
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent / "vendor"))
import pefile
from disasm_exe import EXE

ap = argparse.ArgumentParser()
ap.add_argument("target", type=lambda x: int(x, 0))
args = ap.parse_args()
data = EXE.read_bytes()
pe = pefile.PE(data=data, fast_load=True)
base = pe.OPTIONAL_HEADER.ImageBase
for section in pe.sections:
    if not section.Characteristics & 0x20000000:
        continue
    code = section.get_data()
    cursor = 0
    while True:
        cursor = code.find(b"\xe8", cursor)
        if cursor < 0 or cursor + 5 > len(code):
            break
        address = base + section.VirtualAddress + cursor
        displacement = struct.unpack_from("<i", code, cursor + 1)[0]
        if address + 5 + displacement == args.target:
            print(hex(address))
        cursor += 1
