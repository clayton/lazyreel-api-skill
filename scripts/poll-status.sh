#!/usr/bin/env bash
# Poll an async operation until it reaches a terminal state
# Usage: bash poll-status.sh --url "/api/v1/offerings/offr_.../creatives/crtv_..." --field "result.status" --done "completed,failed" [--interval 3] [--max-polls 60]

source "$(dirname "$0")/api.sh"

POLL_PATH=""
STATUS_FIELD="result.status"
TERMINAL_STATES="completed,failed"
INTERVAL=3
MAX_POLLS=60

while [[ $# -gt 0 ]]; do
  case "$1" in
    --url) POLL_PATH="$2"; shift 2 ;;
    --field) STATUS_FIELD="$2"; shift 2 ;;
    --done) TERMINAL_STATES="$2"; shift 2 ;;
    --interval) INTERVAL="$2"; shift 2 ;;
    --max-polls) MAX_POLLS="$2"; shift 2 ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

if [[ -z "$POLL_PATH" ]]; then
  echo "Error: --url is required" >&2
  exit 1
fi

# Strip base URL prefix if present
POLL_PATH="${POLL_PATH#https://lazyreel.com/api/v1}"
POLL_PATH="${POLL_PATH#/api/v1}"

# Convert status field from dot notation to jq path
JQ_PATH=$(echo "$STATUS_FIELD" | sed 's/\././g')

poll_count=0
while [[ $poll_count -lt $MAX_POLLS ]]; do
  response=""
  if ! response=$(api_get "$POLL_PATH"); then
    echo "Poll failed" >&2
    exit 1
  fi

  current_status=$(echo "$response" | jq -r ".${JQ_PATH}")
  echo "Status: $current_status (poll $((poll_count + 1))/$MAX_POLLS)"

  # Check if terminal
  IFS=',' read -ra STATES <<< "$TERMINAL_STATES"
  for state in "${STATES[@]}"; do
    if [[ "$current_status" == "$state" ]]; then
      echo ""
      echo "$response" | jq '.result'
      exit 0
    fi
  done

  sleep "$INTERVAL"
  ((poll_count++))
done

echo "Timeout: max polls ($MAX_POLLS) reached. Last status: $current_status" >&2
exit 1
