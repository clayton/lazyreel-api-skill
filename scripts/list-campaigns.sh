#!/usr/bin/env bash
# List campaigns for an offering
# Usage: bash list-campaigns.sh --offering-id offr_abc123 [--status draft|active|paused] [--archived] [--page N] [--per-page N]

source "$(dirname "$0")/api.sh"

OFFERING_ID=""
STATUS=""
ARCHIVED="false"
PAGE=1
PER_PAGE=25

while [[ $# -gt 0 ]]; do
  case "$1" in
    --offering-id) OFFERING_ID="$2"; shift 2 ;;
    --status) STATUS="$2"; shift 2 ;;
    --archived) ARCHIVED="true"; shift ;;
    --page) PAGE="$2"; shift 2 ;;
    --per-page) PER_PAGE="$2"; shift 2 ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

if [[ -z "$OFFERING_ID" ]]; then
  echo "Error: --offering-id is required" >&2
  exit 1
fi

QUERY="page=${PAGE}&per_page=${PER_PAGE}&archived=${ARCHIVED}"
if [[ -n "$STATUS" ]]; then
  QUERY="${QUERY}&status=${STATUS}"
fi

response=""
if ! response=$(api_get "/offerings/${OFFERING_ID}/campaigns" "$QUERY"); then
  exit 1
fi

echo "$response" | jq -r '
  "Campaigns (page \(.meta.current_page // 1) of \(.meta.total_pages // 1), \(.meta.total_count // 0) total)\n",
  (["ID", "Name", "Status", "Goal", "Archived"],
   ["--", "----", "------", "----", "--------"],
   (.data[] |
     [
       .id,
       (.name // "-" | if length > 40 then .[:40] + "..." else . end),
       .status,
       .campaign_goal,
       (.archived | tostring)
     ]
   )
   | @tsv)
' | column -t -s $'\t'
