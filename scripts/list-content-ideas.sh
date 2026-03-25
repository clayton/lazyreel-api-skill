#!/usr/bin/env bash
# List content ideas for a campaign
# Usage: bash list-content-ideas.sh --offering-id offr_abc123 --campaign-id camp_def456 [--status draft|approved|used|archived] [--page N] [--per-page N]

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
if ! response=$(api_get "/offerings/${OFFERING_ID}/campaigns/${CAMPAIGN_ID}/content_ideas" "$QUERY"); then
  exit 1
fi

echo "$response" | jq -r '
  "Content Ideas (page \(.meta.current_page // 1) of \(.meta.total_pages // 1), \(.meta.total_count // 0) total)\n",
  (["ID", "Title", "Status", "Hook", "Rejected"],
   ["--", "-----", "------", "----", "--------"],
   (.result[] |
     [
       .id,
       (.title // "-" | if length > 45 then .[:45] + "..." else . end),
       .status,
       (.hook_angle // "-"),
       (.rejected | tostring)
     ]
   )
   | @tsv)
' | column -t -s $'\t'
