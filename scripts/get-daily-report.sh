#!/usr/bin/env bash
# Get the combined daily performance report for an offering
# Usage: bash get-daily-report.sh --offering-id offr_abc123

source "$(dirname "$0")/api.sh"

OFFERING_ID=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --offering-id) OFFERING_ID="$2"; shift 2 ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

if [[ -z "$OFFERING_ID" ]]; then
  echo "Error: --offering-id is required" >&2
  exit 1
fi

response=""
if ! response=$(api_get "/offerings/$OFFERING_ID/daily_report"); then
  exit 1
fi

echo "$response" | format_json
