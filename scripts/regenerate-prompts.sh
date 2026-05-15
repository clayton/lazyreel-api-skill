#!/usr/bin/env bash
# Regenerate visual prompts for a creative's slides
# Usage: bash regenerate-prompts.sh --offering-id offr_abc123 --campaign-id camp_def456 --id crtv_ghi789 --description "dark moody aesthetic"

source "$(dirname "$0")/api.sh"

OFFERING_ID=""
CAMPAIGN_ID=""
ID=""
DESCRIPTION=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --offering-id) OFFERING_ID="$2"; shift 2 ;;
    --campaign-id) CAMPAIGN_ID="$2"; shift 2 ;;
    --id) ID="$2"; shift 2 ;;
    --description) DESCRIPTION="$2"; shift 2 ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

if [[ -z "$OFFERING_ID" || -z "$CAMPAIGN_ID" || -z "$ID" || -z "$DESCRIPTION" ]]; then
  echo "Error: --offering-id, --campaign-id, --id, and --description are required" >&2
  exit 1
fi

BODY=$(jq -n --arg desc "$DESCRIPTION" '{prompt_description: $desc}')

response=""
if ! response=$(api_post "/offerings/${OFFERING_ID}/campaigns/${CAMPAIGN_ID}/creatives/${ID}/regenerate_prompts" "$BODY"); then
  exit 1
fi

echo "$response" | jq '.'
