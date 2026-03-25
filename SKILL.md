---
name: lazyreel-api
description: Manage LazyReel content marketing campaigns, creatives, AI video generation, niche discovery, seed ideas, TikTok posting, and slide manipulation via the LazyReel REST API. Full CRUD for offerings, campaigns, content ideas, creatives, slides, niche discoveries, discovered TikToks, seed ideas, and TikTok accounts.
---

<objective>
Interact with the LazyReel API to manage content marketing workflows: browse and create offerings, create and manage campaigns, generate AI content ideas, build creatives with slides, trigger image/video generation, discover trending TikToks, reimagine content, manage seed ideas, and post to TikTok. Use the shell scripts in this skill's `scripts/` directory for all API calls.
</objective>

<env>
Required: `LAZYREEL_API_TOKEN` in `~/.claude/.env`
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

**Performance Tracking (The Larry Loop)**
- **HookPerformance**: Tracks hook text effectiveness with LLM-classified format categories and Larry's decision statuses (testing/double_down/keep/try_variation/dropped)
- **ConversionEvent**: Conversion intake from external sources (RevenueCat/Stripe/custom) with timing-based attribution to creatives
- **DiagnosticReport**: Daily quadrant analysis (scale/fix_cta/fix_hook/full_reset)
- **CtaVariant**: CTA text tracking with conversion rates
- **DailyReport**: Composite view combining diagnostics, hook performance, conversions, and recommendations
</domain_model>

<operations>
All scripts are in `~/.claude/skills/lazyreel-api/scripts/`.

**Offerings**
```bash
# List all offerings
bash ~/.claude/skills/lazyreel-api/scripts/list-offerings.sh [--page N] [--per-page N]

# Get a single offering
bash ~/.claude/skills/lazyreel-api/scripts/get-offering.sh --id offr_abc123

# Update an offering
bash ~/.claude/skills/lazyreel-api/scripts/update-offering.sh --id offr_abc123 [--name "..."] [--description "..."]

# Create an offering
bash ~/.claude/skills/lazyreel-api/scripts/create-offering.sh --name "My Product" [--description "..."] [--target-audience "..."] [--differentiator "..."] [--tone-voice "..."] [--brand-promise "..."] [--content-aesthetic "..."] [--english-dialect "..."]
```

**Campaigns**
```bash
# List campaigns for an offering
bash ~/.claude/skills/lazyreel-api/scripts/list-campaigns.sh --offering-id offr_abc123 [--status draft|active|paused] [--archived] [--page N]

# Get a campaign
bash ~/.claude/skills/lazyreel-api/scripts/get-campaign.sh --offering-id offr_abc123 --id camp_def456

# Create a campaign
bash ~/.claude/skills/lazyreel-api/scripts/create-campaign.sh --offering-id offr_abc123 --name "Summer Launch" [--goal engagement|brand_awareness|traffic|sales] [--brief "..."] [--template-id tmpl_abc] [--style-ids "arts_a,arts_b"]

# Update a campaign
bash ~/.claude/skills/lazyreel-api/scripts/update-campaign.sh --offering-id offr_abc123 --id camp_def456 [--name "..."] [--status draft|active|paused] [--goal ...] [--brief "..."]

# Archive / unarchive
bash ~/.claude/skills/lazyreel-api/scripts/archive-campaign.sh --offering-id offr_abc123 --id camp_def456 [--unarchive]
```

**Content Ideas**
```bash
# Generate ideas (async -- returns polling info)
bash ~/.claude/skills/lazyreel-api/scripts/generate-ideas.sh --offering-id offr_abc123 --id camp_def456 [--count 5]

# List ideas
bash ~/.claude/skills/lazyreel-api/scripts/list-content-ideas.sh --offering-id offr_abc123 --campaign-id camp_def456 [--status draft|approved|used|archived]

# Get a single idea
bash ~/.claude/skills/lazyreel-api/scripts/get-content-idea.sh --offering-id offr_abc123 --campaign-id camp_def456 --id idea_ghi789

# Approve or reject
bash ~/.claude/skills/lazyreel-api/scripts/approve-reject-idea.sh --offering-id offr_abc123 --campaign-id camp_def456 --id idea_ghi789 [--reject]

# Create a content idea manually
bash ~/.claude/skills/lazyreel-api/scripts/create-content-idea.sh --offering-id offr_abc123 --campaign-id camp_def456 --title "My Idea" [--concept "..."] [--hook-angle "..."] [--slide-content 'JSON'] [--generated-content 'JSON']
```

**Creatives**
```bash
# List creatives
bash ~/.claude/skills/lazyreel-api/scripts/list-creatives.sh --offering-id offr_abc123 --campaign-id camp_def456 [--status draft|pending|generating_content|finding_images|proofing|approved|generating_video|completed|failed]

# Get a creative
bash ~/.claude/skills/lazyreel-api/scripts/get-creative.sh --offering-id offr_abc123 --campaign-id camp_def456 --id crtv_ghi789

# Create a creative
bash ~/.claude/skills/lazyreel-api/scripts/create-creative.sh --offering-id offr_abc123 --campaign-id camp_def456 [--name "..."] [--idea-id idea_abc] [--template-id tmpl_abc] [--style-id arts_abc] [--transition none|push_left]

# Update a creative
bash ~/.claude/skills/lazyreel-api/scripts/update-creative.sh --offering-id offr_abc123 --campaign-id camp_def456 --id crtv_ghi789 [--name "..."] [--style-id arts_abc] [--post-title "..."] [--post-description "..."] [--post-hashtags "#tag"]

# Approve a creative for video generation
bash ~/.claude/skills/lazyreel-api/scripts/approve-creative.sh --offering-id offr_abc123 --campaign-id camp_def456 --id crtv_ghi789

# Archive / unarchive a creative
bash ~/.claude/skills/lazyreel-api/scripts/archive-creative.sh --offering-id offr_abc123 --campaign-id camp_def456 --id crtv_ghi789 [--unarchive]

# Generate images (async)
bash ~/.claude/skills/lazyreel-api/scripts/generate-images.sh --offering-id offr_abc123 --campaign-id camp_def456 --id crtv_ghi789

# Generate video (async)
bash ~/.claude/skills/lazyreel-api/scripts/generate-video.sh --offering-id offr_abc123 --campaign-id camp_def456 --id crtv_ghi789

# Generate assets ZIP (async)
bash ~/.claude/skills/lazyreel-api/scripts/generate-assets.sh --offering-id offr_abc123 --campaign-id camp_def456 --id crtv_ghi789

# Regenerate visual prompts for all slides
bash ~/.claude/skills/lazyreel-api/scripts/regenerate-prompts.sh --offering-id offr_abc123 --campaign-id camp_def456 --id crtv_ghi789 --description "dark moody aesthetic"

# Generate post title, description, and hashtags
bash ~/.claude/skills/lazyreel-api/scripts/generate-post-info.sh --offering-id offr_abc123 --campaign-id camp_def456 --id crtv_ghi789

# Post to TikTok
bash ~/.claude/skills/lazyreel-api/scripts/post-to-tiktok.sh --offering-id offr_abc123 --campaign-id camp_def456 --id crtv_ghi789 [--media-type video|photo]
```

**Slides**
```bash
# List slides for a creative
bash ~/.claude/skills/lazyreel-api/scripts/list-slides.sh --offering-id offr_abc123 --campaign-id camp_def456 --creative-id crtv_ghi789

# Get a slide
bash ~/.claude/skills/lazyreel-api/scripts/get-slide.sh --offering-id offr_abc123 --campaign-id camp_def456 --creative-id crtv_ghi789 --id slde_jkl012

# Create a slide
bash ~/.claude/skills/lazyreel-api/scripts/create-slide.sh --offering-id offr_abc123 --campaign-id camp_def456 --creative-id crtv_ghi789 [--type hook|content|cta|app_plug|problem|solution]

# Update a slide
bash ~/.claude/skills/lazyreel-api/scripts/update-slide.sh --offering-id offr_abc123 --campaign-id camp_def456 --creative-id crtv_ghi789 --id slde_jkl012 [--position N] [--duration N] [--type hook|content|cta|app_plug|problem|solution] [--hidden true|false] [--visual-prompt "..."] [--style-id arts_abc] [--text-elements 'JSON_ARRAY']

# Delete a slide
bash ~/.claude/skills/lazyreel-api/scripts/delete-slide.sh --offering-id offr_abc123 --campaign-id camp_def456 --creative-id crtv_ghi789 --id slde_jkl012

# Hide / unhide a slide
bash ~/.claude/skills/lazyreel-api/scripts/hide-slide.sh --offering-id offr_abc123 --campaign-id camp_def456 --creative-id crtv_ghi789 --id slde_jkl012 [--unhide]

# Move a slide
bash ~/.claude/skills/lazyreel-api/scripts/move-slide.sh --offering-id offr_abc123 --campaign-id camp_def456 --creative-id crtv_ghi789 --id slde_jkl012 --direction top|up|down|bottom

# Generate an image for a specific slide (async)
bash ~/.claude/skills/lazyreel-api/scripts/generate-slide-image.sh --offering-id offr_abc123 --campaign-id camp_def456 --creative-id crtv_ghi789 --id slde_jkl012

# Upload an image to a slide
bash ~/.claude/skills/lazyreel-api/scripts/upload-slide-image.sh --offering-id offr_abc123 --campaign-id camp_def456 --creative-id crtv_ghi789 --id slde_jkl012 --image-url "https://..."
bash ~/.claude/skills/lazyreel-api/scripts/upload-slide-image.sh --offering-id offr_abc123 --campaign-id camp_def456 --creative-id crtv_ghi789 --id slde_jkl012 --image-data "BASE64..." --filename "photo.jpg" --content-type "image/jpeg"
```

**Niche Discoveries**
```bash
# List niche discoveries
bash ~/.claude/skills/lazyreel-api/scripts/list-niche-discoveries.sh --offering-id offr_abc123 --campaign-id camp_def456

# Get a niche discovery
bash ~/.claude/skills/lazyreel-api/scripts/get-niche-discovery.sh --offering-id offr_abc123 --campaign-id camp_def456 --id ndsc_ghi789

# Create a niche discovery
bash ~/.claude/skills/lazyreel-api/scripts/create-niche-discovery.sh --offering-id offr_abc123 --campaign-id camp_def456 --name "Fitness Trends" [--interval-hours 24] [--auto-reimagine] [--auto-reimagine-limit 5]

# Update a niche discovery
bash ~/.claude/skills/lazyreel-api/scripts/update-niche-discovery.sh --offering-id offr_abc123 --campaign-id camp_def456 --id ndsc_ghi789 [--name "..."] [--interval-hours 24] [--auto-reimagine true|false] [--auto-reimagine-limit 5]

# Delete a niche discovery
bash ~/.claude/skills/lazyreel-api/scripts/delete-niche-discovery.sh --offering-id offr_abc123 --campaign-id camp_def456 --id ndsc_ghi789

# Run a niche discovery (async)
bash ~/.claude/skills/lazyreel-api/scripts/run-niche-discovery.sh --offering-id offr_abc123 --campaign-id camp_def456 --id ndsc_ghi789

# Pause / resume a niche discovery
bash ~/.claude/skills/lazyreel-api/scripts/pause-niche-discovery.sh --offering-id offr_abc123 --campaign-id camp_def456 --id ndsc_ghi789 [--resume]

# Refresh search terms (async)
bash ~/.claude/skills/lazyreel-api/scripts/refresh-niche-terms.sh --offering-id offr_abc123 --campaign-id camp_def456 --id ndsc_ghi789
```

**Discovered TikToks**
```bash
# List discovered TikToks
bash ~/.claude/skills/lazyreel-api/scripts/list-discovered-tiktoks.sh --offering-id offr_abc123 --campaign-id camp_def456 --niche-discovery-id ndsc_ghi789 [--status pending|analyzed|reimagined|dismissed]

# Get a discovered TikTok
bash ~/.claude/skills/lazyreel-api/scripts/get-discovered-tiktok.sh --offering-id offr_abc123 --campaign-id camp_def456 --niche-discovery-id ndsc_ghi789 --id dtkt_jkl012

# Analyze a discovered TikTok (async)
bash ~/.claude/skills/lazyreel-api/scripts/analyze-discovered-tiktok.sh --offering-id offr_abc123 --campaign-id camp_def456 --niche-discovery-id ndsc_ghi789 --id dtkt_jkl012

# Reimagine as a new creative (async)
bash ~/.claude/skills/lazyreel-api/scripts/reimagine-discovered-tiktok.sh --offering-id offr_abc123 --campaign-id camp_def456 --niche-discovery-id ndsc_ghi789 --id dtkt_jkl012

# Dismiss a discovered TikTok
bash ~/.claude/skills/lazyreel-api/scripts/dismiss-discovered-tiktok.sh --offering-id offr_abc123 --campaign-id camp_def456 --niche-discovery-id ndsc_ghi789 --id dtkt_jkl012

# Ingest a TikTok by URL
bash ~/.claude/skills/lazyreel-api/scripts/ingest-tiktok.sh --url "https://www.tiktok.com/@user/video/123" [--offering-id offr_abc123] [--campaign-id camp_def456]
```

**Seed Ideas**
```bash
# List seed ideas
bash ~/.claude/skills/lazyreel-api/scripts/list-seed-ideas.sh --offering-id offr_abc123 --campaign-id camp_def456 [--status active|used|archived]

# Get a seed idea
bash ~/.claude/skills/lazyreel-api/scripts/get-seed-idea.sh --offering-id offr_abc123 --campaign-id camp_def456 --id seed_ghi789

# Create a seed idea
bash ~/.claude/skills/lazyreel-api/scripts/create-seed-idea.sh --offering-id offr_abc123 --campaign-id camp_def456 --topic "How to..." [--content "..."] [--category "..."] [--position N] [--status active|used|archived]

# Update a seed idea
bash ~/.claude/skills/lazyreel-api/scripts/update-seed-idea.sh --offering-id offr_abc123 --campaign-id camp_def456 --id seed_ghi789 [--topic "..."] [--content "..."] [--category "..."] [--position N] [--status active|used|archived]

# Delete a seed idea
bash ~/.claude/skills/lazyreel-api/scripts/delete-seed-idea.sh --offering-id offr_abc123 --campaign-id camp_def456 --id seed_ghi789
```

**Performance Tracking (The Larry Loop)**
```bash
# Get the daily performance report (diagnostics + hooks + conversions + recommendations)
bash ~/.claude/skills/lazyreel-api/scripts/get-daily-report.sh --offering-id offr_abc123

# List hook performances
bash ~/.claude/skills/lazyreel-api/scripts/list-hook-performances.sh --offering-id offr_abc123 [--status double_down|keep|testing|try_variation|dropped] [--format-category question|listicle|insider|contrarian|how_to|reveal|person_conflict|transformation|behavioral_callout|authority|social_proof|interactive] [--min-views 10000]

# List CTA variants
bash ~/.claude/skills/lazyreel-api/scripts/list-cta-variants.sh --offering-id offr_abc123 [--status active|winner|retired]

# Run diagnostics (async)
bash ~/.claude/skills/lazyreel-api/scripts/run-diagnostics.sh --offering-id offr_abc123

# Post a conversion event
bash ~/.claude/skills/lazyreel-api/scripts/post-conversion-event.sh --source custom --event-type download --occurred-at "2026-03-24T12:00:00Z" [--amount-cents 999] [--customer-id cus_123]
```

**TikTok Accounts (read-only)**
```bash
# List connected TikTok accounts
bash ~/.claude/skills/lazyreel-api/scripts/list-tiktok-accounts.sh

# Get a TikTok account
bash ~/.claude/skills/lazyreel-api/scripts/get-tiktok-account.sh --id ttak_abc123
```

**Photo Collections (read-only)**
```bash
# No dedicated script yet -- use direct API calls:
# GET /offerings/{offering_id}/photo_collections
# GET /offerings/{offering_id}/photo_collections/{id}
# Example:
source ~/.claude/.env && /usr/bin/curl -s -H "Authorization: Bearer $LAZYREEL_API_TOKEN" \
  "https://lazyreel.com/api/v1/offerings/offr_abc123/photo_collections" | jq .
```

**Reference Data (read-only)**
```bash
# List artwork styles
bash ~/.claude/skills/lazyreel-api/scripts/list-artwork-styles.sh [--page N]

# List creative templates
bash ~/.claude/skills/lazyreel-api/scripts/list-creative-templates.sh [--page N]

# List content aesthetics
bash ~/.claude/skills/lazyreel-api/scripts/list-content-aesthetics.sh
```

**Polling Async Operations**
```bash
# Poll until terminal state
bash ~/.claude/skills/lazyreel-api/scripts/poll-status.sh --url "/api/v1/offerings/offr_.../creatives/crtv_..." --field "data.status" --done "completed,failed" [--interval 3] [--max-polls 60]
```
</operations>

<workflow_larry_loop>
The Larry Loop -- self-improving content feedback cycle:

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

Hook scoring thresholds (Larry's rules):
- 50K+ views -> `double_down`
- 10K-50K views -> `keep`
- 1K-10K views -> `try_variation`
- <1K views (used 2+ times) -> `dropped`
</workflow_larry_loop>

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
bash ~/.claude/skills/lazyreel-api/scripts/poll-status.sh \
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
