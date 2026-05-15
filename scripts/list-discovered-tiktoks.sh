#!/usr/bin/env bash
# List discovered TikToks for a niche discovery
# Usage: bash list-discovered-tiktoks.sh --offering-id offr_abc123 --campaign-id camp_def456 --niche-discovery-id ndsc_ghi789 [--status pending|analyzed|reimagined|dismissed]

source "$(dirname "$0")/api.sh"

OFFERING_ID=""
CAMPAIGN_ID=""
NICHE_DISCOVERY_ID=""
STATUS=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --offering-id) OFFERING_ID="$2"; shift 2 ;;
    --campaign-id) CAMPAIGN_ID="$2"; shift 2 ;;
    --niche-discovery-id) NICHE_DISCOVERY_ID="$2"; shift 2 ;;
    --status) STATUS="$2"; shift 2 ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

if [[ -z "$OFFERING_ID" || -z "$CAMPAIGN_ID" || -z "$NICHE_DISCOVERY_ID" ]]; then
  echo "Error: --offering-id, --campaign-id, and --niche-discovery-id are required" >&2
  exit 1
fi

QUERY=""
if [[ -n "$STATUS" ]]; then
  QUERY="status=${STATUS}"
fi

response=""
if ! response=$(api_get "/offerings/${OFFERING_ID}/campaigns/${CAMPAIGN_ID}/niche_discoveries/${NICHE_DISCOVERY_ID}/discovered_tiktoks" "$QUERY"); then
  exit 1
fi

echo "$response" | jq -r '
  (["ID", "Username", "Views", "Likes", "Status", "Hook"],
   ["--", "--------", "-----", "-----", "------", "----"],
   (.result[] |
     [
       .id,
       (.username // "-"),
       (.view_count // 0 | tostring),
       (.like_count // 0 | tostring),
       .status,
       (.hook // "-" | if length > 40 then .[:40] + "..." else . end)
     ]
   )
   | @tsv)
' | column -t -s $'\t'
