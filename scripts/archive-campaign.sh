#!/usr/bin/env bash
# Archive or unarchive a campaign
# Usage: bash archive-campaign.sh --offering-id offr_abc123 --id camp_def456 [--unarchive]

source "$(dirname "$0")/api.sh"

OFFERING_ID=""
ID=""
ACTION="archive"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --offering-id) OFFERING_ID="$2"; shift 2 ;;
    --id) ID="$2"; shift 2 ;;
    --unarchive) ACTION="unarchive"; shift ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

if [[ -z "$OFFERING_ID" || -z "$ID" ]]; then
  echo "Error: --offering-id and --id are required" >&2
  exit 1
fi

response=""
if ! response=$(api_post "/offerings/${OFFERING_ID}/campaigns/${ID}/${ACTION}"); then
  exit 1
fi

echo "$response" | jq '.data'
