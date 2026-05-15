#!/usr/bin/env bash
# List connected TikTok accounts
# Usage: bash list-tiktok-accounts.sh

source "$(dirname "$0")/api.sh"

response=""
if ! response=$(api_get "/tik_tok_accounts"); then
  exit 1
fi

echo "$response" | jq -r '
  (["ID", "Username", "Display Name", "Active", "Connected", "Followers"],
   ["--", "--------", "------------", "------", "---------", "---------"],
   (.result[] |
     [
       .id,
       (.username // "-"),
       (.display_name // "-" | if length > 20 then .[:20] + "..." else . end),
       (.active | tostring),
       (.connected | tostring),
       (.follower_count // 0 | tostring)
     ]
   )
   | @tsv)
' | column -t -s $'\t'
