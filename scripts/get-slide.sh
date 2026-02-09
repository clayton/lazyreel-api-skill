#!/usr/bin/env bash
# Get a single slide
# Usage: bash get-slide.sh --offering-id offr_abc123 --campaign-id camp_def456 --creative-id crtv_ghi789 --id slde_jkl012

source "$(dirname "$0")/api.sh"

OFFERING_ID=""
CAMPAIGN_ID=""
CREATIVE_ID=""
ID=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --offering-id) OFFERING_ID="$2"; shift 2 ;;
    --campaign-id) CAMPAIGN_ID="$2"; shift 2 ;;
    --creative-id) CREATIVE_ID="$2"; shift 2 ;;
    --id) ID="$2"; shift 2 ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

if [[ -z "$OFFERING_ID" || -z "$CAMPAIGN_ID" || -z "$CREATIVE_ID" || -z "$ID" ]]; then
  echo "Error: --offering-id, --campaign-id, --creative-id, and --id are required" >&2
  exit 1
fi

response=""
if ! response=$(api_get "/offerings/${OFFERING_ID}/campaigns/${CAMPAIGN_ID}/creatives/${CREATIVE_ID}/slides/${ID}"); then
  exit 1
fi

echo "$response" | jq '.data'
