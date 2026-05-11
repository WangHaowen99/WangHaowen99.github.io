# GitHub Pages Hugo Blog Design

Date: 2026-05-11

## Goal

Create a personal blog site for the GitHub account `WangHaowen99` using the standard GitHub Pages user repository:

- Repository: `WangHaowen99/WangHaowen99.github.io`
- Public URL: `https://WangHaowen99.github.io`

The site should be similar in structure to `skyseraph.github.io`: a static personal blog with Markdown-authored posts, article metadata, tags, series, project pages, life notes, author profile, table of contents, previous/next navigation, and comments.

The visual style should not copy the reference site's dark cyber style. It should use a Google-like minimal visual language: light background, high readability, restrained borders, generous whitespace, blue accent color, clear hierarchy, and minimal decoration.

## Requirements

### Content Workflow

- Authors write content primarily in Markdown.
- Hugo generates the static site from Markdown and layouts.
- GitHub Actions builds and deploys the site to GitHub Pages.
- The project should include starter Markdown content for each main section so the site is usable immediately.

### Navigation

Top-level navigation:

- 首页
- 文章
- 专栏
- 项目
- 生活
- About

The `闪念` section from the reference site is intentionally omitted.

### Identity

Site owner:

- Name: `WangHaowen99`
- Tagline: `如无必要，勿增实体。AI for ALL & ALL for AI`

The tagline should appear on the homepage and in appropriate metadata.

### Pages And Sections

The site should include:

- Home page with profile summary, latest posts, featured series, and projects.
- Articles index at `/posts/`.
- Individual article pages under `/posts/YYYY/slug/`.
- Series index at `/series/`.
- Individual series taxonomy pages when posts specify a series.
- Projects page at `/projects/`.
- Life page at `/life/`.
- About page at `/about/`.
- Category and tag taxonomy pages.
- RSS output for posts.

### Article Pages

Article pages should include:

- Title.
- Date.
- Category.
- Tags.
- Reading time.
- Generated table of contents for long articles.
- Markdown body rendered with readable typography.
- Code blocks.
- Tables.
- Blockquotes.
- Author signature.
- Previous and next post navigation.
- Giscus comments section.

The table of contents should appear as a sticky right sidebar on wide screens and be hidden or simplified on small screens.

### Comments

Use Giscus for comments.

Implementation should include a partial or layout hook for Giscus with configuration values in Hugo config. The code should tolerate missing Giscus IDs by hiding the comment widget and showing no broken UI.

Repository Discussions must be enabled for `WangHaowen99/WangHaowen99.github.io`. The Giscus GitHub App may require manual authorization in the browser. The implementation should document the required Giscus setup steps.

### Visual Design

Use a light, Google-like minimal style:

- Background: white or near-white.
- Text: dark neutral.
- Accent: Google-style blue.
- Secondary accents may use subtle Google red/yellow/green only sparingly.
- Borders: thin neutral gray.
- Cards: minimal, flat, small radius.
- No gradient-orb decoration.
- No dark cyber theme.
- No heavy shadows.
- No crowded decorative hero.

The site should prioritize reading comfort:

- Comfortable body text width.
- Clear heading scale.
- Good Chinese and English font stack.
- Strong table readability.
- Accessible focus states.
- Responsive mobile layout.

### Technical Architecture

Use Hugo with a local custom theme/layout rather than a third-party theme. This keeps the code small, predictable, and tailored to the requested visual style.

Expected structure:

```text
.
├── .github/workflows/hugo.yml
├── archetypes/default.md
├── assets/css/main.css
├── content/
│   ├── _index.md
│   ├── about.md
│   ├── life/_index.md
│   ├── posts/
│   ├── projects/_index.md
│   └── series/_index.md
├── hugo.toml
├── layouts/
│   ├── _default/
│   ├── index.html
│   ├── partials/
│   └── taxonomy/
└── static/
```

Use Hugo Pipes for CSS bundling if practical, but keep the setup simple enough for GitHub Actions to build reliably.

### Deployment

Deployment target:

- GitHub Pages from GitHub Actions.
- Default branch: `main`.
- Build command: `hugo --minify`.
- Publish directory: `public`.

The repository should be created as `WangHaowen99.github.io` under the authenticated GitHub account `WangHaowen99`.

### Initial Content

Add starter content so the site is not empty:

- A homepage introduction using the approved tagline.
- One sample technical post explaining the site setup.
- A projects page with placeholder project entries that can be edited later.
- A life page with a short introductory note.
- An About page with owner identity and links.

Sample content should be clearly editable and avoid pretending to be final biography content beyond the approved identity and tagline.

## Non-Goals

- Do not implement a heavy SPA.
- Do not add a CMS.
- Do not copy the reference site's exact assets, avatar, content, comments config, or branding.
- Do not include the `闪念` section.
- Do not require a backend server.
- Do not rely on a remote third-party Hugo theme.

## Open Setup Notes

- GitHub CLI is authenticated as `WangHaowen99`.
- The standard user Pages repository did not exist when checked.
- Global git user name and email were not configured; local repository config can use `WangHaowen99` and the GitHub noreply email `WangHaowen99@users.noreply.github.com`.
- Giscus requires GitHub Discussions and likely manual Giscus App authorization.

## Acceptance Criteria

- `hugo` builds successfully locally.
- The generated site has the requested navigation and pages.
- Markdown posts render with metadata, tags, TOC, author signature, previous/next navigation, and optional Giscus comments.
- The visual result is light, minimal, and closer to Google-style clarity than to the reference site's dark theme.
- GitHub repository `WangHaowen99/WangHaowen99.github.io` exists and contains the site source.
- GitHub Pages is configured to deploy from Actions.
- The site is reachable at `https://WangHaowen99.github.io` after GitHub Pages finishes deployment.

