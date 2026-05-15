#!/usr/bin/env bash
# Update a niche discovery
# Usage: bash update-niche-discovery.sh --offering-id offr_abc123 --campaign-id camp_def456 --id ndsc_ghi789 [--name "..."] [--interval-hours 24] [--auto-reimagine true|false] [--auto-reimagine-limit 5]

source "$(dirname "$0")/api.sh"

OFFERING_ID=""
CAMPAIGN_ID=""
ID=""
NAME=""
INTERVAL_HOURS=""
AUTO_REIMAGINE=""
AUTO_REIMAGINE_LIMIT=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --offering-id) OFFERING_ID="$2"; shift 2 ;;
    --campaign-id) CAMPAIGN_ID="$2"; shift 2 ;;
    --id) ID="$2"; shift 2 ;;
    --name) NAME="$2"; shift 2 ;;
    --interval-hours) INTERVAL_HOURS="$2"; shift 2 ;;
    --auto-reimagine) AUTO_REIMAGINE="$2"; shift 2 ;;
    --auto-reimagine-limit) AUTO_REIMAGINE_LIMIT="$2"; shift 2 ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

if [[ -z "$OFFERING_ID" || -z "$CAMPAIGN_ID" || -z "$ID" ]]; then
  echo "Error: --offering-id, --campaign-id, and --id are required" >&2
  exit 1
fi

BODY='{"niche_discovery":{}}'

if [[ -n "$NAME" ]]; then
  BODY=$(echo "$BODY" | jq --arg v "$NAME" '.niche_discovery.name = $v')
fi
if [[ -n "$INTERVAL_HOURS" ]]; then
  BODY=$(echo "$BODY" | jq --argjson v "$INTERVAL_HOURS" '.niche_discovery.interval_hours = $v')
fi
if [[ -n "$AUTO_REIMAGINE" ]]; then
  BODY=$(echo "$BODY" | jq --argjson v "$AUTO_REIMAGINE" '.niche_discovery.auto_reimagine = $v')
fi
if [[ -n "$AUTO_REIMAGINE_LIMIT" ]]; then
  BODY=$(echo "$BODY" | jq --argjson v "$AUTO_REIMAGINE_LIMIT" '.niche_discovery.auto_reimagine_limit = $v')
fi

response=""
if ! response=$(api_patch "/offerings/${OFFERING_ID}/campaigns/${CAMPAIGN_ID}/niche_discoveries/${ID}" "$BODY"); then
  exit 1
fi

echo "$response" | jq '.result'
