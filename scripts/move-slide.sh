#!/usr/bin/env bash
# Move a slide within a creative
# Usage: bash move-slide.sh --offering-id offr_abc123 --campaign-id camp_def456 --creative-id crtv_ghi789 --id slde_jkl012 --direction top|up|down|bottom

source "$(dirname "$0")/api.sh"

OFFERING_ID=""
CAMPAIGN_ID=""
CREATIVE_ID=""
ID=""
DIRECTION=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --offering-id) OFFERING_ID="$2"; shift 2 ;;
    --campaign-id) CAMPAIGN_ID="$2"; shift 2 ;;
    --creative-id) CREATIVE_ID="$2"; shift 2 ;;
    --id) ID="$2"; shift 2 ;;
    --direction) DIRECTION="$2"; shift 2 ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

if [[ -z "$OFFERING_ID" || -z "$CAMPAIGN_ID" || -z "$CREATIVE_ID" || -z "$ID" || -z "$DIRECTION" ]]; then
  echo "Error: --offering-id, --campaign-id, --creative-id, --id, and --direction are required" >&2
  exit 1
fi

BODY=$(jq -n --arg dir "$DIRECTION" '{direction: $dir}')

response=""
if ! response=$(api_post "/offerings/${OFFERING_ID}/campaigns/${CAMPAIGN_ID}/creatives/${CREATIVE_ID}/slides/${ID}/move" "$BODY"); then
  exit 1
fi

echo "$response" | jq '.result'
