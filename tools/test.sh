#!/bin/bash
set -euo pipefail

A="ar.json"
B="ar2.json"

tmp="$(mktemp)"

jq --argfile b "$B" '
def getb($p):
  try ($b | getpath($p)) catch null;

reduce paths(strings) as $p (.;
  if (getpath($p) == "") then
    (getb($p)) as $val
    | if $val != null then setpath($p; $val) else . end
  else .
  end
)
' "$A" > "$tmp"

mv "$tmp" "$A"