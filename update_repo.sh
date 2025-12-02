#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -lt 2 ]; then
  echo "Usage: $0 <codename> /path/to/*.deb"
  echo "Example: $0 trixie /tmp/debs/*.deb"
  exit 1
fi

CODENAME="$1"
shift

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$BASE_DIR"

for deb in "$@"; do
  if [ ! -f "$deb" ]; then
    echo "Skipping missing file: $deb"
    continue
  fi
  echo "Importing $deb into suite '$CODENAME'"
  reprepro -b . includedeb "$CODENAME" "$deb"
done

git add .
if ! git diff --cached --quiet; then
  git commit -m "Update packages in $CODENAME via update_repo.sh"
  git push origin gh-pages
else
  echo "No changes to commit."
fi
