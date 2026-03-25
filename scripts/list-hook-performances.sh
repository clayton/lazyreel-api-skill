#!/usr/bin/env bash
# List hook performances for an offering
# Usage: bash list-hook-performances.sh --offering-id offr_abc123 [--status double_down|keep|testing|try_variation|dropped] [--format-category question|listicle|insider|...] [--min-views 10000]

source "$(dirname "$0")/api.sh"

OFFERING_ID=""
STATUS=""
FORMAT_CAT=""
MIN_VIEWS=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --offering-id) OFFERING_ID="$2"; shift 2 ;;
    --status) STATUS="$2"; shift 2 ;;
    --format-category) FORMAT_CAT="$2"; shift 2 ;;
    --min-views) MIN_VIEWS="$2"; shift 2 ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

if [[ -z "$OFFERING_ID" ]]; then
  echo "Error: --offering-id is required" >&2
  exit 1
fi

QUERY=""
[[ -n "$STATUS" ]] && QUERY="${QUERY:+$QUERY&}decision_status=$STATUS"
[[ -n "$FORMAT_CAT" ]] && QUERY="${QUERY:+$QUERY&}format_category=$FORMAT_CAT"
[[ -n "$MIN_VIEWS" ]] && QUERY="${QUERY:+$QUERY&}min_views=$MIN_VIEWS"

response=""
if ! response=$(api_get "/offerings/$OFFERING_ID/hook_performances" "$QUERY"); then
  exit 1
fi

echo "$response" | jq -r '
  "Hook Performances (\(.result | length) hooks)\n",
  (["ID", "Hook Text", "Format", "Views", "Conversions", "Status"],
   ["--", "---------", "------", "-----", "-----------", "------"],
   (.result[] |
     [
       .id,
       (.hook_text | if length > 50 then .[:50] + "..." else . end),
       .format_category,
       (.view_count | tostring),
       (.conversion_count | tostring),
       .decision_status
     ]
   )
   | @tsv)
' | column -t -s $'\t'
