#!/usr/bin/env bash
# Get a single offering by prefix ID
# Usage: bash get-offering.sh --id offr_abc123

source "$(dirname "$0")/api.sh"

ID=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --id) ID="$2"; shift 2 ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

if [[ -z "$ID" ]]; then
  echo "Error: --id is required" >&2
  exit 1
fi

response=""
if ! response=$(api_get "/offerings/${ID}"); then
  exit 1
fi

echo "$response" | jq '.data'
