#!/usr/bin/env bash
# Upload an image to a slide via URL or base64 data
# Usage: bash upload-slide-image.sh --offering-id offr_abc123 --campaign-id camp_def456 --creative-id crtv_ghi789 --id slde_jkl012 --image-url "https://..."
# Usage: bash upload-slide-image.sh --offering-id offr_abc123 --campaign-id camp_def456 --creative-id crtv_ghi789 --id slde_jkl012 --image-data "BASE64..." --filename "photo.jpg" --content-type "image/jpeg"

source "$(dirname "$0")/api.sh"

OFFERING_ID=""
CAMPAIGN_ID=""
CREATIVE_ID=""
ID=""
IMAGE_URL=""
IMAGE_DATA=""
FILENAME=""
CONTENT_TYPE=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --offering-id) OFFERING_ID="$2"; shift 2 ;;
    --campaign-id) CAMPAIGN_ID="$2"; shift 2 ;;
    --creative-id) CREATIVE_ID="$2"; shift 2 ;;
    --id) ID="$2"; shift 2 ;;
    --image-url) IMAGE_URL="$2"; shift 2 ;;
    --image-data) IMAGE_DATA="$2"; shift 2 ;;
    --filename) FILENAME="$2"; shift 2 ;;
    --content-type) CONTENT_TYPE="$2"; shift 2 ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

if [[ -z "$OFFERING_ID" || -z "$CAMPAIGN_ID" || -z "$CREATIVE_ID" || -z "$ID" ]]; then
  echo "Error: --offering-id, --campaign-id, --creative-id, and --id are required" >&2
  exit 1
fi

if [[ -n "$IMAGE_URL" && -n "$IMAGE_DATA" ]]; then
  echo "Error: provide either --image-url or --image-data, not both" >&2
  exit 1
fi

if [[ -z "$IMAGE_URL" && -z "$IMAGE_DATA" ]]; then
  echo "Error: either --image-url or --image-data is required" >&2
  exit 1
fi

if [[ -n "$IMAGE_URL" ]]; then
  BODY=$(jq -n --arg url "$IMAGE_URL" '{image_url: $url}')
else
  if [[ -z "$FILENAME" || -z "$CONTENT_TYPE" ]]; then
    echo "Error: --filename and --content-type are required with --image-data" >&2
    exit 1
  fi
  BODY=$(jq -n \
    --arg data "$IMAGE_DATA" \
    --arg fn "$FILENAME" \
    --arg ct "$CONTENT_TYPE" \
    '{image_data: $data, filename: $fn, content_type: $ct}')
fi

response=""
if ! response=$(api_post "/offerings/${OFFERING_ID}/campaigns/${CAMPAIGN_ID}/creatives/${CREATIVE_ID}/slides/${ID}/upload_image" "$BODY"); then
  exit 1
fi

echo "$response" | jq '.result'
