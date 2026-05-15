#!/usr/bin/env bash
# Create a new slide for a creative
# Usage: bash create-slide.sh --offering-id offr_abc123 --campaign-id camp_def456 --creative-id crtv_ghi789 [--type hook|content|cta|app_plug|problem|solution]

source "$(dirname "$0")/api.sh"

OFFERING_ID=""
CAMPAIGN_ID=""
CREATIVE_ID=""
SLIDE_TYPE=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --offering-id) OFFERING_ID="$2"; shift 2 ;;
    --campaign-id) CAMPAIGN_ID="$2"; shift 2 ;;
    --creative-id) CREATIVE_ID="$2"; shift 2 ;;
    --type) SLIDE_TYPE="$2"; shift 2 ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

if [[ -z "$OFFERING_ID" || -z "$CAMPAIGN_ID" || -z "$CREATIVE_ID" ]]; then
  echo "Error: --offering-id, --campaign-id, and --creative-id are required" >&2
  exit 1
fi

BODY='{"slide":{}}'

if [[ -n "$SLIDE_TYPE" ]]; then
  BODY=$(echo "$BODY" | jq --arg v "$SLIDE_TYPE" '.slide.slide_type = $v')
fi

response=""
if ! response=$(api_post "/offerings/${OFFERING_ID}/campaigns/${CAMPAIGN_ID}/creatives/${CREATIVE_ID}/slides" "$BODY"); then
  exit 1
fi

echo "$response" | jq '.result'
