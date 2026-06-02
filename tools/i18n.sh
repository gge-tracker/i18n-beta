#!/usr/bin/env bash
# =============================================================================
# i18n.sh - GGE Tracker translation toolchain
#
# Entry point for all translation management tasks.
# Can be run from the project root or from the tools/ directory.
#
# Usage:
#   bash tools/i18n.sh <command> [arguments]
#
# Commands:
#   init  <lang-code>              Scaffold a new <lang>.json from GGE game data
#   sync  <gge-key> <local-key>   Pull a GGE in-game key into all language files
#   check                          Validate all .json files against fr.json
#   sort                           Sort all .json keys alphabetically (in-place)
#
# Examples:
#   bash tools/i18n.sh init es
#   bash tools/i18n.sh sync dialog_inbox_sender Sender
#   bash tools/i18n.sh check
#   bash tools/i18n.sh sort
#
# Requirements: curl, jq
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN="$SCRIPT_DIR/bin"

case "${1:-}" in
    init)   "$BIN/init-language.sh"         "${@:2}" ;;
    sync)   "$BIN/sync-gge-key.sh"          "${@:2}" ;;
    check)  "$BIN/check-translations.sh"             ;;
    sort)   "$BIN/sort-keys.sh"                      ;;
    *)
        echo "Usage: $(basename "$0") {init|sync|check|sort}"
        echo "Run 'bash tools/i18n.sh <command>' with no arguments for per-command help."
        exit 1
        ;;
esac
