#!/usr/bin/env bash
# =============================================================================
# sync-gge-key.sh - Pull a GGE in-game string into all translation files
#
# For every *.json file in the project root, fetches the value of a GGE
# in-game key from the game's CDN and writes it to the specified local key.
# Supports dot-notation for targeting nested keys.
#
# Usage:
#   bash tools/bin/sync-gge-key.sh <gge-key> <local-key>
#   # or via the main entry point:
#   bash tools/i18n.sh sync <gge-key> <local-key>
#
# Arguments:
#   gge-key     Key name in GGE's language JSON  (e.g. dialog_inbox_sender)
#   local-key   Destination key in our files.
#               Use dot notation for nested keys (e.g. meta.Sender)
#
# Examples:
#   bash tools/i18n.sh sync dialog_inbox_sender Sender
#   bash tools/i18n.sh sync dialog_alliance_member meta.Members
#
# Requirements: curl, jq
# =============================================================================

set -euo pipefail

REMOTE_KEY="${1:-}"
LOCAL_KEY="${2:-}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LANG_DIR="$SCRIPT_DIR/../.."

function usage() {
  echo "Usage: $0 <gge-key> <local-key>"
  echo "Example: $0 'dialog_inbox_sender' 'Sender'"
  exit 1
}

. "$SCRIPT_DIR/../lib/gge-api.sh"
. "$SCRIPT_DIR/../lib/colors.sh"

if [[ -z "$REMOTE_KEY" || -z "$LOCAL_KEY" ]]; then
  usage
fi

echo -e "Using GGE XML version: $GGE_XML_VERSION"

BASE_URL="https://empire-html5.goodgamestudios.com/config/languages/$GGE_XML_VERSION"

for file in "$LANG_DIR"/*.json; do
  filename="$(basename "$file")"
  country="${filename%.json}"
  echo -e "${green_color}Processing $country...${reset_color}"
  remote_json="$(curl -sf "$BASE_URL/$country.json")" || {
    echo "Error: Could not fetch $country.json from GGE, exiting." && exit 1
  }
  value="$(echo "$remote_json" | jq -er --arg key "$REMOTE_KEY" '.[$key]')" || {
    echo "Error: Key '$REMOTE_KEY' not found in GGE $country.json, exiting." && exit 1
  }
  tmp="$(mktemp)"
  if [[ "$LOCAL_KEY" == *.* ]]; then
    IFS='.' read -ra path <<< "$LOCAL_KEY"
    jq --arg value "$value" \
      --argjson path "$(printf '%s\n' "${path[@]}" | jq -R . | jq -s .)" \
      'setpath($path; $value)' \
      "$file" > "$tmp"

    mv "$tmp" "$file"
    echo -e "${green_color}Updated $LOCAL_KEY in $filename with value from GGE $REMOTE_KEY.${reset_color}"
    continue
  fi
  jq --arg key "$LOCAL_KEY" --arg value "$value" '. + {($key): $value}' "$file" > "$tmp"
  mv "$tmp" "$file"
  echo -e "${green_color}Updated $LOCAL_KEY in $filename with value from GGE $REMOTE_KEY.${reset_color}"

done
