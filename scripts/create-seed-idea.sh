#!/usr/bin/env bash
# Create a seed idea for a campaign
# Usage: bash create-seed-idea.sh --offering-id offr_abc123 --campaign-id camp_def456 --topic "How to..." [--content "..."] [--category "..."] [--position N] [--status active|used|archived]

source "$(dirname "$0")/api.sh"

OFFERING_ID=""
CAMPAIGN_ID=""
TOPIC=""
CONTENT=""
CATEGORY=""
POSITION=""
STATUS=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --offering-id) OFFERING_ID="$2"; shift 2 ;;
    --campaign-id) CAMPAIGN_ID="$2"; shift 2 ;;
    --topic) TOPIC="$2"; shift 2 ;;
    --content) CONTENT="$2"; shift 2 ;;
    --category) CATEGORY="$2"; shift 2 ;;
    --position) POSITION="$2"; shift 2 ;;
    --status) STATUS="$2"; shift 2 ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

if [[ -z "$OFFERING_ID" || -z "$CAMPAIGN_ID" || -z "$TOPIC" ]]; then
  echo "Error: --offering-id, --campaign-id, and --topic are required" >&2
  exit 1
fi

BODY=$(jq -n --arg topic "$TOPIC" '{seed_idea: {topic: $topic}}')

if [[ -n "$CONTENT" ]]; then
  BODY=$(echo "$BODY" | jq --arg v "$CONTENT" '.seed_idea.content = $v')
fi
if [[ -n "$CATEGORY" ]]; then
  BODY=$(echo "$BODY" | jq --arg v "$CATEGORY" '.seed_idea.category = $v')
fi
if [[ -n "$POSITION" ]]; then
  BODY=$(echo "$BODY" | jq --argjson v "$POSITION" '.seed_idea.position = $v')
fi
if [[ -n "$STATUS" ]]; then
  BODY=$(echo "$BODY" | jq --arg v "$STATUS" '.seed_idea.status = $v')
fi

response=""
if ! response=$(api_post "/offerings/${OFFERING_ID}/campaigns/${CAMPAIGN_ID}/seed_ideas" "$BODY"); then
  exit 1
fi

echo "$response" | jq '.result'
