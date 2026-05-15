#!/usr/bin/env bash
# Create a new offering
# Usage: bash create-offering.sh --name "My Product" [--description "..."] [--target-audience "..."] [--differentiator "..."] [--tone-voice "..."] [--brand-promise "..."] [--content-aesthetic "..."] [--english-dialect "..."]

source "$(dirname "$0")/api.sh"

NAME=""
DESCRIPTION=""
TARGET_AUDIENCE=""
DIFFERENTIATOR=""
TONE_VOICE=""
BRAND_PROMISE=""
CONTENT_AESTHETIC=""
ENGLISH_DIALECT=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --name) NAME="$2"; shift 2 ;;
    --description) DESCRIPTION="$2"; shift 2 ;;
    --target-audience) TARGET_AUDIENCE="$2"; shift 2 ;;
    --differentiator) DIFFERENTIATOR="$2"; shift 2 ;;
    --tone-voice) TONE_VOICE="$2"; shift 2 ;;
    --brand-promise) BRAND_PROMISE="$2"; shift 2 ;;
    --content-aesthetic) CONTENT_AESTHETIC="$2"; shift 2 ;;
    --english-dialect) ENGLISH_DIALECT="$2"; shift 2 ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

if [[ -z "$NAME" ]]; then
  echo "Error: --name is required" >&2
  exit 1
fi

BODY=$(jq -n --arg name "$NAME" '{offering: {name: $name}}')

if [[ -n "$DESCRIPTION" ]]; then
  BODY=$(echo "$BODY" | jq --arg v "$DESCRIPTION" '.offering.description = $v')
fi
if [[ -n "$TARGET_AUDIENCE" ]]; then
  BODY=$(echo "$BODY" | jq --arg v "$TARGET_AUDIENCE" '.offering.target_audience = $v')
fi
if [[ -n "$DIFFERENTIATOR" ]]; then
  BODY=$(echo "$BODY" | jq --arg v "$DIFFERENTIATOR" '.offering.differentiator = $v')
fi
if [[ -n "$TONE_VOICE" ]]; then
  BODY=$(echo "$BODY" | jq --arg v "$TONE_VOICE" '.offering.tone_voice = $v')
fi
if [[ -n "$BRAND_PROMISE" ]]; then
  BODY=$(echo "$BODY" | jq --arg v "$BRAND_PROMISE" '.offering.brand_promise = $v')
fi
if [[ -n "$CONTENT_AESTHETIC" ]]; then
  BODY=$(echo "$BODY" | jq --arg v "$CONTENT_AESTHETIC" '.offering.content_aesthetic = $v')
fi
if [[ -n "$ENGLISH_DIALECT" ]]; then
  BODY=$(echo "$BODY" | jq --arg v "$ENGLISH_DIALECT" '.offering.english_dialect = $v')
fi

response=""
if ! response=$(api_post "/offerings" "$BODY"); then
  exit 1
fi

echo "$response" | jq '.result'
