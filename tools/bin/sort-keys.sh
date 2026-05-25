#!/usr/bin/env bash
# =============================================================================
# sort-keys.sh - Sort JSON keys alphabetically across all translation files
#
# Rewrites every *.json file in the project root with its keys sorted in
# ascending alphabetical order using `jq -S`. Operates in-place via a
# temporary file to avoid data loss on failure.
#
# Usage:
#   bash tools/bin/sort-keys.sh
#   # or via the main entry point:
#   bash tools/i18n.sh sort
#
# Requirements: jq
# =============================================================================

set -e

if ! command -v jq &> /dev/null; then
  echo "jq is required but not installed. Please install jq and try again."
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/../.." || exit 1
FILES=$(find . -maxdepth 1 -type f -name "*.json")

for file in $FILES; do
  tmp="$(mktemp)"
  jq -S '.' "$file" > "$tmp" && mv "$tmp" "$file"
  echo "Sorted keys in $file"
done
