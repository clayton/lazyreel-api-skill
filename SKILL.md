---
name: lazyreel-api
description: Manage LazyReel content marketing campaigns, creatives, AI video generation, niche discovery, seed ideas, TikTok posting, and slide manipulation via the LazyReel REST API. Full CRUD for offerings, campaigns, content ideas, creatives, slides, niche discoveries, discovered TikToks, seed ideas, and TikTok accounts.
---

<objective>
Interact with the LazyReel API to manage content marketing workflows: browse and create offerings, create and manage campaigns, generate AI content ideas, build creatives with slides, trigger image/video generation, discover trending TikToks, reimagine content, manage seed ideas, and post to TikTok. Use the shell scripts in this skill's `scripts/` directory for all API calls.
</objective>

<env>
Required: `LAZYREEL_API_TOKEN` in `~/.codex/.env`, `~/.claude/.env`, `~/.env`, or the current project's `.env`.
Token format: `lr_` followed by 48 hex characters.
Create tokens in LazyReel web app: Settings > API Tokens (requires owner/admin role).
Rate limit: 60 requests per 60-second window.
</env>

<domain_model>
The core resource chain:
```
Organization -> Offering -> Campaign -> ContentIdea -> Creative -> Slides -> Video
                                     -> NicheDiscovery -> DiscoveredTikTok
                                     -> SeedIdea
Organization -> TikTokAccount
```

- **Offering**: Product/service being marketed
- **Campaign**: Marketing campaign with goal, brief, and automation settings
- **ContentIdea**: AI-generated content concept (approve/reject workflow)
- **Creative**: Final content piece (video/carousel) with a state machine
- **Slide**: Individual slide in a creative with text elements and images
- **NicheDiscovery**: Automated TikTok trend discovery configuration
- **DiscoveredTikTok**: A TikTok found via niche discovery, can be analyzed and reimagined
- **SeedIdea**: Topic seeds that guide AI content generation for a campaign
- **TikTokAccount**: Connected TikTok account for posting
- **Photo Collection**: Set of uploaded photos used as image source for campaigns

All resources use prefix IDs: `offr_*`, `camp_*`, `idea_*`, `crtv_*`, `slde_*`, `arts_*`, `tmpl_*`, `pcol_*`, `ndsc_*`, `dtkt_*`, `seed_*`, `ttak_*`, `hook_*`, `conv_*`, `diag_*`, `ctav_*`

**Performance Tracking (The Lazy Loop)**
- **HookPerformance**: Tracks hook text effectiveness with LLM-classified format categories and decision statuses (testing/double_down/keep/try_variation/dropped)
- **ConversionEvent**: Conversion intake from external sources (RevenueCat/Stripe/custom) with timing-based attribution to creatives
- **DiagnosticReport**: Daily quadrant analysis (scale/fix_cta/fix_hook/full_reset)
- **CtaVariant**: CTA text tracking with conversion rates
- **DailyReport**: Composite view combining diagnostics, hook performance, conversions, and recommendations
</domain_model>

<operations>
All API calls should use the bundled shell scripts. Resolve the skill directory before running examples:

```bash
export LAZYREEL_SKILL_DIR="${LAZYREEL_SKILL_DIR:-$HOME/.codex/skills/lazyreel-api}"
test -d "$LAZYREEL_SKILL_DIR" || export LAZYREEL_SKILL_DIR="$HOME/.claude/skills/lazyreel-api"
```

Then run scripts from `$LAZYREEL_SKILL_DIR/scripts/`.

**Offerings**
```bash
# List all offerings
bash $LAZYREEL_SKILL_DIR/scripts/list-offerings.sh [--page N] [--per-page N]

# Get a single offering
bash $LAZYREEL_SKILL_DIR/scripts/get-offering.sh --id offr_abc123

# Update an offering
bash $LAZYREEL_SKILL_DIR/scripts/update-offering.sh --id offr_abc123 [--name "..."] [--description "..."]

# Create an offering
bash $LAZYREEL_SKILL_DIR/scripts/create-offering.sh --name "My Product" [--description "..."] [--target-audience "..."] [--differentiator "..."] [--tone-voice "..."] [--brand-promise "..."] [--content-aesthetic "..."] [--english-dialect "..."]
```

**Campaigns**
```bash
# List campaigns for an offering
bash $LAZYREEL_SKILL_DIR/scripts/list-campaigns.sh --offering-id offr_abc123 [--status draft|active|paused] [--archived] [--page N]

# Get a campaign
bash $LAZYREEL_SKILL_DIR/scripts/get-campaign.sh --offering-id offr_abc123 --id camp_def456

# Create a campaign
bash $LAZYREEL_SKILL_DIR/scripts/create-campaign.sh --offering-id offr_abc123 --name "Summer Launch" [--goal engagement|brand_awareness|traffic|sales] [--brief "..."] [--template-id tmpl_abc] [--style-ids "arts_a,arts_b"]

# Update a campaign
bash $LAZYREEL_SKILL_DIR/scripts/update-campaign.sh --offering-id offr_abc123 --id camp_def456 [--name "..."] [--status draft|active|paused] [--goal ...] [--brief "..."]

# Archive / unarchive
bash $LAZYREEL_SKILL_DIR/scripts/archive-campaign.sh --offering-id offr_abc123 --id camp_def456 [--unarchive]
```

**Campaign Text Style Configuration**

Set default text styles when creating or updating a campaign. These apply to all new creatives/slides:

```
default_text_style_variant: outline | background_white | background_color | background_color_solid
default_text_background_color: "#HEXCODE"
default_text_background_opacity: 0.0-1.0
default_text_layout: headline_subtext | single_block
```

Use `update-campaign.sh` to set these, or pass them when creating. Automation-specific overrides: `automation_text_style_variant`, `automation_text_background_color`, `automation_text_background_opacity`, `automation_text_layout`.

**Content Ideas**
```bash
# Generate ideas (async -- returns polling info)
bash $LAZYREEL_SKILL_DIR/scripts/generate-ideas.sh --offering-id offr_abc123 --id camp_def456 [--count 5]

# List ideas
bash $LAZYREEL_SKILL_DIR/scripts/list-content-ideas.sh --offering-id offr_abc123 --campaign-id camp_def456 [--status draft|approved|used|archived]

# Get a single idea
bash $LAZYREEL_SKILL_DIR/scripts/get-content-idea.sh --offering-id offr_abc123 --campaign-id camp_def456 --id idea_ghi789

# Approve or reject
bash $LAZYREEL_SKILL_DIR/scripts/approve-reject-idea.sh --offering-id offr_abc123 --campaign-id camp_def456 --id idea_ghi789 [--reject]

# Create a content idea manually
bash $LAZYREEL_SKILL_DIR/scripts/create-content-idea.sh --offering-id offr_abc123 --campaign-id camp_def456 --title "My Idea" [--concept "..."] [--hook-angle "..."] [--slide-content 'JSON'] [--generated-content 'JSON']
```

**Creatives**
```bash
# List creatives
bash $LAZYREEL_SKILL_DIR/scripts/list-creatives.sh --offering-id offr_abc123 --campaign-id camp_def456 [--status draft|pending|generating_content|finding_images|proofing|approved|generating_video|completed|failed]

# Get a creative
bash $LAZYREEL_SKILL_DIR/scripts/get-creative.sh --offering-id offr_abc123 --campaign-id camp_def456 --id crtv_ghi789

# Create a creative
bash $LAZYREEL_SKILL_DIR/scripts/create-creative.sh --offering-id offr_abc123 --campaign-id camp_def456 [--name "..."] [--idea-id idea_abc] [--template-id tmpl_abc] [--style-id arts_abc] [--transition none|push_left]

# Update a creative
bash $LAZYREEL_SKILL_DIR/scripts/update-creative.sh --offering-id offr_abc123 --campaign-id camp_def456 --id crtv_ghi789 [--name "..."] [--style-id arts_abc] [--post-title "..."] [--post-description "..."] [--post-hashtags "#tag"]

# Approve a creative for video generation
bash $LAZYREEL_SKILL_DIR/scripts/approve-creative.sh --offering-id offr_abc123 --campaign-id camp_def456 --id crtv_ghi789

# Archive / unarchive a creative
bash $LAZYREEL_SKILL_DIR/scripts/archive-creative.sh --offering-id offr_abc123 --campaign-id camp_def456 --id crtv_ghi789 [--unarchive]

# Generate images (async)
bash $LAZYREEL_SKILL_DIR/scripts/generate-images.sh --offering-id offr_abc123 --campaign-id camp_def456 --id crtv_ghi789

# Generate video (async)
bash $LAZYREEL_SKILL_DIR/scripts/generate-video.sh --offering-id offr_abc123 --campaign-id camp_def456 --id crtv_ghi789

# Generate assets ZIP (async)
bash $LAZYREEL_SKILL_DIR/scripts/generate-assets.sh --offering-id offr_abc123 --campaign-id camp_def456 --id crtv_ghi789

# Regenerate visual prompts for all slides
bash $LAZYREEL_SKILL_DIR/scripts/regenerate-prompts.sh --offering-id offr_abc123 --campaign-id camp_def456 --id crtv_ghi789 --description "dark moody aesthetic"

# Generate post title, description, and hashtags
bash $LAZYREEL_SKILL_DIR/scripts/generate-post-info.sh --offering-id offr_abc123 --campaign-id camp_def456 --id crtv_ghi789

# Post to TikTok
bash $LAZYREEL_SKILL_DIR/scripts/post-to-tiktok.sh --offering-id offr_abc123 --campaign-id camp_def456 --id crtv_ghi789 [--media-type video|photo]
```

**Slides**
```bash
# List slides for a creative
bash $LAZYREEL_SKILL_DIR/scripts/list-slides.sh --offering-id offr_abc123 --campaign-id camp_def456 --creative-id crtv_ghi789

# Get a slide
bash $LAZYREEL_SKILL_DIR/scripts/get-slide.sh --offering-id offr_abc123 --campaign-id camp_def456 --creative-id crtv_ghi789 --id slde_jkl012

# Create a slide
bash $LAZYREEL_SKILL_DIR/scripts/create-slide.sh --offering-id offr_abc123 --campaign-id camp_def456 --creative-id crtv_ghi789 [--type hook|content|cta|app_plug|problem|solution]

# Update a slide
bash $LAZYREEL_SKILL_DIR/scripts/update-slide.sh --offering-id offr_abc123 --campaign-id camp_def456 --creative-id crtv_ghi789 --id slde_jkl012 [--position N] [--duration N] [--type hook|content|cta|app_plug|problem|solution] [--hidden true|false] [--visual-prompt "..."] [--style-id arts_abc] [--text-elements 'JSON_ARRAY']

# Delete a slide
bash $LAZYREEL_SKILL_DIR/scripts/delete-slide.sh --offering-id offr_abc123 --campaign-id camp_def456 --creative-id crtv_ghi789 --id slde_jkl012

# Hide / unhide a slide
bash $LAZYREEL_SKILL_DIR/scripts/hide-slide.sh --offering-id offr_abc123 --campaign-id camp_def456 --creative-id crtv_ghi789 --id slde_jkl012 [--unhide]

# Move a slide
bash $LAZYREEL_SKILL_DIR/scripts/move-slide.sh --offering-id offr_abc123 --campaign-id camp_def456 --creative-id crtv_ghi789 --id slde_jkl012 --direction top|up|down|bottom

# Generate an image for a specific slide (async)
bash $LAZYREEL_SKILL_DIR/scripts/generate-slide-image.sh --offering-id offr_abc123 --campaign-id camp_def456 --creative-id crtv_ghi789 --id slde_jkl012

# Upload an image to a slide
bash $LAZYREEL_SKILL_DIR/scripts/upload-slide-image.sh --offering-id offr_abc123 --campaign-id camp_def456 --creative-id crtv_ghi789 --id slde_jkl012 --image-url "https://..."
bash $LAZYREEL_SKILL_DIR/scripts/upload-slide-image.sh --offering-id offr_abc123 --campaign-id camp_def456 --creative-id crtv_ghi789 --id slde_jkl012 --image-data "BASE64..." --filename "photo.jpg" --content-type "image/jpeg"
```

**Slide Text Elements**

Update slide text elements via `update-slide.sh --text-elements 'JSON_ARRAY'`. Each element:

```json
{
  "id": "uuid",
  "preset": "headline|subtext|caption|title|body|text",
  "text": "Your text here",
  "x": 11.0, "y": 20.0, "width": 78.0, "height": 15.0,
  "fontSize": "26px",
  "alignment": "left|center|right",
  "style_variant": "outline|background_white|background_color|background_color_solid",
  "background_color": "#4A5FBD",
  "background_opacity": 0.72
}
```

Coordinates are percentages of the 1080x1920 frame. Safe zone: x 11-89%, y 8-83%.

**Post Copy / Captions**

```bash
# Generate AI post title, description, and hashtags for a creative
bash $LAZYREEL_SKILL_DIR/scripts/generate-post-info.sh --offering-id offr_abc123 --campaign-id camp_def456 --id crtv_ghi789
```

Returns `post_title`, `post_description`, `post_hashtags` on the creative. These fields are also included in every creative GET response. To regenerate, clear the fields first via `update-creative.sh --post-title "" --post-description "" --post-hashtags ""`.

**Niche Discoveries**
```bash
# List niche discoveries
bash $LAZYREEL_SKILL_DIR/scripts/list-niche-discoveries.sh --offering-id offr_abc123 --campaign-id camp_def456

# Get a niche discovery
bash $LAZYREEL_SKILL_DIR/scripts/get-niche-discovery.sh --offering-id offr_abc123 --campaign-id camp_def456 --id ndsc_ghi789

# Create a niche discovery
bash $LAZYREEL_SKILL_DIR/scripts/create-niche-discovery.sh --offering-id offr_abc123 --campaign-id camp_def456 --name "Fitness Trends" [--interval-hours 24] [--auto-reimagine] [--auto-reimagine-limit 5]

# Update a niche discovery
bash $LAZYREEL_SKILL_DIR/scripts/update-niche-discovery.sh --offering-id offr_abc123 --campaign-id camp_def456 --id ndsc_ghi789 [--name "..."] [--interval-hours 24] [--auto-reimagine true|false] [--auto-reimagine-limit 5]

# Delete a niche discovery
bash $LAZYREEL_SKILL_DIR/scripts/delete-niche-discovery.sh --offering-id offr_abc123 --campaign-id camp_def456 --id ndsc_ghi789

# Run a niche discovery (async)
bash $LAZYREEL_SKILL_DIR/scripts/run-niche-discovery.sh --offering-id offr_abc123 --campaign-id camp_def456 --id ndsc_ghi789

# Pause / resume a niche discovery
bash $LAZYREEL_SKILL_DIR/scripts/pause-niche-discovery.sh --offering-id offr_abc123 --campaign-id camp_def456 --id ndsc_ghi789 [--resume]

# Refresh search terms (async)
bash $LAZYREEL_SKILL_DIR/scripts/refresh-niche-terms.sh --offering-id offr_abc123 --campaign-id camp_def456 --id ndsc_ghi789
```

**Discovered TikToks**
```bash
# List discovered TikToks
bash $LAZYREEL_SKILL_DIR/scripts/list-discovered-tiktoks.sh --offering-id offr_abc123 --campaign-id camp_def456 --niche-discovery-id ndsc_ghi789 [--status pending|analyzed|reimagined|dismissed]

# Get a discovered TikTok
bash $LAZYREEL_SKILL_DIR/scripts/get-discovered-tiktok.sh --offering-id offr_abc123 --campaign-id camp_def456 --niche-discovery-id ndsc_ghi789 --id dtkt_jkl012

# Analyze a discovered TikTok (async)
bash $LAZYREEL_SKILL_DIR/scripts/analyze-discovered-tiktok.sh --offering-id offr_abc123 --campaign-id camp_def456 --niche-discovery-id ndsc_ghi789 --id dtkt_jkl012

# Reimagine as a new creative (async)
bash $LAZYREEL_SKILL_DIR/scripts/reimagine-discovered-tiktok.sh --offering-id offr_abc123 --campaign-id camp_def456 --niche-discovery-id ndsc_ghi789 --id dtkt_jkl012

# Dismiss a discovered TikTok
bash $LAZYREEL_SKILL_DIR/scripts/dismiss-discovered-tiktok.sh --offering-id offr_abc123 --campaign-id camp_def456 --niche-discovery-id ndsc_ghi789 --id dtkt_jkl012

# Ingest a TikTok by URL
bash $LAZYREEL_SKILL_DIR/scripts/ingest-tiktok.sh --url "https://www.tiktok.com/@user/video/123" [--offering-id offr_abc123] [--campaign-id camp_def456]
```

**Seed Ideas**
```bash
# List seed ideas
bash $LAZYREEL_SKILL_DIR/scripts/list-seed-ideas.sh --offering-id offr_abc123 --campaign-id camp_def456 [--status active|used|archived]

# Get a seed idea
bash $LAZYREEL_SKILL_DIR/scripts/get-seed-idea.sh --offering-id offr_abc123 --campaign-id camp_def456 --id seed_ghi789

# Create a seed idea
bash $LAZYREEL_SKILL_DIR/scripts/create-seed-idea.sh --offering-id offr_abc123 --campaign-id camp_def456 --topic "How to..." [--content "..."] [--category "..."] [--position N] [--status active|used|archived]

# Update a seed idea
bash $LAZYREEL_SKILL_DIR/scripts/update-seed-idea.sh --offering-id offr_abc123 --campaign-id camp_def456 --id seed_ghi789 [--topic "..."] [--content "..."] [--category "..."] [--position N] [--status active|used|archived]

# Delete a seed idea
bash $LAZYREEL_SKILL_DIR/scripts/delete-seed-idea.sh --offering-id offr_abc123 --campaign-id camp_def456 --id seed_ghi789
```

**Performance Tracking (The Lazy Loop)**
```bash
# Get the daily performance report (diagnostics + hooks + conversions + recommendations)
bash $LAZYREEL_SKILL_DIR/scripts/get-daily-report.sh --offering-id offr_abc123

# List hook performances
bash $LAZYREEL_SKILL_DIR/scripts/list-hook-performances.sh --offering-id offr_abc123 [--status double_down|keep|testing|try_variation|dropped] [--format-category question|listicle|insider|contrarian|how_to|reveal|person_conflict|transformation|behavioral_callout|authority|social_proof|interactive] [--min-views 10000]

# List CTA variants
bash $LAZYREEL_SKILL_DIR/scripts/list-cta-variants.sh --offering-id offr_abc123 [--status active|winner|retired]

# Run diagnostics (async)
bash $LAZYREEL_SKILL_DIR/scripts/run-diagnostics.sh --offering-id offr_abc123

# Post a conversion event
bash $LAZYREEL_SKILL_DIR/scripts/post-conversion-event.sh --source custom --event-type download --occurred-at "2026-03-24T12:00:00Z" [--amount-cents 999] [--customer-id cus_123]
```

**TikTok Accounts (read-only)**
```bash
# List connected TikTok accounts
bash $LAZYREEL_SKILL_DIR/scripts/list-tiktok-accounts.sh

# Get a TikTok account
bash $LAZYREEL_SKILL_DIR/scripts/get-tiktok-account.sh --id ttak_abc123
```

**Photo Collections**
```bash
# List photo collections
source "$LAZYREEL_SKILL_DIR/scripts/api.sh"
api_get "/offerings/offr_abc123/photo_collections" | jq .

# Upload images to a collection (via URL -- server fetches them)
bash $LAZYREEL_SKILL_DIR/scripts/upload-collection-images.sh --offering-id offr_abc123 --collection-id pcol_def456 --image-urls "https://example.com/a.jpg,https://example.com/b.jpg"
```

**Reference Data (read-only)**
```bash
# List artwork styles
bash $LAZYREEL_SKILL_DIR/scripts/list-artwork-styles.sh [--page N]

# List creative templates
bash $LAZYREEL_SKILL_DIR/scripts/list-creative-templates.sh [--page N]

# List content aesthetics
bash $LAZYREEL_SKILL_DIR/scripts/list-content-aesthetics.sh
```

**Polling Async Operations**
```bash
# Poll until terminal state
bash $LAZYREEL_SKILL_DIR/scripts/poll-status.sh --url "/api/v1/offerings/offr_.../creatives/crtv_..." --field "data.status" --done "completed,failed" [--interval 3] [--max-polls 60]
```
</operations>

<workflow_lazy_loop>
The Lazy Loop -- self-improving content feedback cycle:

1. `get-daily-report.sh` -- check today's diagnostics and recommendations
2. Interpret the quadrant breakdown:
   - **scale**: High views + high conversions. Create variations of winning hooks.
   - **fix_cta**: High views but low conversions. Keep hooks, test new CTAs.
   - **fix_hook**: Low views but high conversions. Try new hook formats, keep CTAs.
   - **full_reset**: Low views + low conversions. Try a completely different angle.
3. `list-hook-performances.sh --status double_down` -- find hooks to create variations of
4. `list-cta-variants.sh --status winner` -- find best-performing CTAs to reuse
5. `generate-ideas.sh` -- generate new content (diagnostics are automatically injected into prompts)
6. Continue with content pipeline (create creative, generate images, etc.)
7. `post-conversion-event.sh` -- report conversions as they come in (attribution is automatic)
8. `list-hook-performances.sh` -- check how hooks are performing (scored daily)

Hook scoring thresholds:
- 50K+ views -> `double_down`
- 10K-50K views -> `keep`
- 1K-10K views -> `try_variation`
- <1K views (used 2+ times) -> `dropped`
</workflow_lazy_loop>

<async_operations>
Async operations return a poll action in `next_actions`:

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

Use `poll-status.sh` with the returned polling metadata:
```bash
bash $LAZYREEL_SKILL_DIR/scripts/poll-status.sh \
  --url "/api/v1/offerings/offr_.../creatives/crtv_..." \
  --field "result.status" \
  --done "proofing,failed" \
  --interval 5
```
</async_operations>

<creative_states>
Creative state machine progression:
`draft` -> `pending` -> `generating_content` -> `finding_images` -> `proofing` -> `approved` -> `generating_video` -> `completed`

Any state can transition to `failed`. Use get-creative to check current status.
</creative_states>

<workflow_content_pipeline>
Standard content creation flow:

1. `list-offerings.sh` -- find the offering
2. `list-campaigns.sh` -- find or create a campaign
3. `generate-ideas.sh` -- generate AI content ideas
4. `list-content-ideas.sh` -- review generated ideas
5. `approve-reject-idea.sh` -- approve the best ideas
6. `create-creative.sh` -- create a creative from an approved idea
7. `list-slides.sh` -- review initial slides
8. `update-slide.sh` / `create-slide.sh` / `delete-slide.sh` -- edit slide content
9. `move-slide.sh` / `hide-slide.sh` -- reorder or hide slides
10. `generate-images.sh` -- trigger AI image generation for all slides
11. `poll-status.sh` -- wait for images to complete
12. `generate-slide-image.sh` / `upload-slide-image.sh` -- regenerate or replace individual slide images
13. `approve-creative.sh` -- approve the creative
14. `generate-video.sh` -- render the final video
15. `poll-status.sh` -- wait for video to complete
16. `post-to-tiktok.sh` -- post the completed video to TikTok
</workflow_content_pipeline>

<workflow_niche_discovery>
Niche discovery pipeline:

1. `create-niche-discovery.sh` -- set up a discovery with search terms
2. `run-niche-discovery.sh` -- trigger a discovery run
3. `list-discovered-tiktoks.sh` -- review discovered TikToks
4. `analyze-discovered-tiktok.sh` -- analyze a promising TikTok
5. `reimagine-discovered-tiktok.sh` -- reimagine as a new creative
6. `get-creative.sh` -- review the reimagined creative
7. Continue from step 7 of the content pipeline
</workflow_niche_discovery>

<workflow_ingest_remix>
Ingest and remix a TikTok by URL:

1. `ingest-tiktok.sh` -- ingest a TikTok URL (auto-analyzes)
2. `get-discovered-tiktok.sh` -- review the analysis
3. `reimagine-discovered-tiktok.sh` -- reimagine as a new creative
4. Continue from step 7 of the content pipeline
</workflow_ingest_remix>

<references>
- `references/api-reference.md` -- Full API endpoint documentation
- `references/openapi-v1.yaml` -- OpenAPI 3.0 spec (fetch latest: `GET /openapi`)
</references>
