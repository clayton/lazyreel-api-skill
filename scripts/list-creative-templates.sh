#!/usr/bin/env bash
# List creative templates
# Usage: bash list-creative-templates.sh [--page N] [--per-page N]

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
if ! response=$(api_get "/creative_templates" "page=${PAGE}&per_page=${PER_PAGE}"); then
  exit 1
fi

echo "$response" | jq -r '
  "Creative Templates (page \(.meta.current_page // 1) of \(.meta.total_pages // 1), \(.meta.total_count // 0) total)\n",
  (["ID", "Name", "Type", "Purpose", "Active", "Auto"],
   ["--", "----", "----", "-------", "------", "----"],
   (.data[] |
     [
       .id,
       (.name // "-" | if length > 30 then .[:30] + "..." else . end),
       .template_type,
       .content_purpose,
       (.is_active | tostring),
       (.automation_eligible | tostring)
     ]
   )
   | @tsv)
' | column -t -s $'\t'
