#!/usr/bin/env bash
# Get a single TikTok account
# Usage: bash get-tiktok-account.sh --id ttak_abc123

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
if ! response=$(api_get "/tik_tok_accounts/${ID}"); then
  exit 1
fi

echo "$response" | jq '.result'
