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
- Photo Collection: `pcol_*`
- Niche Discovery: `ndsc_*`
- Discovered TikTok: `dtkt_*`
- Seed Idea: `seed_*`
- TikTok Account: `ttak_*`
- Hook Performance: `hook_*`
- Conversion Event: `conv_*`
- Diagnostic Report: `diag_*`
- CTA Variant: `ctav_*`

## Response Envelope

All responses use an agent-first envelope:

**Success:**
```json
{
  "ok": true,
  "result": { ... },
  "next_actions": [
    { "action": "approve", "method": "POST", "url": "/api/v1/...", "description": "..." }
  ],
  "meta": { "timestamp": "2026-03-24T12:00:00Z" }
}
```

**Error:**
```json
{
  "ok": false,
  "error": { "message": "...", "code": "not_found" },
  "next_actions": [
    { "action": "create", "method": "POST", "url": "/api/v1/...", "description": "Create one instead" }
  ],
  "meta": { "timestamp": "2026-03-24T12:00:00Z" }
}
```

`next_actions` tells agents what they can do next based on the current resource state. Actions with `"type": "poll"` indicate async operations.

Error codes: `unauthorized`, `not_found`, `unprocessable_entity`, `rate_limited`, `missing_parameter`, `invalid_parameter`, `validation_error`

## Endpoints

### Offerings

| Method | Path | Description |
|--------|------|-------------|
| GET | `/offerings` | List offerings |
| GET | `/offerings/{id}` | Get an offering |
| POST | `/offerings` | Create an offering |
| PATCH | `/offerings/{id}` | Update an offering |

**Create/update offering body:**
```json
{
  "offering": {
    "name": "My Product",
    "description": "...",
    "target_audience": "...",
    "differentiator": "...",
    "tone_voice": "...",
    "brand_promise": "...",
    "content_aesthetic": "...",
    "english_dialect": "..."
  }
}
```

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

**Create/update campaign body (all fields optional on update):**
```json
{
  "campaign": {
    "name": "Summer Launch",
    "description": "...",
    "content_focus": "...",
    "status": "draft|active|paused",
    "campaign_type": "brand_awareness|audience_building|app_promotion|ecommerce_promotion",
    "content_brief": "...",
    "content_seed_bank": "...",
    "content_aesthetic": "...",
    "image_source_preference": "ai_generated|photo_collection",
    "always_generate_images": false,
    "photo_collection_id": "pcol_*",
    "default_artwork_style_id": "arts_*",
    "automated": true,
    "auto_approval": false,
    "preferred_hour": 11,
    "default_text_style_variant": "outline|background_white|background_color|background_color_solid",
    "default_text_background_color": "#008080",
    "default_text_background_opacity": 0.72,
    "default_text_layout": "headline_subtext|single_block",
    "automation_text_style_variant": "outline|background_white|background_color|background_color_solid",
    "automation_text_background_color": "#008080",
    "automation_text_background_opacity": 0.72,
    "automation_text_layout": "headline_subtext|single_block",
    "tik_tok_account_id": "tktk_*",
    "automation_template_ids": ["tmpl_*"],
    "artwork_style_ids": ["arts_*"]
  }
}
```

**Writable field groups:**
- **Core**: `name`, `description`, `content_focus`, `status`, `campaign_type`, `content_brief`
- **Content direction**: `content_seed_bank`, `content_aesthetic`
- **Automation**: `automated`, `auto_approval`, `preferred_hour`
- **Image settings**: `image_source_preference`, `always_generate_images`, `photo_collection_id` (prefix ID), `default_artwork_style_id` (prefix ID)
- **Text defaults**: `default_text_style_variant`, `default_text_background_color`, `default_text_background_opacity`, `default_text_layout`
- **Automation text overrides**: `automation_text_style_variant`, `automation_text_background_color`, `automation_text_background_opacity`, `automation_text_layout`
- **Associations**: `tik_tok_account_id` (prefix ID), `automation_template_ids` (array of prefix IDs), `artwork_style_ids` (array of prefix IDs)

**Read-only fields:** `automation_status`, `automation_error_message`, `last_automated_run_at`, `archived`, timestamps

Notes:
- `photo_collection_id`, `default_artwork_style_id`, `tik_tok_account_id` accept prefix IDs; set to `null` to clear
- `automation_template_ids` and `artwork_style_ids` accept arrays of prefix IDs and sync join tables
- `content_seed_bank` stores seed content ideas for AI generation

**List campaigns query params:** `status` (draft|active|paused), `archived` (boolean)

### Content Ideas

| Method | Path | Description |
|--------|------|-------------|
| GET | `/offerings/{oid}/campaigns/{cid}/content_ideas` | List ideas |
| POST | `/offerings/{oid}/campaigns/{cid}/content_ideas` | Create an idea |
| GET | `/offerings/{oid}/campaigns/{cid}/content_ideas/{id}` | Get an idea |
| POST | `/offerings/{oid}/campaigns/{cid}/content_ideas/{id}/approve` | Approve |
| POST | `/offerings/{oid}/campaigns/{cid}/content_ideas/{id}/reject` | Reject |

**Create content idea body:**
```json
{
  "content_idea": {
    "title": "My Idea",
    "concept": "...",
    "hook_angle": "...",
    "slide_content": [],
    "generated_content": {}
  }
}
```

**List ideas query params:** `status` (draft|approved|used|archived)

### Creatives

| Method | Path | Description |
|--------|------|-------------|
| GET | `/offerings/{oid}/campaigns/{cid}/creatives` | List creatives |
| POST | `/offerings/{oid}/campaigns/{cid}/creatives` | Create creative |
| GET | `/offerings/{oid}/campaigns/{cid}/creatives/{id}` | Get creative |
| PATCH | `/offerings/{oid}/campaigns/{cid}/creatives/{id}` | Update creative |
| POST | `/offerings/{oid}/campaigns/{cid}/creatives/{id}/approve` | Approve creative |
| POST | `/offerings/{oid}/campaigns/{cid}/creatives/{id}/archive` | Archive creative |
| POST | `/offerings/{oid}/campaigns/{cid}/creatives/{id}/unarchive` | Unarchive creative |
| POST | `/offerings/{oid}/campaigns/{cid}/creatives/{id}/generate_images` | Generate images (async) |
| POST | `/offerings/{oid}/campaigns/{cid}/creatives/{id}/generate_video` | Generate video (async) |
| POST | `/offerings/{oid}/campaigns/{cid}/creatives/{id}/generate_assets` | Generate assets ZIP (async) |
| POST | `/offerings/{oid}/campaigns/{cid}/creatives/{id}/regenerate_prompts` | Regenerate visual prompts |
| POST | `/offerings/{oid}/campaigns/{cid}/creatives/{id}/generate_post_info` | Generate post info |
| POST | `/offerings/{oid}/campaigns/{cid}/creatives/{id}/post_to_tiktok` | Post to TikTok |

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

**Regenerate prompts body:**
```json
{
  "prompt_description": "dark moody aesthetic with neon accents"
}
```

**Post to TikTok body:**
```json
{
  "media_type": "video|photo"
}
```

**Creative statuses:** draft, pending, generating_content, finding_images, proofing, approved, generating_video, completed, failed

**List creatives query params:** `status`

### Slides

| Method | Path | Description |
|--------|------|-------------|
| GET | `/offerings/{oid}/campaigns/{cid}/creatives/{crid}/slides` | List slides |
| POST | `/offerings/{oid}/campaigns/{cid}/creatives/{crid}/slides` | Create slide |
| GET | `/offerings/{oid}/campaigns/{cid}/creatives/{crid}/slides/{id}` | Get slide |
| PATCH | `/offerings/{oid}/campaigns/{cid}/creatives/{crid}/slides/{id}` | Update slide |
| DELETE | `/offerings/{oid}/campaigns/{cid}/creatives/{crid}/slides/{id}` | Delete slide |
| POST | `/offerings/{oid}/campaigns/{cid}/creatives/{crid}/slides/{id}/hide` | Hide slide |
| POST | `/offerings/{oid}/campaigns/{cid}/creatives/{crid}/slides/{id}/unhide` | Unhide slide |
| POST | `/offerings/{oid}/campaigns/{cid}/creatives/{crid}/slides/{id}/move` | Move slide |
| POST | `/offerings/{oid}/campaigns/{cid}/creatives/{crid}/slides/{id}/generate_image` | Generate image (async) |
| POST | `/offerings/{oid}/campaigns/{cid}/creatives/{crid}/slides/{id}/upload_image` | Upload image |

**Create slide body:**
```json
{
  "slide": {
    "slide_type": "hook|content|cta|app_plug|problem|solution"
  }
}
```

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

**Move slide body:**
```json
{
  "direction": "top|up|down|bottom"
}
```

**Upload image body (URL):**
```json
{
  "image_url": "https://example.com/photo.jpg"
}
```

**Upload image body (base64):**
```json
{
  "image_data": "base64_encoded_data",
  "filename": "photo.jpg",
  "content_type": "image/jpeg"
}
```

### Niche Discoveries

| Method | Path | Description |
|--------|------|-------------|
| GET | `/offerings/{oid}/campaigns/{cid}/niche_discoveries` | List niche discoveries |
| POST | `/offerings/{oid}/campaigns/{cid}/niche_discoveries` | Create niche discovery |
| GET | `/offerings/{oid}/campaigns/{cid}/niche_discoveries/{id}` | Get niche discovery |
| PATCH | `/offerings/{oid}/campaigns/{cid}/niche_discoveries/{id}` | Update niche discovery |
| DELETE | `/offerings/{oid}/campaigns/{cid}/niche_discoveries/{id}` | Delete niche discovery |
| POST | `/offerings/{oid}/campaigns/{cid}/niche_discoveries/{id}/run` | Run discovery (async) |
| POST | `/offerings/{oid}/campaigns/{cid}/niche_discoveries/{id}/pause` | Pause discovery |
| POST | `/offerings/{oid}/campaigns/{cid}/niche_discoveries/{id}/resume` | Resume discovery |
| POST | `/offerings/{oid}/campaigns/{cid}/niche_discoveries/{id}/refresh_terms` | Refresh search terms (async) |

**Create/update niche discovery body:**
```json
{
  "niche_discovery": {
    "name": "Fitness Trends",
    "interval_hours": 24,
    "auto_reimagine": true,
    "auto_reimagine_limit": 5
  }
}
```

### Discovered TikToks

| Method | Path | Description |
|--------|------|-------------|
| GET | `.../{ndid}/discovered_tiktoks` | List discovered TikToks |
| GET | `.../{ndid}/discovered_tiktoks/{id}` | Get discovered TikTok |
| POST | `.../{ndid}/discovered_tiktoks/{id}/analyze` | Analyze (async) |
| POST | `.../{ndid}/discovered_tiktoks/{id}/reimagine` | Reimagine as creative (async) |
| POST | `.../{ndid}/discovered_tiktoks/{id}/dismiss` | Dismiss |
| POST | `/discovered_tiktoks/ingest` | Ingest a TikTok by URL |

Full path for nested routes: `/offerings/{oid}/campaigns/{cid}/niche_discoveries/{ndid}/discovered_tiktoks/...`

**Ingest body:**
```json
{
  "url": "https://www.tiktok.com/@user/video/123",
  "offering_id": "offr_*",
  "campaign_id": "camp_*"
}
```

**List discovered TikToks query params:** `status` (pending|analyzed|reimagined|dismissed)

### Seed Ideas

| Method | Path | Description |
|--------|------|-------------|
| GET | `/offerings/{oid}/campaigns/{cid}/seed_ideas` | List seed ideas |
| POST | `/offerings/{oid}/campaigns/{cid}/seed_ideas` | Create seed idea |
| GET | `/offerings/{oid}/campaigns/{cid}/seed_ideas/{id}` | Get seed idea |
| PATCH | `/offerings/{oid}/campaigns/{cid}/seed_ideas/{id}` | Update seed idea |
| DELETE | `/offerings/{oid}/campaigns/{cid}/seed_ideas/{id}` | Delete seed idea |

**Create/update seed idea body:**
```json
{
  "seed_idea": {
    "topic": "How to use the product",
    "content": "Detailed content description...",
    "category": "tutorial",
    "position": 1,
    "status": "active|used|archived"
  }
}
```

**List seed ideas query params:** `status` (active|used|archived)

### Hook Performances

| Method | Path | Description |
|--------|------|-------------|
| GET | `/offerings/{oid}/hook_performances` | List hook performances |
| GET | `/offerings/{oid}/hook_performances/{id}` | Get a hook performance |

**List query params:** `decision_status` (testing|double_down|keep|try_variation|dropped), `format_category`, `min_views`

Prefix ID: `hook_*`

### Conversion Events

| Method | Path | Description |
|--------|------|-------------|
| GET | `/conversion_events` | List conversion events |
| POST | `/conversion_events` | Create a conversion event |
| POST | `/conversion_events/bulk` | Create multiple events |

**Create body:**
```json
{
  "conversion_event": {
    "source": "custom|stripe|revenuecat|webhook",
    "event_type": "trial_start|subscription|purchase|download|signup",
    "occurred_at": "2026-03-24T12:00:00Z",
    "amount_cents": 999,
    "currency": "USD",
    "customer_id": "cus_123",
    "external_id": "evt_abc"
  }
}
```

**Bulk create body:**
```json
{
  "events": [
    { "source": "stripe", "event_type": "subscription", "occurred_at": "...", "amount_cents": 999 }
  ]
}
```

**List query params:** `source`, `event_type`, `campaign_id`, `since` (ISO8601)

Attribution is automatic -- events are matched to the most recent published creative within 72 hours.

Prefix ID: `conv_*`

### Diagnostic Reports

| Method | Path | Description |
|--------|------|-------------|
| GET | `/offerings/{oid}/diagnostic_reports` | List reports |
| GET | `/offerings/{oid}/diagnostic_reports/latest` | Get latest report |
| POST | `/offerings/{oid}/diagnostic_reports/run` | Run diagnostics (async) |

Reports classify creatives into quadrants: scale, fix_cta, fix_hook, full_reset.

Prefix ID: `diag_*`

### CTA Variants

| Method | Path | Description |
|--------|------|-------------|
| GET | `/offerings/{oid}/cta_variants` | List CTA variants |

**List query params:** `status` (active|winner|retired)

Prefix ID: `ctav_*`

### Daily Report

| Method | Path | Description |
|--------|------|-------------|
| GET | `/offerings/{oid}/daily_report` | Get composite daily report |

Returns combined: diagnostics + hook performance + conversions + recommendations. This is the primary endpoint for understanding "what should I do today?"

### TikTok Accounts

| Method | Path | Description |
|--------|------|-------------|
| GET | `/tik_tok_accounts` | List TikTok accounts |
| GET | `/tik_tok_accounts/{id}` | Get TikTok account |

Read-only. TikTok accounts are connected via OAuth in the web app.

### Photo Collections

| Method | Path | Description |
|--------|------|-------------|
| GET | `/offerings/{oid}/photo_collections` | List photo collections |
| GET | `/offerings/{oid}/photo_collections/{id}` | Get collection with images |
| POST | `/offerings/{oid}/photo_collections` | Create collection |
| POST | `/offerings/{oid}/photo_collections/{id}/upload_images` | Upload images via URL |
| DELETE | `/offerings/{oid}/photo_collections/{id}/remove_image` | Remove image |

**Create body:**
```json
{ "photo_collection": { "name": "My Photos", "description": "..." } }
```

**Upload images body:**
```json
{ "image_urls": ["https://example.com/a.jpg", "https://example.com/b.jpg"] }
```

**Remove image params:** `image_id` (integer ID of the photo_collection_image record)

Prefix ID: `pcol_*`

### Reference Data

| Method | Path | Description |
|--------|------|-------------|
| GET | `/artwork_styles` | List artwork styles |
| GET | `/artwork_styles/{id}` | Get artwork style |
| GET | `/creative_templates` | List creative templates |
| GET | `/creative_templates/{id}` | Get creative template |
| GET | `/content_aesthetics` | List content aesthetics |

### OpenAPI Spec

| Method | Path | Description |
|--------|------|-------------|
| GET | `/openapi` | Download the OpenAPI 3.0 YAML spec |

## Async Operations

Async operations include a poll action in `next_actions`:

```json
{
  "ok": true,
  "result": { ... },
  "next_actions": [
    {
      "action": "poll_status",
      "method": "GET",
      "url": "/api/v1/offerings/offr_.../creatives/crtv_...",
      "type": "poll",
      "interval_seconds": 5,
      "status_field": "status",
      "terminal_states": ["proofing", "failed"]
    }
  ]
}
```

Poll the `url` at `interval_seconds` intervals. Check `result.<status_field>` in the response. Stop when it matches a value in `terminal_states`.
