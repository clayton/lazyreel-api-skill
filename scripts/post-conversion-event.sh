#!/usr/bin/env bash
# Create a conversion event for attribution tracking
# Usage: bash post-conversion-event.sh --source custom --event-type download --occurred-at "2026-03-24T12:00:00Z" [--amount-cents 999] [--currency USD] [--customer-id cus_123] [--external-id evt_abc]

source "$(dirname "$0")/api.sh"

SOURCE=""
EVENT_TYPE=""
OCCURRED_AT=""
AMOUNT_CENTS=""
CURRENCY=""
CUSTOMER_ID=""
EXTERNAL_ID=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --source) SOURCE="$2"; shift 2 ;;
    --event-type) EVENT_TYPE="$2"; shift 2 ;;
    --occurred-at) OCCURRED_AT="$2"; shift 2 ;;
    --amount-cents) AMOUNT_CENTS="$2"; shift 2 ;;
    --currency) CURRENCY="$2"; shift 2 ;;
    --customer-id) CUSTOMER_ID="$2"; shift 2 ;;
    --external-id) EXTERNAL_ID="$2"; shift 2 ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

if [[ -z "$SOURCE" || -z "$EVENT_TYPE" || -z "$OCCURRED_AT" ]]; then
  echo "Error: --source, --event-type, and --occurred-at are required" >&2
  echo "Sources: revenuecat, stripe, custom, webhook" >&2
  echo "Event types: trial_start, subscription, purchase, download, signup" >&2
  exit 1
fi

BODY=$(jq -n \
  --arg source "$SOURCE" \
  --arg event_type "$EVENT_TYPE" \
  --arg occurred_at "$OCCURRED_AT" \
  --arg amount_cents "$AMOUNT_CENTS" \
  --arg currency "$CURRENCY" \
  --arg customer_id "$CUSTOMER_ID" \
  --arg external_id "$EXTERNAL_ID" \
  '{conversion_event: {
    source: $source,
    event_type: $event_type,
    occurred_at: $occurred_at
  } | if $amount_cents != "" then . + {amount_cents: ($amount_cents | tonumber)} else . end
    | if $currency != "" then . + {currency: $currency} else . end
    | if $customer_id != "" then . + {customer_id: $customer_id} else . end
    | if $external_id != "" then . + {external_id: $external_id} else . end
  }')

response=""
if ! response=$(api_post "/conversion_events" "$BODY"); then
  exit 1
fi

echo "$response" | format_json
