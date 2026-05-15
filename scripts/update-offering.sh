#!/usr/bin/env bash
# Update an offering
# Usage: bash update-offering.sh --id offr_abc123 [--name "..."] [--content-aesthetic "..."] [--content-aesthetic-id caes_abc] [--description "..."]

source "$(dirname "$0")/api.sh"

ID=""
KEYS=()
VALS=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --id) ID="$2"; shift 2 ;;
    --name) KEYS+=(name); VALS+=("$2"); shift 2 ;;
    --description) KEYS+=(description); VALS+=("$2"); shift 2 ;;
    --target-audience) KEYS+=(target_audience); VALS+=("$2"); shift 2 ;;
    --differentiator) KEYS+=(differentiator); VALS+=("$2"); shift 2 ;;
    --tone-voice) KEYS+=(tone_voice); VALS+=("$2"); shift 2 ;;
    --brand-promise) KEYS+=(brand_promise); VALS+=("$2"); shift 2 ;;
    --content-aesthetic) KEYS+=(content_aesthetic); VALS+=("$2"); shift 2 ;;
    --content-aesthetic-id) KEYS+=(content_aesthetic_id); VALS+=("$2"); shift 2 ;;
    --english-dialect) KEYS+=(english_dialect); VALS+=("$2"); shift 2 ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

if [[ -z "$ID" ]]; then
  echo "Error: --id is required" >&2
  exit 1
fi

if [[ ${#KEYS[@]} -eq 0 ]]; then
  echo "Error: at least one field to update is required" >&2
  exit 1
fi

# Build JSON payload
json_parts=()
for i in "${!KEYS[@]}"; do
  json_parts+=("$(jq -n --arg k "${KEYS[$i]}" --arg v "${VALS[$i]}" '{($k): $v}')")
done

body=$(printf '%s\n' "${json_parts[@]}" | jq -s 'add | {offering: .}')

response=""
if ! response=$(api_patch "/offerings/${ID}" "$body"); then
  exit 1
fi

echo "$response" | jq '.result'
