#!/usr/bin/env bash
# List all offerings for the authenticated organization
# Usage: bash list-offerings.sh [--page N] [--per-page N]

source "$(dirname "$0")/api.sh"

PAGE=1
PER_PAGE=25

while [[ $# -gt 0 ]]; do
  case "$1" in
    --page) PAGE="$2"; shift 2 ;;
    --per-page) PER_PAGE="$2"; shift 2 ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

response=""
if ! response=$(api_get "/offerings" "page=${PAGE}&per_page=${PER_PAGE}"); then
  exit 1
fi

echo "$response" | jq -r '
  "Offerings (page \(.meta.current_page // 1) of \(.meta.total_pages // 1), \(.meta.total_count // 0) total)\n",
  (["ID", "Name", "Target Audience"],
   ["--", "----", "---------------"],
   (.result[] |
     [
       .id,
       .name,
       (.target_audience // "-" | if length > 50 then .[:50] + "..." else . end)
     ]
   )
   | @tsv)
' | column -t -s $'\t'
