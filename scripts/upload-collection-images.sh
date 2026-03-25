#!/usr/bin/env bash
# Upload images to a photo collection via URL
# Usage: bash upload-collection-images.sh --offering-id offr_abc123 --collection-id pcol_def456 --image-urls "https://example.com/a.jpg,https://example.com/b.jpg"

source "$(dirname "$0")/api.sh"

OFFERING_ID=""
COLLECTION_ID=""
IMAGE_URLS=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --offering-id) OFFERING_ID="$2"; shift 2 ;;
    --collection-id) COLLECTION_ID="$2"; shift 2 ;;
    --image-urls) IMAGE_URLS="$2"; shift 2 ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

if [[ -z "$OFFERING_ID" || -z "$COLLECTION_ID" || -z "$IMAGE_URLS" ]]; then
  echo "Error: --offering-id, --collection-id, and --image-urls are required" >&2
  echo "Example: --image-urls \"https://example.com/a.jpg,https://example.com/b.jpg\"" >&2
  exit 1
fi

# Convert comma-separated URLs to JSON array
URLS_JSON=$(echo "$IMAGE_URLS" | tr ',' '\n' | jq -R . | jq -s .)

BODY=$(jq -n --argjson urls "$URLS_JSON" '{ image_urls: $urls }')

response=""
if ! response=$(api_post "/offerings/$OFFERING_ID/photo_collections/$COLLECTION_ID/upload_images" "$BODY"); then
  exit 1
fi

echo "$response" | format_json
