#!/usr/bin/env bash
# Create a new campaign
# Usage: bash create-campaign.sh --offering-id offr_abc123 --name "My Campaign" [--description "..."] [--goal engagement|brand_awareness|traffic|sales] [--brief "..."] [--template-id tmpl_abc123]

source "$(dirname "$0")/api.sh"

OFFERING_ID=""
NAME=""
DESCRIPTION=""
GOAL=""
BRIEF=""
TEMPLATE_ID=""
STYLE_IDS=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --offering-id) OFFERING_ID="$2"; shift 2 ;;
    --name) NAME="$2"; shift 2 ;;
    --description) DESCRIPTION="$2"; shift 2 ;;
    --goal) GOAL="$2"; shift 2 ;;
    --brief) BRIEF="$2"; shift 2 ;;
    --template-id) TEMPLATE_ID="$2"; shift 2 ;;
    --style-ids) STYLE_IDS="$2"; shift 2 ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

if [[ -z "$OFFERING_ID" || -z "$NAME" ]]; then
  echo "Error: --offering-id and --name are required" >&2
  exit 1
fi

# Build JSON body
BODY=$(jq -n --arg name "$NAME" '{campaign: {name: $name}}')

if [[ -n "$DESCRIPTION" ]]; then
  BODY=$(echo "$BODY" | jq --arg v "$DESCRIPTION" '.campaign.description = $v')
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
if ! response=$(api_post "/offerings/${OFFERING_ID}/campaigns" "$BODY"); then
  exit 1
fi

echo "$response" | jq '.result'
