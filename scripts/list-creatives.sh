#!/usr/bin/env bash
# List creatives for a campaign
# Usage: bash list-creatives.sh --offering-id offr_abc123 --campaign-id camp_def456 [--status draft|pending|...] [--page N] [--per-page N]

source "$(dirname "$0")/api.sh"

OFFERING_ID=""
CAMPAIGN_ID=""
STATUS=""
PAGE=1
PER_PAGE=25

while [[ $# -gt 0 ]]; do
  case "$1" in
    --offering-id) OFFERING_ID="$2"; shift 2 ;;
    --campaign-id) CAMPAIGN_ID="$2"; shift 2 ;;
    --status) STATUS="$2"; shift 2 ;;
    --page) PAGE="$2"; shift 2 ;;
    --per-page) PER_PAGE="$2"; shift 2 ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

if [[ -z "$OFFERING_ID" || -z "$CAMPAIGN_ID" ]]; then
  echo "Error: --offering-id and --campaign-id are required" >&2
  exit 1
fi

QUERY="page=${PAGE}&per_page=${PER_PAGE}"
if [[ -n "$STATUS" ]]; then
  QUERY="${QUERY}&status=${STATUS}"
fi

response=""
if ! response=$(api_get "/offerings/${OFFERING_ID}/campaigns/${CAMPAIGN_ID}/creatives" "$QUERY"); then
  exit 1
fi

echo "$response" | jq -r '
  "Creatives (page \(.meta.current_page // 1) of \(.meta.total_pages // 1), \(.meta.total_count // 0) total)\n",
  (["ID", "Name", "Status", "Video", "Slides"],
   ["--", "----", "------", "-----", "------"],
   (.data[] |
     [
       .id,
       (.name // "-" | if length > 35 then .[:35] + "..." else . end),
       .status,
       (.video_status // "-"),
       (.slide_count // 0 | tostring)
     ]
   )
   | @tsv)
' | column -t -s $'\t'
