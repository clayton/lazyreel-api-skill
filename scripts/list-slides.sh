#!/usr/bin/env bash
# List slides for a creative
# Usage: bash list-slides.sh --offering-id offr_abc123 --campaign-id camp_def456 --creative-id crtv_ghi789

source "$(dirname "$0")/api.sh"

OFFERING_ID=""
CAMPAIGN_ID=""
CREATIVE_ID=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --offering-id) OFFERING_ID="$2"; shift 2 ;;
    --campaign-id) CAMPAIGN_ID="$2"; shift 2 ;;
    --creative-id) CREATIVE_ID="$2"; shift 2 ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

if [[ -z "$OFFERING_ID" || -z "$CAMPAIGN_ID" || -z "$CREATIVE_ID" ]]; then
  echo "Error: --offering-id, --campaign-id, and --creative-id are required" >&2
  exit 1
fi

response=""
if ! response=$(api_get "/offerings/${OFFERING_ID}/campaigns/${CAMPAIGN_ID}/creatives/${CREATIVE_ID}/slides"); then
  exit 1
fi

echo "$response" | jq -r '
  (["ID", "Pos", "Type", "Duration", "Hidden", "Has Image"],
   ["--", "---", "----", "--------", "------", "---------"],
   (.data[] |
     [
       .id,
       (.position | tostring),
       .slide_type,
       (.duration | tostring),
       (.hidden | tostring),
       (.has_generated_image // .has_uploaded_image // false | tostring)
     ]
   )
   | @tsv)
' | column -t -s $'\t'
