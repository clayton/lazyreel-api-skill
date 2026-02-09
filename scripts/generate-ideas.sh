#!/usr/bin/env bash
# Generate content ideas for a campaign (async)
# Usage: bash generate-ideas.sh --offering-id offr_abc123 --id camp_def456 [--count 5]

source "$(dirname "$0")/api.sh"

OFFERING_ID=""
ID=""
COUNT=5

while [[ $# -gt 0 ]]; do
  case "$1" in
    --offering-id) OFFERING_ID="$2"; shift 2 ;;
    --id) ID="$2"; shift 2 ;;
    --count) COUNT="$2"; shift 2 ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

if [[ -z "$OFFERING_ID" || -z "$ID" ]]; then
  echo "Error: --offering-id and --id are required" >&2
  exit 1
fi

BODY=$(jq -n --argjson count "$COUNT" '{count: $count}')

response=""
if ! response=$(api_post "/offerings/${OFFERING_ID}/campaigns/${ID}/generate_ideas" "$BODY"); then
  exit 1
fi

echo "$response" | jq '.'
