#!/usr/bin/env bash
# =============================================================================
# gge-api.sh - Resolve the current GGE language pack version
#
# Fetches the active version identifier from the GGE CDN and exports it as
# GGE_XML_VERSION, which other scripts use to construct language file URLs.
#
# Exported variables:
#   GGE_XML_VERSION   Version string for the current GGE language pack
#                     (e.g. "1.0.523")
#
# Usage:
#   . "$SCRIPT_DIR/../lib/gge-api.sh"
#   echo "Base URL: https://empire-html5.goodgamestudios.com/config/languages/$GGE_XML_VERSION"
#
# Requirements: curl, jq
# =============================================================================

GGE_XML_VERSION=$(curl -s https://empire-html5.goodgamestudios.com/config/languages/version.json)
GGE_XML_VERSION=$(echo "$GGE_XML_VERSION" | jq -r '.languages.en')
export GGE_XML_VERSION
