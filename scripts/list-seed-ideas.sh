#!/usr/bin/env bash
# List seed ideas for a campaign
# Usage: bash list-seed-ideas.sh --offering-id offr_abc123 --campaign-id camp_def456 [--status active|used|archived]

source "$(dirname "$0")/api.sh"

OFFERING_ID=""
CAMPAIGN_ID=""
STATUS=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --offering-id) OFFERING_ID="$2"; shift 2 ;;
    --campaign-id) CAMPAIGN_ID="$2"; shift 2 ;;
    --status) STATUS="$2"; shift 2 ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

if [[ -z "$OFFERING_ID" || -z "$CAMPAIGN_ID" ]]; then
  echo "Error: --offering-id and --campaign-id are required" >&2
  exit 1
fi

QUERY=""
if [[ -n "$STATUS" ]]; then
  QUERY="status=${STATUS}"
fi

response=""
if ! response=$(api_get "/offerings/${OFFERING_ID}/campaigns/${CAMPAIGN_ID}/seed_ideas" "$QUERY"); then
  exit 1
fi

echo "$response" | jq -r '
  (["ID", "Topic", "Category", "Position", "Status", "Score"],
   ["--", "-----", "--------", "--------", "------", "-----"],
   (.result[] |
     [
       .id,
       (.topic // "-" | if length > 30 then .[:30] + "..." else . end),
       (.category // "-"),
       (.position // 0 | tostring),
       .status,
       (.score // 0 | tostring)
     ]
   )
   | @tsv)
' | column -t -s $'\t'
