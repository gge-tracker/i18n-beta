# =============================================================================
# colors.sh - ANSI colour constants for terminal output
#
# Source this file to get named colour variables for use in `echo -e` strings.
#
# Usage:
#   . "$SCRIPT_DIR/../lib/colors.sh"
#   echo -e "${green_color}Success${reset_color}"
#   echo -e "${red_color}Error${reset_color}"
# =============================================================================

readonly red_color='\033[0;31m'
readonly green_color='\033[0;32m'
readonly yellow_color='\033[0;33m'
readonly reset_color='\033[0m'
