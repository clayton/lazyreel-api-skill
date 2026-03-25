#!/usr/bin/env bash
# Update a slide
# Usage: bash update-slide.sh --offering-id offr_abc123 --campaign-id camp_def456 --creative-id crtv_ghi789 --id slde_jkl012 [--position N] [--duration N] [--type hook|content|cta|...] [--hidden true|false] [--visual-prompt "..."] [--style-id arts_abc]

source "$(dirname "$0")/api.sh"

OFFERING_ID=""
CAMPAIGN_ID=""
CREATIVE_ID=""
ID=""
POSITION=""
DURATION=""
SLIDE_TYPE=""
HIDDEN=""
VISUAL_PROMPT=""
STYLE_ID=""
TEXT_ELEMENTS_JSON=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --offering-id) OFFERING_ID="$2"; shift 2 ;;
    --campaign-id) CAMPAIGN_ID="$2"; shift 2 ;;
    --creative-id) CREATIVE_ID="$2"; shift 2 ;;
    --id) ID="$2"; shift 2 ;;
    --position) POSITION="$2"; shift 2 ;;
    --duration) DURATION="$2"; shift 2 ;;
    --type) SLIDE_TYPE="$2"; shift 2 ;;
    --hidden) HIDDEN="$2"; shift 2 ;;
    --visual-prompt) VISUAL_PROMPT="$2"; shift 2 ;;
    --style-id) STYLE_ID="$2"; shift 2 ;;
    --text-elements) TEXT_ELEMENTS_JSON="$2"; shift 2 ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

if [[ -z "$OFFERING_ID" || -z "$CAMPAIGN_ID" || -z "$CREATIVE_ID" || -z "$ID" ]]; then
  echo "Error: --offering-id, --campaign-id, --creative-id, and --id are required" >&2
  exit 1
fi

BODY='{"slide":{}}'

if [[ -n "$POSITION" ]]; then
  BODY=$(echo "$BODY" | jq --argjson v "$POSITION" '.slide.position = $v')
fi
if [[ -n "$DURATION" ]]; then
  BODY=$(echo "$BODY" | jq --argjson v "$DURATION" '.slide.duration = $v')
fi
if [[ -n "$SLIDE_TYPE" ]]; then
  BODY=$(echo "$BODY" | jq --arg v "$SLIDE_TYPE" '.slide.slide_type = $v')
fi
if [[ -n "$HIDDEN" ]]; then
  BODY=$(echo "$BODY" | jq --argjson v "$HIDDEN" '.slide.hidden = $v')
fi
if [[ -n "$VISUAL_PROMPT" ]]; then
  BODY=$(echo "$BODY" | jq --arg v "$VISUAL_PROMPT" '.slide.visual_prompt = $v')
fi
if [[ -n "$STYLE_ID" ]]; then
  BODY=$(echo "$BODY" | jq --arg v "$STYLE_ID" '.slide.artwork_style_id = $v')
fi
if [[ -n "$TEXT_ELEMENTS_JSON" ]]; then
  BODY=$(echo "$BODY" | jq --argjson v "$TEXT_ELEMENTS_JSON" '.slide.text_elements = $v')
fi

response=""
if ! response=$(api_patch "/offerings/${OFFERING_ID}/campaigns/${CAMPAIGN_ID}/creatives/${CREATIVE_ID}/slides/${ID}" "$BODY"); then
  exit 1
fi

echo "$response" | jq '.result'
