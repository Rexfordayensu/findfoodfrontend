"""Write the Content-Security-Policy for vercel.json.

The policy limits where the page may load code from and send data to, so
injected script can't run or ship a signed-in user's token elsewhere.
index.html has a few inline scripts; each is allowed by its SHA-256 hash, so
this runs after every build (tool/build_web.sh) to keep the hashes current.

Usage (from frontend/): python tool/update_csp.py
"""
import base64
import hashlib
import json
import re
import sys
from pathlib import Path

API = "https://findfooddelivery-backend.onrender.com"
# Photos: our image storage, the API's own /static files, Google profile pictures.
IMAGES = [API, "https://res.cloudinary.com", "https://*.googleusercontent.com"]
# Flutter loads fallback fonts (e.g. for ₵) from fonts.gstatic.com. Its
# renderer is served from our own site (build_web.sh: --no-web-resources-cdn).
FLUTTER = ["https://fonts.gstatic.com"]
# Maps: OpenFreeMap serves the map style, tiles, icons and label fonts. The
# map library itself is served from our own site (web/maplibre).
MAPS = ["https://tiles.openfreemap.org"]

root = Path(__file__).resolve().parent.parent
# Hash the file as Vercel serves it: git stores it with LF line endings
# (.gitattributes), even where a Windows checkout shows CRLF.
CR = chr(13)
html = (root / "web" / "index.html").read_bytes().decode("utf-8").replace(CR, "")
inline = re.findall(r"<script>(.*?)</script>", html, flags=re.S)
hashes = [
    "'sha256-" + base64.b64encode(hashlib.sha256(body.encode("utf-8")).digest()).decode() + "'"
    for body in inline
]

policy = "; ".join([
    "default-src 'self'",
    # wasm-unsafe-eval lets the renderer (WebAssembly) start; it does not
    # allow eval() of strings.
    "script-src 'self' 'wasm-unsafe-eval' " + " ".join(hashes),
    # Flutter positions its elements with inline styles.
    "style-src 'self' 'unsafe-inline'",
    "img-src 'self' data: blob: " + " ".join([*IMAGES, *MAPS]),
    "font-src 'self' data: https://fonts.gstatic.com",
    # wss: live order chat. blob: and data: let the app read a photo the
    # user just picked (the browser holds it at a blob: URL) before upload.
    "connect-src 'self' blob: data: " + " ".join([API, API.replace("https://", "wss://"), *FLUTTER, *IMAGES[1:], *MAPS]),
    "worker-src 'self' blob:",
    "manifest-src 'self'",
    "object-src 'none'",
    "base-uri 'self'",
    "form-action 'self'",
    "frame-ancestors 'none'",
    "upgrade-insecure-requests",
])

config_path = root / "vercel.json"
config = json.loads(config_path.read_text(encoding="utf-8"))
all_pages = next(h for h in config["headers"] if h["source"] == "/(.*)")
headers = [h for h in all_pages["headers"] if h["key"] != "Content-Security-Policy"]
headers.append({"key": "Content-Security-Policy", "value": policy})
all_pages["headers"] = headers
config_path.write_text(json.dumps(config, indent=2) + "\n", encoding="utf-8")
print(f"CSP updated: {len(hashes)} inline script(s) allowed by hash", file=sys.stderr)
