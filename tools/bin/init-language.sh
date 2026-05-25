#!/usr/bin/env bash
# =============================================================================
# init-language.sh - Bootstrap a new translation file from GGE game data
#
# Creates <lang>.json in the project root by:
#   1. Copying fr.json as a blank template (all string values emptied).
#   2. Fetching the corresponding GGE in-game strings for the target language.
#   3. Auto-populating every key listed in tools/data/ingame-keys.conf.
#
# Keys not covered by ingame-keys.conf are left empty for manual translation.
#
# Usage:
#   bash tools/bin/init-language.sh <lang-code>
#   # or via the main entry point:
#   bash tools/i18n.sh init <lang-code>
#
# Arguments:
#   lang-code   BCP-47 language code used by GGE (e.g. en, de, fr, es, pl, ar)
#
# Requirements: curl, jq
# =============================================================================

set -euo pipefail

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <language-code>"
    exit 1
fi

LANG_CODE="$1"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LANG_DIR="$SCRIPT_DIR/../.."

. "$SCRIPT_DIR/../lib/gge-api.sh"
. "$SCRIPT_DIR/../lib/colors.sh"

CONF_FILE="$SCRIPT_DIR/../data/ingame-keys.conf"

FILE_NAME="$LANG_DIR/${LANG_CODE}.json"

if [ -f "$FILE_NAME" ]; then
    echo "File $FILE_NAME already exists."
    exit 1
fi

if [ ! -f "$CONF_FILE" ]; then
    echo "Missing config file:"
    echo "$CONF_FILE"
    exit 1
fi

BASE_URL="https://empire-html5.goodgamestudios.com/config/languages/$GGE_XML_VERSION"

echo -e "${green_color}Using GGE XML version: $GGE_XML_VERSION${reset_color}"

echo -e "${green_color}Fetching ${LANG_CODE}.json...${reset_color}"

remote_json="$(curl -sf "$BASE_URL/$LANG_CODE.json")" || {
    echo "Could not fetch ${LANG_CODE}.json"
    exit 1
}

echo -e "${green_color}Creating template...${reset_color}"

cp "$LANG_DIR/fr.json" "$FILE_NAME"

# Empty recursively (works for nested objects)
jq '
walk(
    if type=="string"
    then ""
    else .
    end
)
' "$FILE_NAME" > tmp.json

mv tmp.json "$FILE_NAME"

echo -e "${green_color}Populating known translations...${reset_color}"

while IFS='=' read -r LOCAL_KEY REMOTE_KEY; do

    [[ -z "$LOCAL_KEY" ]] && continue
    [[ "$LOCAL_KEY" =~ ^# ]] && continue

    value="$(echo "$remote_json" | jq -er --arg key "$REMOTE_KEY" '.[$key]')" || {
        echo -e "${yellow_color}Missing GGE key: $REMOTE_KEY${reset_color}"
        continue
    }

    tmp="$(mktemp)"

    if [[ "$LOCAL_KEY" == *.* ]]; then

        IFS='.' read -ra path <<< "$LOCAL_KEY"

        jq \
            --arg value "$value" \
            --argjson path "$(printf '%s\n' "${path[@]}" | jq -R . | jq -s .)" \
            '
            setpath($path; $value)
            ' \
            "$FILE_NAME" > "$tmp"

    else

        jq \
            --arg key "$LOCAL_KEY" \
            --arg value "$value" \
            '
            . + {($key):$value}
            ' \
            "$FILE_NAME" > "$tmp"

    fi

    mv "$tmp" "$FILE_NAME"

    echo -e "${green_color}✓ ${LOCAL_KEY}${reset_color}"

done < "$CONF_FILE"

echo
echo -e "${green_color}Finished:${reset_color} $FILE_NAME"
