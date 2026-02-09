# LazyReel API Claude Code Skill

A [Claude Code](https://docs.anthropic.com/en/docs/claude-code) skill for managing [LazyReel](https://lazyreel.com) content marketing campaigns, creatives, and AI video generation directly from your terminal.

## What it does

- Browse offerings and campaigns
- Create and manage marketing campaigns
- Generate AI content ideas and approve/reject them
- Create creatives from approved ideas
- Trigger AI image generation and video rendering
- Monitor async operations (image gen, video rendering)
- View and update individual slides with text elements
- Browse artwork styles and creative templates

## Install

Clone this repo into your Claude Code skills directory:

```bash
git clone https://github.com/clayton/lazyreel-api-skill.git ~/.claude/skills/lazyreel-api
```

Add your LazyReel API token to `~/.claude/.env`:

```bash
echo "LAZYREEL_API_TOKEN=lr_your_token_here" >> ~/.claude/.env
```

Tokens can be created in the LazyReel web app under **Settings > API Tokens** (requires owner or admin role).

## Usage

Once installed, Claude Code will automatically use this skill when you ask about LazyReel. Examples:

- "List my LazyReel offerings"
- "Create a new campaign for my product"
- "Generate 5 content ideas for my summer campaign"
- "Approve the best content idea and create a creative from it"
- "Generate images for the creative and render the video"
- "What's the status of my video generation?"
- "Show me the available artwork styles"

## Content Pipeline

The standard workflow follows this flow:

1. **List offerings** -- find your product/service
2. **List/create campaigns** -- organize your marketing efforts
3. **Generate ideas** -- AI generates content concepts
4. **Review & approve ideas** -- curate the best ideas
5. **Create creative** -- build a creative from an approved idea
6. **Generate images** -- AI generates images for each slide
7. **Generate video** -- render the final video from slides
8. **Download assets** -- get a ZIP of all slide images

## Scripts

| Script | Description |
|--------|-------------|
| `list-offerings.sh` | List all offerings |
| `get-offering.sh` | Get offering details |
| `list-campaigns.sh` | List campaigns with filtering |
| `get-campaign.sh` | Get campaign details |
| `create-campaign.sh` | Create a new campaign |
| `update-campaign.sh` | Update campaign settings |
| `archive-campaign.sh` | Archive/unarchive a campaign |
| `generate-ideas.sh` | Generate AI content ideas (async) |
| `list-content-ideas.sh` | List content ideas |
| `get-content-idea.sh` | Get idea details |
| `approve-reject-idea.sh` | Approve or reject an idea |
| `list-creatives.sh` | List creatives |
| `get-creative.sh` | Get creative details |
| `create-creative.sh` | Create a new creative |
| `update-creative.sh` | Update creative settings |
| `generate-images.sh` | Generate AI images (async) |
| `generate-video.sh` | Render video (async) |
| `generate-assets.sh` | Generate assets ZIP (async) |
| `list-slides.sh` | List slides for a creative |
| `get-slide.sh` | Get slide details |
| `update-slide.sh` | Update slide content |
| `list-artwork-styles.sh` | List available artwork styles |
| `list-creative-templates.sh` | List creative templates |
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

## Requirements

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code)
- `curl` and `jq`
- A LazyReel account with an API token

## API Rate Limit

60 requests per 60-second window. Scripts are designed for reasonable usage within this limit.

## License

MIT
