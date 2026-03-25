#!/usr/bin/env bash
# Get a single content idea
# Usage: bash get-content-idea.sh --offering-id offr_abc123 --campaign-id camp_def456 --id idea_ghi789

source "$(dirname "$0")/api.sh"

OFFERING_ID=""
CAMPAIGN_ID=""
ID=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --offering-id) OFFERING_ID="$2"; shift 2 ;;
    --campaign-id) CAMPAIGN_ID="$2"; shift 2 ;;
    --id) ID="$2"; shift 2 ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

if [[ -z "$OFFERING_ID" || -z "$CAMPAIGN_ID" || -z "$ID" ]]; then
  echo "Error: --offering-id, --campaign-id, and --id are required" >&2
  exit 1
fi

response=""
if ! response=$(api_get "/offerings/${OFFERING_ID}/campaigns/${CAMPAIGN_ID}/content_ideas/${ID}"); then
  exit 1
fi

echo "$response" | jq '.result'
