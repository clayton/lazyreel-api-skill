#!/usr/bin/env bash
# Ingest a TikTok by URL for analysis and reimagining
# Usage: bash ingest-tiktok.sh --url "https://www.tiktok.com/@user/video/123" [--offering-id offr_abc123] [--campaign-id camp_def456]

source "$(dirname "$0")/api.sh"

URL=""
OFFERING_ID=""
CAMPAIGN_ID=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --url) URL="$2"; shift 2 ;;
    --offering-id) OFFERING_ID="$2"; shift 2 ;;
    --campaign-id) CAMPAIGN_ID="$2"; shift 2 ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

if [[ -z "$URL" ]]; then
  echo "Error: --url is required" >&2
  exit 1
fi

BODY=$(jq -n --arg url "$URL" '{url: $url}')

if [[ -n "$OFFERING_ID" ]]; then
  BODY=$(echo "$BODY" | jq --arg v "$OFFERING_ID" '.offering_id = $v')
fi
if [[ -n "$CAMPAIGN_ID" ]]; then
  BODY=$(echo "$BODY" | jq --arg v "$CAMPAIGN_ID" '.campaign_id = $v')
fi

response=""
if ! response=$(api_post "/discovered_tiktoks/ingest" "$BODY"); then
  exit 1
fi

echo "$response" | jq '.'
