#!/usr/bin/env bash
# =============================================================================
# check-translations.sh - Validate translation files against the reference
#
# Reads every *.json file in the project root and verifies that:
#   1. The file is syntactically valid JSON.
#   2. Its key structure (all dot-notation paths) matches fr.json exactly.
#
# Exit codes:
#   0   All files are valid.
#   1   One or more files failed validation.
#
# Usage:
#   bash tools/bin/check-translations.sh
#   # or via the main entry point:
#   bash tools/i18n.sh check
#
# Requirements: jq
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

. "$SCRIPT_DIR/../lib/colors.sh"
. "$SCRIPT_DIR/../lib/helpers.sh"

readonly source_file="fr.json"
readonly translations_dir="$SCRIPT_DIR/../.."

if [ ! -f "$translations_dir/$source_file" ]; then
  echo -e "${red_color} Error: The file '$source_file' is missing.${reset_color}"
  exit 1
fi

errors=0

main() {
  print_header
  cd "$translations_dir" || exit 1
  ref_keys=$(extract_keys "$source_file")
  echo -e " Reference file: $source_file with $(echo "$ref_keys" | wc -l) keys."
  check_translations
  print_summary
}

check_translations() {
  for file in *.json; do
    [ "$file" = "$source_file" ] && continue
    echo -e "$yellow_color Checking file: $file...$reset_color"
    if [ ! -f "$file" ]; then
      echo -e " Error: $file does not exist."
      errors=$((errors + 1))
      continue
    fi
    if ! jq empty "$file" 2>/dev/null; then
      echo -e " Error: $file is not a valid JSON."
      errors=$((errors + 1))
      continue
    fi
    file_keys=$(extract_keys "$file")
    diff=$(diff -u <(echo "$ref_keys") <(echo "$file_keys") || true)
    if [ -n "$diff" ]; then
      echo -e " $yellow_color |- $red_color Error: differences detected in $file:$reset_color"
      echo "$diff"
      errors=$((errors + 1))
    else
      echo -e " $yellow_color |- $green_color Success: $file is valid and matches the reference structure.$reset_color"
    fi
  done
}

print_summary() {
  if [ $errors -eq 0 ]; then
    echo -e "\n${green_color} All translation files are valid and match the reference structure.${reset_color}"
    exit 0
  else
    echo -e "\n${red_color} Completed with $errors error(s). Please review the above messages.${reset_color}"
    exit 1
  fi
}

main
