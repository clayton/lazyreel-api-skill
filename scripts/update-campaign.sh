#!/usr/bin/env bash
# Update a campaign
# Usage: bash update-campaign.sh --offering-id offr_abc123 --id camp_def456 [--name "..."] [--status draft|active|paused] [--goal ...] [--brief "..."]

source "$(dirname "$0")/api.sh"

OFFERING_ID=""
ID=""
NAME=""
DESCRIPTION=""
STATUS=""
GOAL=""
BRIEF=""
TEMPLATE_ID=""
STYLE_IDS=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --offering-id) OFFERING_ID="$2"; shift 2 ;;
    --id) ID="$2"; shift 2 ;;
    --name) NAME="$2"; shift 2 ;;
    --description) DESCRIPTION="$2"; shift 2 ;;
    --status) STATUS="$2"; shift 2 ;;
    --goal) GOAL="$2"; shift 2 ;;
    --brief) BRIEF="$2"; shift 2 ;;
    --template-id) TEMPLATE_ID="$2"; shift 2 ;;
    --style-ids) STYLE_IDS="$2"; shift 2 ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

if [[ -z "$OFFERING_ID" || -z "$ID" ]]; then
  echo "Error: --offering-id and --id are required" >&2
  exit 1
fi

BODY='{"campaign":{}}'

if [[ -n "$NAME" ]]; then
  BODY=$(echo "$BODY" | jq --arg v "$NAME" '.campaign.name = $v')
fi
if [[ -n "$DESCRIPTION" ]]; then
  BODY=$(echo "$BODY" | jq --arg v "$DESCRIPTION" '.campaign.description = $v')
fi
if [[ -n "$STATUS" ]]; then
  BODY=$(echo "$BODY" | jq --arg v "$STATUS" '.campaign.status = $v')
fi
if [[ -n "$GOAL" ]]; then
  BODY=$(echo "$BODY" | jq --arg v "$GOAL" '.campaign.campaign_goal = $v')
fi
if [[ -n "$BRIEF" ]]; then
  BODY=$(echo "$BODY" | jq --arg v "$BRIEF" '.campaign.content_brief = $v')
fi
if [[ -n "$TEMPLATE_ID" ]]; then
  BODY=$(echo "$BODY" | jq --arg v "$TEMPLATE_ID" '.campaign.creative_template_id = $v')
fi
if [[ -n "$STYLE_IDS" ]]; then
  BODY=$(echo "$BODY" | jq --arg v "$STYLE_IDS" '.campaign.artwork_style_ids = ($v | split(","))')
fi

response=""
if ! response=$(api_patch "/offerings/${OFFERING_ID}/campaigns/${ID}" "$BODY"); then
  exit 1
fi

echo "$response" | jq '.data'
