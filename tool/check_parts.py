"""Check that each on-demand page (main.dart.js_N.part.js) is the one the
built main.dart.js expects, so a deploy can't ship mismatched files (the
app then shows "Couldn't load this page").

Usage (from frontend/): python tool/check_parts.py build/web
"""
import json
import re
import sys
from pathlib import Path

folder = Path(sys.argv[1] if len(sys.argv) > 1 else "build/web")
main = (folder / "main.dart.js").read_text(encoding="utf-8")
uris = json.loads(re.search(r"deferredPartUris:(\[[^\]]*\])", main).group(1))
hashes = json.loads(re.search(r"deferredPartHashes:(\[[^\]]*\])", main).group(1))
bad = []
for uri, expected in zip(uris, hashes):
    part = folder / uri
    found = re.findall(r'a\["([^"]+)"\]=a\.current', part.read_text(encoding="utf-8")) if part.exists() else []
    if found != [expected]:
        bad.append(f"{uri}: expected {expected}, found {found or 'no file'}")
extra = sorted({p.name for p in folder.glob("main.dart.js_*.part.js")} - set(uris))
if extra:
    bad.append(f"leftover pages from an older build: {', '.join(extra)}")
if bad:
    print("On-demand pages don't match main.dart.js:\n  " + "\n  ".join(bad), file=sys.stderr)
    sys.exit(1)
print(f"On-demand pages match main.dart.js ({len(uris)} files).")
