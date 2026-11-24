#!/usr/bin/env bash
# Regenerate the repo-layout tree in Readme.md from the real directory structure.
#
# Run from anywhere; finds the repo root itself. Idempotent: re-running just
# replaces the block between the markers below with a fresh `tree` dump.
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

README="Readme.md"
START="<!-- repo-tree:start -->"
END="<!-- repo-tree:end -->"
IGNORE='.git|.direnv|result|result-*|.jj|node_modules'

if ! command -v tree >/dev/null 2>&1; then
  echo "error: 'tree' is not installed" >&2
  exit 1
fi

tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT

in_block=0
while IFS= read -r line || [ -n "$line" ]; do
  if [ "$line" = "$START" ]; then
    echo "$line" >> "$tmp"
    echo '```' >> "$tmp"
    tree -I "$IGNORE" --dirsfirst >> "$tmp"
    echo '```' >> "$tmp"
    in_block=1
    continue
  fi
  if [ "$line" = "$END" ]; then
    in_block=0
    echo "$line" >> "$tmp"
    continue
  fi
  [ "$in_block" = 1 ] && continue
  echo "$line" >> "$tmp"
done < "$README"

mv "$tmp" "$README"
echo "Updated repo layout tree in $README"
