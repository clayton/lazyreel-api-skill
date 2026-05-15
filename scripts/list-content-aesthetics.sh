#!/usr/bin/env bash
# List available content aesthetics (curated + organization-specific)
# Usage: bash list-content-aesthetics.sh

source "$(dirname "$0")/api.sh"

response=""
if ! response=$(api_get "/content_aesthetics"); then
  exit 1
fi

count=$(echo "$response" | jq '.result | length')
echo "Content Aesthetics ($count available)"
printf "%-36s  %-24s  %-16s  %s\n" "ID" "Name" "Slug" "Description"
printf "%-36s  %-24s  %-16s  %s\n" "--" "----" "----" "-----------"

echo "$response" | jq -r '.result[] | [.id, .name, .slug, (.description | .[0:60] + "...")] | @tsv' | \
  while IFS=$'\t' read -r id name slug desc; do
    printf "%-36s  %-24s  %-16s  %s\n" "$id" "$name" "$slug" "$desc"
  done
