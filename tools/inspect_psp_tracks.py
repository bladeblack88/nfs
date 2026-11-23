#!/usr/bin/env python3
"""Inventory PSP Most Wanted track VIV packages in an ISO9660 image.

This tool extracts the track VIV files and inventories embedded BIGF markers,
mesh-name references and readable asset-name strings. It does NOT decrypt or
decode proprietary mesh/texture payloads.
"""
from __future__ import annotations
import argparse, json, os, re, struct
from pathlib import Path

SECTOR = 2048

def record(buf: bytes):
    if len(buf) < 34 or not buf[0]:
        return None
    n = buf[32]
    raw = buf[33:33+n]
    if raw == b"\\x00": name = "."
    elif raw == b"\\x01": name = ".."
    else: name = raw.decode("ascii", "replace")
    extent = struct.unpack("<I", buf[2:6])[0]
    size = struct.unpack("<I", buf[10:14])[0]
    flags = buf[25]
    return name, extent, size, flags

def iso_entries(path: Path):
    with path.open("rb") as f:
        f.seek(16 * SECTOR)
        pvd = f.read(SECTOR)
        if pvd[1:6] != b"CD001":
            raise ValueError("Not an ISO9660 image (missing primary volume descriptor)")
        rr = pvd[156]
        root = record(pvd[156:156+rr])
        if not root: raise ValueError("ISO root directory not found")
        found = []
        def walk(extent, size, prefix="", depth=0):
            if depth > 12: return
            f.seek(extent * SECTOR)
            data = f.read(size)
            i = 0
            while i < len(data):
                n = data[i]
                if n == 0:
                    i = ((i // SECTOR) + 1) * SECTOR
                    continue
                ent = record(data[i:i+n]); i += n
                if not ent: continue
                name, e, s, flags = ent
                if name in (".", ".."): continue
                name = name.split(";")[0]
                full = prefix + "/" + name
                found.append((full, e, s, flags))
                if flags & 2: walk(e, s, full, depth+1)
        walk(root[1], root[2])
        return found

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("iso", type=Path)
    ap.add_argument("--out", type=Path, default=Path("psp_track_extract"))
    args = ap.parse_args()
    entries = iso_entries(args.iso)
    tracks = [x for x in entries if "/tracks/" in x[0].lower() and x[0].lower().endswith(".viv")]
    args.out.mkdir(parents=True, exist_ok=True)
    results = []
    with args.iso.open("rb") as f:
        for name, sector, size, _ in tracks:
            f.seek(sector * SECTOR)
            data = f.read(size)
            filename = name.rsplit("/", 1)[-1]
            (args.out / filename).write_bytes(data)
            strings = [m.group().decode("ascii", "ignore")
                       for m in re.finditer(rb"[\\x20-\\x7e]{4,}", data)]
            keys = ("road", "bridge", "tunnel", "building", "police",
                    "factory", "textureusage", "parking", "warehouse",
                    "stadium", "ship", "grocery")
            names = list(dict.fromkeys(x for x in strings
                         if any(k in x.lower() for k in keys) or
                            ".msh" in x.lower() or ".ord" in x.lower()))
            results.append({
                "archive": filename, "iso_sector": sector, "bytes": size,
                "bigf_offsets": [m.start() for m in re.finditer(b"BIGF", data)],
                "mesh_name_offsets": [m.start() for m in re.finditer(rb"X0\\.msh", data)],
                "asset_name_strings": names[:200]
            })
    (args.out / "track_asset_manifest.json").write_text(
        json.dumps(results, indent=2), encoding="utf-8")
    print(f"Extracted {len(results)} track archives to {args.out}")
    print("Inventory only: proprietary mesh/texture decoding is not performed.")

if __name__ == "__main__":
    main()
