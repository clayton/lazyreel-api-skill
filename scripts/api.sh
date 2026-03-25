#!/usr/bin/env bash
# Shared API wrapper for LazyReel API
# Source this file from other scripts: source "$(dirname "$0")/api.sh"

set -euo pipefail

LAZYREEL_API_BASE="https://lazyreel.com/api/v1"

# Load environment variables from .env files
load_env() {
  local env_files=(
    "$HOME/.claude/.env"
    "$HOME/.env"
    ".env"
  )
  for f in "${env_files[@]}"; do
    if [[ -f "$f" ]]; then
      set -a
      source "$f"
      set +a
      break
    fi
  done

  if [[ -z "${LAZYREEL_API_TOKEN:-}" ]]; then
    echo "Error: LAZYREEL_API_TOKEN not set." >&2
    echo "Add it to ~/.claude/.env" >&2
    echo "Tokens can be created in LazyReel under Settings > API Tokens." >&2
    exit 1
  fi
}

# Check API response for errors (supports agent-first envelope: ok/result/next_actions)
check_error() {
  local response="$1"
  # Check for ok: false (agent-first envelope)
  local ok
  ok=$(echo "$response" | jq -r '.ok // true' 2>/dev/null) || ok="true"
  if [[ "$ok" == "false" ]]; then
    local code
    code=$(echo "$response" | jq -r '.error.code // "unknown"' 2>/dev/null) || code="unknown"
    local error_msg
    error_msg=$(echo "$response" | jq -r '.error.message // "Unknown error"' 2>/dev/null)
    echo "API Error [$code]: $error_msg" >&2
    local details
    details=$(echo "$response" | jq -r '.error.details // empty' 2>/dev/null) || true
    if [[ -n "$details" ]]; then
      echo "Details: $details" >&2
    fi
    # Show recovery suggestions from next_actions
    local actions
    actions=$(echo "$response" | jq -r '.next_actions[]? | "  -> \(.method) \(.url) — \(.description)"' 2>/dev/null) || true
    if [[ -n "$actions" ]]; then
      echo "Suggested next actions:" >&2
      echo "$actions" >&2
    fi
    return 1
  fi
  return 0
}

# Pretty-print JSON via jq
format_json() {
  jq '.' 2>/dev/null || cat
}

# GET request
api_get() {
  local path="$1"
  local query="${2:-}"
  local url="${LAZYREEL_API_BASE}${path}"
  if [[ -n "$query" ]]; then
    url="${url}?${query}"
  fi
  local response
  response=$(curl -sf -H "Authorization: Bearer $LAZYREEL_API_TOKEN" \
    -H "Content-Type: application/json" \
    "$url") || {
    echo "Error: API request failed for $path" >&2
    return 1
  }
  check_error "$response" || return 1
  echo "$response"
}

# POST request with JSON body
api_post() {
  local path="$1"
  local body="${2:-{}}"
  local url="${LAZYREEL_API_BASE}${path}"
  local response
  response=$(curl -sf -X POST \
    -H "Authorization: Bearer $LAZYREEL_API_TOKEN" \
    -H "Content-Type: application/json" \
    -d "$body" "$url") || {
    echo "Error: API POST failed for $path" >&2
    return 1
  }
  check_error "$response" || return 1
  echo "$response"
}

# PATCH request with JSON body
api_patch() {
  local path="$1"
  local body="$2"
  local url="${LAZYREEL_API_BASE}${path}"
  local response
  response=$(curl -sf -X PATCH \
    -H "Authorization: Bearer $LAZYREEL_API_TOKEN" \
    -H "Content-Type: application/json" \
    -d "$body" "$url") || {
    echo "Error: API PATCH failed for $path" >&2
    return 1
  }
  check_error "$response" || return 1
  echo "$response"
}

# DELETE request
api_delete() {
  local path="$1"
  local url="${LAZYREEL_API_BASE}${path}"
  local response
  response=$(curl -sf -X DELETE \
    -H "Authorization: Bearer $LAZYREEL_API_TOKEN" \
    -H "Content-Type: application/json" \
    "$url") || {
    echo "Error: API DELETE failed for $path" >&2
    return 1
  }
  check_error "$response" || return 1
  echo "$response"
}

# Auto-load env when sourced
load_env
