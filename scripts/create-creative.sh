#!/usr/bin/env bash
# Create a new creative
# Usage: bash create-creative.sh --offering-id offr_abc123 --campaign-id camp_def456 [--name "..."] [--idea-id idea_abc] [--template-id tmpl_abc] [--style-id arts_abc] [--transition none|push_left]

source "$(dirname "$0")/api.sh"

OFFERING_ID=""
CAMPAIGN_ID=""
NAME=""
IDEA_ID=""
TEMPLATE_ID=""
STYLE_ID=""
TRANSITION=""
POST_TITLE=""
POST_DESC=""
POST_HASHTAGS=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --offering-id) OFFERING_ID="$2"; shift 2 ;;
    --campaign-id) CAMPAIGN_ID="$2"; shift 2 ;;
    --name) NAME="$2"; shift 2 ;;
    --idea-id) IDEA_ID="$2"; shift 2 ;;
    --template-id) TEMPLATE_ID="$2"; shift 2 ;;
    --style-id) STYLE_ID="$2"; shift 2 ;;
    --transition) TRANSITION="$2"; shift 2 ;;
    --post-title) POST_TITLE="$2"; shift 2 ;;
    --post-description) POST_DESC="$2"; shift 2 ;;
    --post-hashtags) POST_HASHTAGS="$2"; shift 2 ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

if [[ -z "$OFFERING_ID" || -z "$CAMPAIGN_ID" ]]; then
  echo "Error: --offering-id and --campaign-id are required" >&2
  exit 1
fi

BODY='{"creative":{}}'

if [[ -n "$NAME" ]]; then
  BODY=$(echo "$BODY" | jq --arg v "$NAME" '.creative.name = $v')
fi
if [[ -n "$IDEA_ID" ]]; then
  BODY=$(echo "$BODY" | jq --arg v "$IDEA_ID" '.creative.content_idea_id = $v')
fi
if [[ -n "$TEMPLATE_ID" ]]; then
  BODY=$(echo "$BODY" | jq --arg v "$TEMPLATE_ID" '.creative.creative_template_id = $v')
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
if ! response=$(api_post "/offerings/${OFFERING_ID}/campaigns/${CAMPAIGN_ID}/creatives" "$BODY"); then
  exit 1
fi

echo "$response" | jq '.result'
