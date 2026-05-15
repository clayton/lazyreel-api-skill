# LazyReel API Skill for Codex and Claude Code

A skill for managing [LazyReel](https://lazyreel.com) content marketing campaigns, creatives, and AI video generation directly from Codex or [Claude Code](https://docs.anthropic.com/en/docs/claude-code).

## What it does

- Browse and create offerings
- Create and manage marketing campaigns
- Generate AI content ideas and approve/reject them
- Create creatives from approved ideas
- Manage slides: create, edit, reorder, hide, delete
- Trigger AI image generation and video rendering
- Upload custom images to slides
- Discover trending TikToks via niche discovery
- Analyze and reimagine discovered content
- Ingest TikToks by URL for remixing
- Manage seed ideas for content direction
- Post completed videos to TikTok
- Monitor async operations (image gen, video rendering, analysis)
- View and manage connected TikTok accounts
- Browse artwork styles and creative templates

## Install

Clone this repo into the skills directory for the agent you use:

```bash
# Codex
git clone https://github.com/clayton/lazyreel-api-skill.git ~/.codex/skills/lazyreel-api

# Claude Code
git clone https://github.com/clayton/lazyreel-api-skill.git ~/.claude/skills/lazyreel-api
```

Add your LazyReel API token to the matching agent env file:

```bash
# Codex
echo "LAZYREEL_API_TOKEN=lr_your_token_here" >> ~/.codex/.env

# Claude Code
echo "LAZYREEL_API_TOKEN=lr_your_token_here" >> ~/.claude/.env
```

Tokens can be created in the LazyReel web app under **Settings > API Tokens** (requires owner or admin role).

## Usage

Once installed, Codex or Claude Code will automatically use this skill when you ask about LazyReel. Examples:

- "List my LazyReel offerings"
- "Create a new campaign for my product"
- "Generate 5 content ideas for my summer campaign"
- "Approve the best content idea and create a creative from it"
- "Generate images for the creative and render the video"
- "What's the status of my video generation?"
- "Set up a niche discovery to find trending fitness TikToks"
- "Reimagine that discovered TikTok as a new creative"
- "Post the completed video to TikTok"
- "Add some seed ideas to guide my campaign's content"

## Content Pipeline

The standard workflow follows this flow:

1. **List offerings** -- find your product/service
2. **List/create campaigns** -- organize your marketing efforts
3. **Generate ideas** -- AI generates content concepts
4. **Review & approve ideas** -- curate the best ideas
5. **Create creative** -- build a creative from an approved idea
6. **Edit slides** -- adjust slide content, reorder, hide/show
7. **Generate images** -- AI generates images for each slide
8. **Review & adjust** -- regenerate or upload individual slide images
9. **Approve creative** -- approve for video rendering
10. **Generate video** -- render the final video from slides
11. **Post to TikTok** -- publish to your connected TikTok account

## Niche Discovery Pipeline

Discover and remix trending content:

1. **Create niche discovery** -- define search terms and schedule
2. **Run discovery** -- find trending TikToks in your niche
3. **Review discovered TikToks** -- browse results with engagement metrics
4. **Analyze** -- extract content insights from a TikTok
5. **Reimagine** -- create a new creative inspired by the original
6. **Edit & publish** -- continue from step 6 of the content pipeline

You can also ingest any TikTok URL directly with `ingest-tiktok.sh`.

## Scripts

| Script | Description |
|--------|-------------|
| **Offerings** | |
| `list-offerings.sh` | List all offerings |
| `get-offering.sh` | Get offering details |
| `create-offering.sh` | Create a new offering |
| `update-offering.sh` | Update offering settings |
| **Campaigns** | |
| `list-campaigns.sh` | List campaigns with filtering |
| `get-campaign.sh` | Get campaign details |
| `create-campaign.sh` | Create a new campaign |
| `update-campaign.sh` | Update campaign settings |
| `archive-campaign.sh` | Archive/unarchive a campaign |
| **Content Ideas** | |
| `generate-ideas.sh` | Generate AI content ideas (async) |
| `list-content-ideas.sh` | List content ideas |
| `get-content-idea.sh` | Get idea details |
| `create-content-idea.sh` | Create a content idea manually |
| `approve-reject-idea.sh` | Approve or reject an idea |
| **Creatives** | |
| `list-creatives.sh` | List creatives |
| `get-creative.sh` | Get creative details |
| `create-creative.sh` | Create a new creative |
| `update-creative.sh` | Update creative settings |
| `approve-creative.sh` | Approve a creative |
| `archive-creative.sh` | Archive/unarchive a creative |
| `generate-images.sh` | Generate AI images (async) |
| `generate-video.sh` | Render video (async) |
| `generate-assets.sh` | Generate assets ZIP (async) |
| `regenerate-prompts.sh` | Regenerate visual prompts |
| `generate-post-info.sh` | Generate post title/description/hashtags |
| `post-to-tiktok.sh` | Post to TikTok |
| **Slides** | |
| `list-slides.sh` | List slides for a creative |
| `get-slide.sh` | Get slide details |
| `create-slide.sh` | Create a new slide |
| `update-slide.sh` | Update slide content |
| `delete-slide.sh` | Delete a slide |
| `hide-slide.sh` | Hide/unhide a slide |
| `move-slide.sh` | Move a slide (top/up/down/bottom) |
| `generate-slide-image.sh` | Generate image for one slide (async) |
| `upload-slide-image.sh` | Upload image to a slide |
| **Niche Discoveries** | |
| `list-niche-discoveries.sh` | List niche discoveries |
| `get-niche-discovery.sh` | Get niche discovery details |
| `create-niche-discovery.sh` | Create a niche discovery |
| `update-niche-discovery.sh` | Update a niche discovery |
| `delete-niche-discovery.sh` | Delete a niche discovery |
| `run-niche-discovery.sh` | Run a discovery (async) |
| `pause-niche-discovery.sh` | Pause/resume a discovery |
| `refresh-niche-terms.sh` | Refresh search terms (async) |
| **Discovered TikToks** | |
| `list-discovered-tiktoks.sh` | List discovered TikToks |
| `get-discovered-tiktok.sh` | Get discovered TikTok details |
| `analyze-discovered-tiktok.sh` | Analyze a TikTok (async) |
| `reimagine-discovered-tiktok.sh` | Reimagine as new creative (async) |
| `dismiss-discovered-tiktok.sh` | Dismiss a discovered TikTok |
| `ingest-tiktok.sh` | Ingest a TikTok by URL |
| **Seed Ideas** | |
| `list-seed-ideas.sh` | List seed ideas |
| `get-seed-idea.sh` | Get seed idea details |
| `create-seed-idea.sh` | Create a seed idea |
| `update-seed-idea.sh` | Update a seed idea |
| `delete-seed-idea.sh` | Delete a seed idea |
| **TikTok Accounts** | |
| `list-tiktok-accounts.sh` | List connected TikTok accounts |
| `get-tiktok-account.sh` | Get TikTok account details |
| **Reference Data** | |
| `list-artwork-styles.sh` | List available artwork styles |
| `list-creative-templates.sh` | List creative templates |
| `list-content-aesthetics.sh` | List content aesthetics |
| **Utilities** | |
| `poll-status.sh` | Poll async operation status |

## Prefix IDs

All resources use human-readable prefix IDs:

| Resource | Prefix | Example |
|----------|--------|---------|
| Offering | `offr_` | `offr_a1b2c3d4e5f6` |
| Campaign | `camp_` | `camp_a1b2c3d4e5f6` |
| Content Idea | `idea_` | `idea_a1b2c3d4e5f6` |
| Creative | `crtv_` | `crtv_a1b2c3d4e5f6` |
| Slide | `slde_` | `slde_a1b2c3d4e5f6` |
| Artwork Style | `arts_` | `arts_a1b2c3d4e5f6` |
| Creative Template | `tmpl_` | `tmpl_a1b2c3d4e5f6` |
| Photo Collection | `pcol_` | `pcol_a1b2c3d4e5f6` |
| Niche Discovery | `ndsc_` | `ndsc_a1b2c3d4e5f6` |
| Discovered TikTok | `dtkt_` | `dtkt_a1b2c3d4e5f6` |
| Seed Idea | `seed_` | `seed_a1b2c3d4e5f6` |
| TikTok Account | `ttak_` | `ttak_a1b2c3d4e5f6` |

## Requirements

- Codex or [Claude Code](https://docs.anthropic.com/en/docs/claude-code)
- `curl` and `jq`
- A LazyReel account with an API token

## API Rate Limit

60 requests per 60-second window. Scripts are designed for reasonable usage within this limit.

## License

MIT
