#!/usr/bin/env bash
# Create a content idea manually
# Usage: bash create-content-idea.sh --offering-id offr_abc123 --campaign-id camp_def456 --title "My Idea" [--concept "..."] [--hook-angle "..."] [--slide-content 'JSON'] [--generated-content 'JSON']

source "$(dirname "$0")/api.sh"

OFFERING_ID=""
CAMPAIGN_ID=""
TITLE=""
CONCEPT=""
HOOK_ANGLE=""
SLIDE_CONTENT=""
GENERATED_CONTENT=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --offering-id) OFFERING_ID="$2"; shift 2 ;;
    --campaign-id) CAMPAIGN_ID="$2"; shift 2 ;;
    --title) TITLE="$2"; shift 2 ;;
    --concept) CONCEPT="$2"; shift 2 ;;
    --hook-angle) HOOK_ANGLE="$2"; shift 2 ;;
    --slide-content) SLIDE_CONTENT="$2"; shift 2 ;;
    --generated-content) GENERATED_CONTENT="$2"; shift 2 ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

if [[ -z "$OFFERING_ID" || -z "$CAMPAIGN_ID" || -z "$TITLE" ]]; then
  echo "Error: --offering-id, --campaign-id, and --title are required" >&2
  exit 1
fi

BODY=$(jq -n --arg title "$TITLE" '{content_idea: {title: $title}}')

if [[ -n "$CONCEPT" ]]; then
  BODY=$(echo "$BODY" | jq --arg v "$CONCEPT" '.content_idea.concept = $v')
fi
if [[ -n "$HOOK_ANGLE" ]]; then
  BODY=$(echo "$BODY" | jq --arg v "$HOOK_ANGLE" '.content_idea.hook_angle = $v')
fi
if [[ -n "$SLIDE_CONTENT" ]]; then
  BODY=$(echo "$BODY" | jq --argjson v "$SLIDE_CONTENT" '.content_idea.slide_content = $v')
fi
if [[ -n "$GENERATED_CONTENT" ]]; then
  BODY=$(echo "$BODY" | jq --argjson v "$GENERATED_CONTENT" '.content_idea.generated_content = $v')
fi

response=""
if ! response=$(api_post "/offerings/${OFFERING_ID}/campaigns/${CAMPAIGN_ID}/content_ideas" "$BODY"); then
  exit 1
fi

echo "$response" | jq '.result'
