#!/usr/bin/env bash
# List niche discoveries for a campaign
# Usage: bash list-niche-discoveries.sh --offering-id offr_abc123 --campaign-id camp_def456

source "$(dirname "$0")/api.sh"

OFFERING_ID=""
CAMPAIGN_ID=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --offering-id) OFFERING_ID="$2"; shift 2 ;;
    --campaign-id) CAMPAIGN_ID="$2"; shift 2 ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

if [[ -z "$OFFERING_ID" || -z "$CAMPAIGN_ID" ]]; then
  echo "Error: --offering-id and --campaign-id are required" >&2
  exit 1
fi

response=""
if ! response=$(api_get "/offerings/${OFFERING_ID}/campaigns/${CAMPAIGN_ID}/niche_discoveries"); then
  exit 1
fi

echo "$response" | jq -r '
  (["ID", "Name", "Status", "Auto-Reimagine", "Discovered"],
   ["--", "----", "------", "--------------", "----------"],
   (.result[] |
     [
       .id,
       (.name // "-" | if length > 30 then .[:30] + "..." else . end),
       .status,
       (.auto_reimagine | tostring),
       (.discovered_tiktoks_count // 0 | tostring)
     ]
   )
   | @tsv)
' | column -t -s $'\t'
