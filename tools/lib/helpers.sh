# =============================================================================
# helpers.sh - Shared helper functions for the i18n toolchain
#
# Provides:
#   print_header     Print the GGE Tracker ASCII-art banner to stdout.
#   extract_keys     Emit a sorted list of all dot-notation key paths in a JSON file.
#
# Usage:
#   . "$SCRIPT_DIR/../lib/helpers.sh"
#
#   # Print the banner
#   print_header
#
#   # List all keys in a file
#   extract_keys fr.json
# =============================================================================

print_header() {
  echo -e " [34m
                                                __                        __
                ____   ____   ____           _/  |_____________    ____ |  | __ ___________
                / ___\\ / ___\\_/ __ \\   ______ \\   __\\_  __ \\__  \\ _/ ___\\|  |/ // __ \\_  __ \\
              / /_/  > /_/  >  ___/  /_____/  |  |  |  | \\// __ \\\\  \\___|    <\\  ___/|  | \\/
              \\___  /\\___  / \\___  >          |__|  |__|  (____  /\\___  >__|_ \\\\___  >__|
              /_____//_____/      \\/                            \\/     \\/     \\/    \\/

                                    GGE Tracker i18n Checker v1.0
  [0m"
}

extract_keys() {
  jq -r '
    paths(scalars)
    | map(tostring)
    | join(".")
  ' "$1" | sort
}
