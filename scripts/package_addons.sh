#!/usr/bin/env bash
set -euo pipefail

# Usage: scripts/package_addons.sh <version>
# If version is omitted, reads from addons/usdx_lyrics/plugin.cfg

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
cfg_path="$repo_root/addons/usdx_lyrics/plugin.cfg"

if [[ $# -ge 1 && -n "$1" ]]; then
  version="$1"
else
  if [[ ! -f "$cfg_path" ]]; then
    echo "plugin.cfg not found at $cfg_path" >&2
    exit 1
  fi
  version=$(grep -Po '(?<=^version=")[^"]+' "$cfg_path" || true)
  if [[ -z "$version" ]]; then
    echo "Failed to read version from $cfg_path" >&2
    exit 1
  fi
fi

zip_name="usdx-lyrics-${version}.zip"
rm -f "$zip_name"

echo "Creating $zip_name from addons/"
cd "$repo_root"
if command -v zip >/dev/null 2>&1; then
  zip -r "$zip_name" addons
  echo "Created $zip_name"
else
  echo "zip not found; using Python fallback to create archive"
  if command -v python3 >/dev/null 2>&1; then
    _py=python3
  elif command -v python >/dev/null 2>&1; then
    _py=python
  else
    echo "Neither 'zip' nor 'python'/'python3' are available. Install one to create the archive." >&2
    exit 1
  fi
  $_py - <<'PY'
import os, zipfile
zip_name = os.environ.get('zip_name', '${zip_name}')
root = 'addons'
with zipfile.ZipFile(zip_name, 'w', compression=zipfile.ZIP_DEFLATED) as z:
    for dirpath, dirnames, filenames in os.walk(root):
        for fname in filenames:
            full = os.path.join(dirpath, fname)
            arcname = os.path.relpath(full, '.')
            z.write(full, arcname)
print('Created', zip_name)
PY
fi
