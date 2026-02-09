# LazyReel API v1 Reference

Base URL: `https://lazyreel.com/api/v1`

## Authentication

All requests require a Bearer token:
```
Authorization: Bearer lr_<48 hex characters>
```

Tokens are scoped to an organization. Create them in LazyReel: Settings > API Tokens.

## Rate Limiting

60 requests per 60-second window. Response headers:
- `X-RateLimit-Limit`: Max requests per window
- `X-RateLimit-Remaining`: Requests remaining
- `X-RateLimit-Reset`: Unix timestamp when window resets

## Prefix IDs

All resources use human-readable prefix IDs:
- Offering: `offr_*`
- Campaign: `camp_*`
- Content Idea: `idea_*`
- Creative: `crtv_*`
- Slide: `slde_*`
- Artwork Style: `arts_*`
- Creative Template: `tmpl_*`

## Pagination

List endpoints accept `page` (default: 1) and `per_page` (default: 25, max: 100).

Response includes:
```json
{
  "meta": {
    "current_page": 1,
    "total_pages": 3,
    "total_count": 52,
    "per_page": 25
  }
}
```

## Error Responses

```json
{
  "error": {
    "code": "not_found",
    "message": "Resource not found",
    "details": null
  }
}
```

Error codes: `unauthorized`, `not_found`, `unprocessable_entity`, `rate_limited`, `missing_parameter`, `invalid_parameter`, `validation_error`

## Endpoints

### Offerings

| Method | Path | Description |
|--------|------|-------------|
| GET | `/offerings` | List offerings |
| GET | `/offerings/{id}` | Get an offering |

### Campaigns

| Method | Path | Description |
|--------|------|-------------|
| GET | `/offerings/{offering_id}/campaigns` | List campaigns |
| POST | `/offerings/{offering_id}/campaigns` | Create a campaign |
| GET | `/offerings/{offering_id}/campaigns/{id}` | Get a campaign |
| PATCH | `/offerings/{offering_id}/campaigns/{id}` | Update a campaign |
| POST | `/offerings/{offering_id}/campaigns/{id}/archive` | Archive |
| POST | `/offerings/{offering_id}/campaigns/{id}/unarchive` | Unarchive |
| POST | `/offerings/{offering_id}/campaigns/{id}/generate_ideas` | Generate ideas (async) |

**Create campaign body:**
```json
{
  "campaign": {
    "name": "Summer Launch",
    "description": "...",
    "campaign_goal": "engagement|brand_awareness|traffic|sales",
    "content_brief": "...",
    "creative_template_id": "tmpl_*",
    "artwork_style_ids": ["arts_*"]
  }
}
```

**List campaigns query params:** `status` (draft|active|paused), `archived` (boolean)

### Content Ideas

| Method | Path | Description |
|--------|------|-------------|
| GET | `/offerings/{oid}/campaigns/{cid}/content_ideas` | List ideas |
| GET | `/offerings/{oid}/campaigns/{cid}/content_ideas/{id}` | Get an idea |
| POST | `/offerings/{oid}/campaigns/{cid}/content_ideas/{id}/approve` | Approve |
| POST | `/offerings/{oid}/campaigns/{cid}/content_ideas/{id}/reject` | Reject |

**List ideas query params:** `status` (draft|approved|used|archived)

### Creatives

| Method | Path | Description |
|--------|------|-------------|
| GET | `/offerings/{oid}/campaigns/{cid}/creatives` | List creatives |
| POST | `/offerings/{oid}/campaigns/{cid}/creatives` | Create creative |
| GET | `/offerings/{oid}/campaigns/{cid}/creatives/{id}` | Get creative |
| PATCH | `/offerings/{oid}/campaigns/{cid}/creatives/{id}` | Update creative |
| POST | `/offerings/{oid}/campaigns/{cid}/creatives/{id}/generate_images` | Generate images (async) |
| POST | `/offerings/{oid}/campaigns/{cid}/creatives/{id}/generate_video` | Generate video (async) |
| POST | `/offerings/{oid}/campaigns/{cid}/creatives/{id}/generate_assets` | Generate assets ZIP (async) |

**Create creative body:**
```json
{
  "creative": {
    "name": "Summer Vibes",
    "content_idea_id": "idea_*",
    "creative_template_id": "tmpl_*",
    "artwork_style_id": "arts_*",
    "transition_style": "none|push_left",
    "post_title": "...",
    "post_description": "...",
    "post_hashtags": "#summer #product"
  }
}
```

**Creative statuses:** draft, pending, generating_content, finding_images, proofing, approved, generating_video, completed, failed

**List creatives query params:** `status`

### Slides

| Method | Path | Description |
|--------|------|-------------|
| GET | `/offerings/{oid}/campaigns/{cid}/creatives/{crid}/slides` | List slides |
| GET | `/offerings/{oid}/campaigns/{cid}/creatives/{crid}/slides/{id}` | Get slide |
| PATCH | `/offerings/{oid}/campaigns/{cid}/creatives/{crid}/slides/{id}` | Update slide |

**Update slide body:**
```json
{
  "slide": {
    "position": 0,
    "duration": 3.0,
    "slide_type": "hook|content|cta|app_plug|problem|solution",
    "hidden": false,
    "visual_prompt": "...",
    "artwork_style_id": "arts_*",
    "text_elements": [
      {
        "id": "uuid",
        "preset": "headline",
        "text": "Stop Scrolling",
        "x": 11.0,
        "y": 20.0,
        "height": 15.0,
        "width": 78.0,
        "alignment": "center"
      }
    ]
  }
}
```

### Reference Data

| Method | Path | Description |
|--------|------|-------------|
| GET | `/artwork_styles` | List artwork styles |
| GET | `/artwork_styles/{id}` | Get artwork style |
| GET | `/creative_templates` | List creative templates |
| GET | `/creative_templates/{id}` | Get creative template |

### OpenAPI Spec

| Method | Path | Description |
|--------|------|-------------|
| GET | `/openapi` | Download the OpenAPI 3.0 YAML spec |

## Async Operations

Endpoints that trigger background jobs return 202 with polling metadata:

```json
{
  "message": "Generating images for creative",
  "polling": {
    "poll_url": "/api/v1/offerings/offr_.../creatives/crtv_...",
    "interval_seconds": 3,
    "status_field": "data.status",
    "terminal_states": ["completed", "failed"]
  }
}
```

Poll the `poll_url` at `interval_seconds` intervals. Check the value at `status_field` in the response. Stop when it matches a value in `terminal_states`.
