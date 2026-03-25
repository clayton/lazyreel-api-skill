#!/usr/bin/env bash
# Update a creative
# Usage: bash update-creative.sh --offering-id offr_abc123 --campaign-id camp_def456 --id crtv_ghi789 [--name "..."] [--style-id arts_abc] [--transition none|push_left] [--post-title "..."]

source "$(dirname "$0")/api.sh"

OFFERING_ID=""
CAMPAIGN_ID=""
ID=""
NAME=""
STYLE_ID=""
TRANSITION=""
POST_TITLE=""
POST_DESC=""
POST_HASHTAGS=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --offering-id) OFFERING_ID="$2"; shift 2 ;;
    --campaign-id) CAMPAIGN_ID="$2"; shift 2 ;;
    --id) ID="$2"; shift 2 ;;
    --name) NAME="$2"; shift 2 ;;
    --style-id) STYLE_ID="$2"; shift 2 ;;
    --transition) TRANSITION="$2"; shift 2 ;;
    --post-title) POST_TITLE="$2"; shift 2 ;;
    --post-description) POST_DESC="$2"; shift 2 ;;
    --post-hashtags) POST_HASHTAGS="$2"; shift 2 ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

if [[ -z "$OFFERING_ID" || -z "$CAMPAIGN_ID" || -z "$ID" ]]; then
  echo "Error: --offering-id, --campaign-id, and --id are required" >&2
  exit 1
fi

BODY='{"creative":{}}'

if [[ -n "$NAME" ]]; then
  BODY=$(echo "$BODY" | jq --arg v "$NAME" '.creative.name = $v')
fi
if [[ -n "$STYLE_ID" ]]; then
  BODY=$(echo "$BODY" | jq --arg v "$STYLE_ID" '.creative.artwork_style_id = $v')
fi
if [[ -n "$TRANSITION" ]]; then
  BODY=$(echo "$BODY" | jq --arg v "$TRANSITION" '.creative.transition_style = $v')
fi
if [[ -n "$POST_TITLE" ]]; then
  BODY=$(echo "$BODY" | jq --arg v "$POST_TITLE" '.creative.post_title = $v')
fi
if [[ -n "$POST_DESC" ]]; then
  BODY=$(echo "$BODY" | jq --arg v "$POST_DESC" '.creative.post_description = $v')
fi
if [[ -n "$POST_HASHTAGS" ]]; then
  BODY=$(echo "$BODY" | jq --arg v "$POST_HASHTAGS" '.creative.post_hashtags = $v')
fi

response=""
if ! response=$(api_patch "/offerings/${OFFERING_ID}/campaigns/${CAMPAIGN_ID}/creatives/${ID}" "$BODY"); then
  exit 1
fi

echo "$response" | jq '.result'
