#!/usr/bin/env bash
# Get a single discovered TikTok
# Usage: bash get-discovered-tiktok.sh --offering-id offr_abc123 --campaign-id camp_def456 --niche-discovery-id ndsc_ghi789 --id dtkt_jkl012

source "$(dirname "$0")/api.sh"

OFFERING_ID=""
CAMPAIGN_ID=""
NICHE_DISCOVERY_ID=""
ID=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --offering-id) OFFERING_ID="$2"; shift 2 ;;
    --campaign-id) CAMPAIGN_ID="$2"; shift 2 ;;
    --niche-discovery-id) NICHE_DISCOVERY_ID="$2"; shift 2 ;;
    --id) ID="$2"; shift 2 ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

if [[ -z "$OFFERING_ID" || -z "$CAMPAIGN_ID" || -z "$NICHE_DISCOVERY_ID" || -z "$ID" ]]; then
  echo "Error: --offering-id, --campaign-id, --niche-discovery-id, and --id are required" >&2
  exit 1
fi

response=""
if ! response=$(api_get "/offerings/${OFFERING_ID}/campaigns/${CAMPAIGN_ID}/niche_discoveries/${NICHE_DISCOVERY_ID}/discovered_tiktoks/${ID}"); then
  exit 1
fi

echo "$response" | jq '.result'
