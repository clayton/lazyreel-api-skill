#!/usr/bin/env bash
# List CTA variants for an offering
# Usage: bash list-cta-variants.sh --offering-id offr_abc123 [--status active|winner|retired]

source "$(dirname "$0")/api.sh"

OFFERING_ID=""
STATUS=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --offering-id) OFFERING_ID="$2"; shift 2 ;;
    --status) STATUS="$2"; shift 2 ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

if [[ -z "$OFFERING_ID" ]]; then
  echo "Error: --offering-id is required" >&2
  exit 1
fi

QUERY=""
[[ -n "$STATUS" ]] && QUERY="status=$STATUS"

response=""
if ! response=$(api_get "/offerings/$OFFERING_ID/cta_variants" "$QUERY"); then
  exit 1
fi

echo "$response" | jq -r '
  "CTA Variants (\(.result | length) variants)\n",
  (["ID", "CTA Text", "Views", "Conversions", "Rate", "Status"],
   ["--", "--------", "-----", "-----------", "----", "------"],
   (.result[] |
     [
       .id,
       (.cta_text | if length > 50 then .[:50] + "..." else . end),
       (.view_count | tostring),
       (.conversion_count | tostring),
       ((.conversion_rate // 0) | tostring) + "%",
       .status
     ]
   )
   | @tsv)
' | column -t -s $'\t'
