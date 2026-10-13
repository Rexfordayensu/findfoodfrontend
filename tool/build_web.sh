#!/usr/bin/env bash
# Build the web app and refresh the compiled files Vercel serves from web/.
#
# web/ is both Flutter's template folder and the deployed output, so a plain
# `flutter build web` copies the previously committed main.dart.js over the
# fresh build. This script moves the generated files aside first.
# Usage (from frontend/): bash tool/build_web.sh
set -euo pipefail
cd "$(dirname "$0")/.."

stash="$(mktemp -d)"
for f in .last_build_id assets canvaskit flutter.js flutter_bootstrap.js \
         flutter_service_worker.js main.dart.js version.json; do
  [ -e "web/$f" ] && mv "web/$f" "$stash/"
done
trap 'cp -rn "$stash"/. web/ 2>/dev/null || true' EXIT

rm -rf build/web
flutter build web --release

# The icon font is trimmed to the icons the app uses, so it changes whenever
# a new icon is added, but keeps the same name. Browsers that cached an older
# copy would show blank icons, so give it a content-hashed name.
font=build/web/assets/fonts/MaterialIcons-Regular.otf
if [ -f "$font" ]; then
  hash="$(md5sum "$font" | cut -c1-10)"
  mv "$font" "build/web/assets/fonts/MaterialIcons-Regular.$hash.otf"
  sed -i "s#fonts/MaterialIcons-Regular.otf#fonts/MaterialIcons-Regular.$hash.otf#"     build/web/assets/FontManifest.json
fi

cp -r build/web/. web/
# Success: drop the previous build instead of restoring it on exit.
trap - EXIT
rm -rf "$stash"
echo "web/ updated from a fresh build; commit and push to deploy."
