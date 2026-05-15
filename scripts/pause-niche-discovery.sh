#!/usr/bin/env bash
# Pause or resume a niche discovery
# Usage: bash pause-niche-discovery.sh --offering-id offr_abc123 --campaign-id camp_def456 --id ndsc_ghi789 [--resume]

source "$(dirname "$0")/api.sh"

OFFERING_ID=""
CAMPAIGN_ID=""
ID=""
ACTION="pause"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --offering-id) OFFERING_ID="$2"; shift 2 ;;
    --campaign-id) CAMPAIGN_ID="$2"; shift 2 ;;
    --id) ID="$2"; shift 2 ;;
    --resume) ACTION="resume"; shift ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

if [[ -z "$OFFERING_ID" || -z "$CAMPAIGN_ID" || -z "$ID" ]]; then
  echo "Error: --offering-id, --campaign-id, and --id are required" >&2
  exit 1
fi

response=""
if ! response=$(api_post "/offerings/${OFFERING_ID}/campaigns/${CAMPAIGN_ID}/niche_discoveries/${ID}/${ACTION}"); then
  exit 1
fi

echo "$response" | jq '.result'
