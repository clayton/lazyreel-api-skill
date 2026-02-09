---
name: lazyreel-api
description: Manage LazyReel content marketing campaigns, creatives, and AI video generation via the LazyReel REST API. List offerings, create campaigns, generate content ideas, manage creatives/slides, trigger image and video generation, and poll async operations.
---

<objective>
Interact with the LazyReel API to manage content marketing workflows: browse offerings, create and manage campaigns, generate AI content ideas, build creatives with slides, trigger image/video generation, and monitor async jobs. Use the shell scripts in this skill's `scripts/` directory for all API calls.
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
```

- **Offering**: Product/service being marketed
- **Campaign**: Marketing campaign with goal, brief, and automation settings
- **ContentIdea**: AI-generated content concept (approve/reject workflow)
- **Creative**: Final content piece (video/carousel) with a state machine
- **Slide**: Individual slide in a creative with text elements and images

All resources use prefix IDs: `offr_*`, `camp_*`, `idea_*`, `crtv_*`, `slde_*`, `arts_*`, `tmpl_*`
</domain_model>

<operations>
All scripts are in `~/.claude/skills/lazyreel-api/scripts/`.

**Offerings (read-only)**
```bash
# List all offerings
bash ~/.claude/skills/lazyreel-api/scripts/list-offerings.sh [--page N] [--per-page N]

# Get a single offering
bash ~/.claude/skills/lazyreel-api/scripts/get-offering.sh --id offr_abc123
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

# Generate images (async)
bash ~/.claude/skills/lazyreel-api/scripts/generate-images.sh --offering-id offr_abc123 --campaign-id camp_def456 --id crtv_ghi789

# Generate video (async)
bash ~/.claude/skills/lazyreel-api/scripts/generate-video.sh --offering-id offr_abc123 --campaign-id camp_def456 --id crtv_ghi789

# Generate assets ZIP (async)
bash ~/.claude/skills/lazyreel-api/scripts/generate-assets.sh --offering-id offr_abc123 --campaign-id camp_def456 --id crtv_ghi789
```

**Slides**
```bash
# List slides for a creative
bash ~/.claude/skills/lazyreel-api/scripts/list-slides.sh --offering-id offr_abc123 --campaign-id camp_def456 --creative-id crtv_ghi789

# Get a slide
bash ~/.claude/skills/lazyreel-api/scripts/get-slide.sh --offering-id offr_abc123 --campaign-id camp_def456 --creative-id crtv_ghi789 --id slde_jkl012

# Update a slide
bash ~/.claude/skills/lazyreel-api/scripts/update-slide.sh --offering-id offr_abc123 --campaign-id camp_def456 --creative-id crtv_ghi789 --id slde_jkl012 [--position N] [--duration N] [--type hook|content|cta|app_plug|problem|solution] [--hidden true|false] [--visual-prompt "..."] [--style-id arts_abc] [--text-elements 'JSON_ARRAY']
```

**Reference Data (read-only)**
```bash
# List artwork styles
bash ~/.claude/skills/lazyreel-api/scripts/list-artwork-styles.sh [--page N]

# List creative templates
bash ~/.claude/skills/lazyreel-api/scripts/list-creative-templates.sh [--page N]
```

**Polling Async Operations**
```bash
# Poll until terminal state
bash ~/.claude/skills/lazyreel-api/scripts/poll-status.sh --url "/api/v1/offerings/offr_.../creatives/crtv_..." --field "data.status" --done "completed,failed" [--interval 3] [--max-polls 60]
```
</operations>

<async_operations>
Image generation, video rendering, idea generation, and asset archiving return `202 Accepted` with polling metadata:

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

Use `poll-status.sh` with the returned polling metadata to wait for completion:
```bash
bash ~/.claude/skills/lazyreel-api/scripts/poll-status.sh \
  --url "/api/v1/offerings/offr_.../creatives/crtv_..." \
  --field "data.status" \
  --done "completed,failed" \
  --interval 3
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
7. `generate-images.sh` -- trigger AI image generation
8. `poll-status.sh` -- wait for images to complete
9. `list-slides.sh` -- review slides and images
10. `generate-video.sh` -- render the final video
11. `poll-status.sh` -- wait for video to complete
12. `get-creative.sh` -- get the final video URL
</workflow_content_pipeline>

<references>
- `references/api-reference.md` -- Full API endpoint documentation
</references>
