# GitHub Pages Hugo Blog Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build and deploy a Hugo-powered Markdown personal blog at `https://WangHaowen99.github.io`.

**Architecture:** Use Hugo as a static-site generator with local layouts and assets, no remote theme. Markdown content lives under `content/`, shared HTML is composed from Hugo partials, and GitHub Actions builds `public/` for GitHub Pages.

**Tech Stack:** Hugo `0.161.1`, Markdown, Hugo templates, CSS, GitHub Actions, GitHub Pages, Giscus.

---

## Scope Check

This is one cohesive subsystem: a static personal blog with deployment. It does not need to be split into separate specs. Giscus has one external manual authorization step, documented in this plan and in the site repository.

## File Structure

Create or modify these files:

```text
.
├── .github/workflows/hugo.yml
├── .gitignore
├── archetypes/default.md
├── assets/css/main.css
├── content/
│   ├── _index.md
│   ├── about.md
│   ├── life/
│   │   ├── _index.md
│   │   └── first-note.md
│   ├── posts/2026/building-this-site.md
│   └── projects/
│       ├── _index.md
│       └── personal-blog.md
├── docs/giscus.md
├── docs/superpowers/plans/2026-05-11-github-pages-hugo-blog.md
├── hugo.toml
├── layouts/
│   ├── _default/
│   │   ├── baseof.html
│   │   ├── list.html
│   │   ├── single.html
│   │   ├── term.html
│   │   └── terms.html
│   ├── index.html
│   └── partials/
│       ├── article-meta.html
│       ├── author-signature.html
│       ├── footer.html
│       ├── giscus.html
│       ├── head.html
│       ├── nav.html
│       ├── post-card.html
│       ├── post-nav.html
│       └── toc.html
└── scripts/
    ├── install-hugo.sh
    └── verify-site.sh
```

Responsibilities:

- `hugo.toml`: site metadata, menus, taxonomies, markup, and Giscus settings.
- `layouts/_default/baseof.html`: global page shell.
- `layouts/partials/*.html`: navigation, metadata, comments, TOC, footer, and reusable cards.
- `layouts/index.html`: homepage composition.
- `layouts/_default/list.html`: section list pages such as posts, projects, and life.
- `layouts/_default/single.html`: article and regular page rendering.
- `layouts/_default/terms.html`: taxonomy landing pages such as `/tags/`, `/categories/`, `/series/`.
- `layouts/_default/term.html`: taxonomy term pages such as `/tags/hugo/`.
- `assets/css/main.css`: Google-like light minimal visual system.
- `scripts/install-hugo.sh`: installs pinned local Hugo on Linux.
- `scripts/verify-site.sh`: builds and checks generated pages.
- `.github/workflows/hugo.yml`: deploys to GitHub Pages.
- `docs/giscus.md`: setup instructions for Discussions and Giscus IDs.

---

### Task 1: Tooling, Hugo Config, And Deployment Workflow

**Files:**
- Create: `scripts/install-hugo.sh`
- Create: `scripts/verify-site.sh`
- Create: `hugo.toml`
- Create: `archetypes/default.md`
- Create: `.github/workflows/hugo.yml`
- Modify: `.gitignore`

- [ ] **Step 1: Create the local Hugo installer**

Create `scripts/install-hugo.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

version="${HUGO_VERSION:-0.161.1}"
arch="$(uname -m)"

case "$arch" in
  x86_64|amd64)
    deb_arch="amd64"
    ;;
  aarch64|arm64)
    deb_arch="arm64"
    ;;
  *)
    echo "Unsupported architecture: $arch" >&2
    exit 1
    ;;
esac

sudo_cmd=()
if command -v sudo >/dev/null 2>&1 && [ "$(id -u)" -ne 0 ]; then
  sudo_cmd=(sudo)
fi

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

url="https://github.com/gohugoio/hugo/releases/download/v${version}/hugo_extended_${version}_linux-${deb_arch}.deb"
deb_path="$tmp_dir/hugo.deb"

echo "Downloading Hugo ${version} from ${url}"
curl -fsSL "$url" -o "$deb_path"

if ! "${sudo_cmd[@]}" dpkg -i "$deb_path"; then
  "${sudo_cmd[@]}" apt-get update
  "${sudo_cmd[@]}" apt-get install -f -y
fi

hugo version
```

- [ ] **Step 2: Make the installer executable**

Run:

```bash
chmod +x scripts/install-hugo.sh
```

Expected: no output and exit code `0`.

- [ ] **Step 3: Install Hugo if it is missing**

Run:

```bash
hugo version || scripts/install-hugo.sh
```

Expected after completion: output contains `hugo v0.161.1`.

- [ ] **Step 4: Create the verification script before the site exists**

Create `scripts/verify-site.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

if ! command -v hugo >/dev/null 2>&1; then
  echo "hugo is required. Run scripts/install-hugo.sh first." >&2
  exit 1
fi

rm -rf public
hugo --minify

required_files=(
  "public/index.html"
  "public/posts/index.html"
  "public/posts/2026/building-this-site/index.html"
  "public/projects/index.html"
  "public/life/index.html"
  "public/about/index.html"
  "public/tags/index.html"
  "public/categories/index.html"
  "public/series/index.html"
  "public/index.xml"
)

for file in "${required_files[@]}"; do
  if [ ! -f "$file" ]; then
    echo "Missing generated file: $file" >&2
    exit 1
  fi
done

grep -Fq "WangHaowen99" public/index.html
grep -Fq "如无必要，勿增实体。AI for ALL & ALL for AI" public/index.html
grep -Fq "首页" public/index.html
grep -Fq "文章" public/index.html
grep -Fq "专栏" public/index.html
grep -Fq "项目" public/index.html
grep -Fq "生活" public/index.html
grep -Fq "About" public/index.html
grep -Fq "目录" public/posts/2026/building-this-site/index.html
grep -Fq "评论" public/posts/2026/building-this-site/index.html
grep -Fq "Giscus is not configured yet" public/posts/2026/building-this-site/index.html

echo "site verification passed"
```

- [ ] **Step 5: Make the verification script executable**

Run:

```bash
chmod +x scripts/verify-site.sh
```

Expected: no output and exit code `0`.

- [ ] **Step 6: Run the verification script to confirm it fails before implementation**

Run:

```bash
scripts/verify-site.sh
```

Expected: FAIL because `hugo.toml`, layouts, and content have not been created yet. The error may be `Unable to locate config file or config directory`.

- [ ] **Step 7: Create the Hugo configuration**

Create `hugo.toml`:

```toml
baseURL = "https://WangHaowen99.github.io/"
languageCode = "zh-CN"
title = "WangHaowen99"
enableRobotsTXT = true
hasCJKLanguage = true
summaryLength = 120
timeZone = "Asia/Shanghai"

[pagination]
pagerSize = 10

[params]
author = "WangHaowen99"
tagline = "如无必要，勿增实体。AI for ALL & ALL for AI"
description = "WangHaowen99 的个人博客，记录技术、项目、专栏和生活。"
github = "https://github.com/WangHaowen99"
mainSections = ["posts"]

[params.giscus]
enabled = true
repo = "WangHaowen99/WangHaowen99.github.io"
repoID = ""
category = "Announcements"
categoryID = ""
mapping = "pathname"
strict = "0"
reactionsEnabled = "1"
emitMetadata = "0"
inputPosition = "bottom"
theme = "light"
lang = "zh-CN"

[taxonomies]
tag = "tags"
category = "categories"
series = "series"

[outputs]
home = ["HTML", "RSS"]
section = ["HTML", "RSS"]
taxonomy = ["HTML", "RSS"]
term = ["HTML", "RSS"]

[markup]
  [markup.highlight]
  noClasses = false
  lineNos = false
  style = "github"
  [markup.goldmark]
    [markup.goldmark.renderer]
    unsafe = true
  [markup.tableOfContents]
  startLevel = 2
  endLevel = 3
  ordered = false

[[menus.main]]
name = "首页"
url = "/"
weight = 10

[[menus.main]]
name = "文章"
url = "/posts/"
weight = 20

[[menus.main]]
name = "专栏"
url = "/series/"
weight = 30

[[menus.main]]
name = "项目"
url = "/projects/"
weight = 40

[[menus.main]]
name = "生活"
url = "/life/"
weight = 50

[[menus.main]]
name = "About"
url = "/about/"
weight = 60
```

- [ ] **Step 8: Create the default content archetype**

Create `archetypes/default.md`:

```markdown
---
title: "{{ replace .Name "-" " " | title }}"
date: {{ .Date }}
draft: true
categories: []
tags: []
series: []
description: ""
toc: true
---
```

- [ ] **Step 9: Create the GitHub Actions Pages workflow**

Create `.github/workflows/hugo.yml`:

```yaml
name: Deploy Hugo site to Pages

on:
  push:
    branches:
      - main
  workflow_dispatch:

permissions:
  contents: read
  pages: write
  id-token: write

concurrency:
  group: pages
  cancel-in-progress: false

defaults:
  run:
    shell: bash

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Setup Hugo
        uses: peaceiris/actions-hugo@v3
        with:
          hugo-version: "0.161.1"
          extended: true

      - name: Setup Pages
        uses: actions/configure-pages@v5

      - name: Build
        run: hugo --minify --baseURL "${{ steps.pages.outputs.base_url }}/"

      - name: Upload artifact
        uses: actions/upload-pages-artifact@v3
        with:
          path: ./public

  deploy:
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    runs-on: ubuntu-latest
    needs: build
    steps:
      - name: Deploy to GitHub Pages
        id: deployment
        uses: actions/deploy-pages@v4
```

- [ ] **Step 10: Update `.gitignore`**

Ensure `.gitignore` contains exactly these lines:

```gitignore
.superpowers/
public/
resources/_gen/
.hugo_build.lock
```

- [ ] **Step 11: Commit tooling and config**

Run:

```bash
git add .gitignore .github/workflows/hugo.yml archetypes/default.md hugo.toml scripts/install-hugo.sh scripts/verify-site.sh
git commit -m "chore: scaffold Hugo site tooling"
```

Expected: commit succeeds.

---

### Task 2: Base Layout And Shared Partials

**Files:**
- Create: `layouts/_default/baseof.html`
- Create: `layouts/partials/head.html`
- Create: `layouts/partials/nav.html`
- Create: `layouts/partials/footer.html`
- Create: `layouts/partials/article-meta.html`
- Create: `layouts/partials/post-card.html`

- [ ] **Step 1: Create the base layout**

Create `layouts/_default/baseof.html`:

```html
<!doctype html>
<html lang="{{ site.LanguageCode | default "zh-CN" }}">
  <head>
    {{ partial "head.html" . }}
  </head>
  <body>
    {{ partial "nav.html" . }}
    <main class="site-main">
      {{ block "main" . }}{{ end }}
    </main>
    {{ partial "footer.html" . }}
  </body>
</html>
```

- [ ] **Step 2: Create the head partial**

Create `layouts/partials/head.html`:

```html
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
{{ $description := .Description | default site.Params.description | default site.Params.tagline }}
<title>{{ if .IsHome }}{{ site.Title }}{{ else }}{{ .Title }} | {{ site.Title }}{{ end }}</title>
<meta name="description" content="{{ $description }}">
<meta name="author" content="{{ site.Params.author }}">
<meta name="referrer" content="no-referrer">
<meta property="og:title" content="{{ if .IsHome }}{{ site.Title }}{{ else }}{{ .Title }}{{ end }}">
<meta property="og:description" content="{{ $description }}">
<meta property="og:type" content="{{ if .IsPage }}article{{ else }}website{{ end }}">
<meta property="og:url" content="{{ .Permalink }}">
<link rel="canonical" href="{{ .Permalink }}">
{{ with .OutputFormats.Get "RSS" }}
<link rel="alternate" type="application/rss+xml" href="{{ .RelPermalink }}" title="{{ site.Title }}">
{{ end }}
<link rel="icon" href="data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 100'%3E%3Ctext y='.9em' font-size='86'%3EWH%3C/text%3E%3C/svg%3E">
{{ $css := resources.Get "css/main.css" | minify | fingerprint }}
<link rel="stylesheet" href="{{ $css.RelPermalink }}" integrity="{{ $css.Data.Integrity }}">
```

- [ ] **Step 3: Create the navigation partial**

Create `layouts/partials/nav.html`:

```html
<header class="site-header">
  <nav class="nav container" aria-label="主导航">
    <a class="nav-brand" href="{{ "/" | relURL }}" aria-label="{{ site.Title }} 首页">{{ site.Title }}</a>
    <div class="nav-links">
      {{ $current := . }}
      {{ range site.Menus.main }}
        {{ $active := or ($current.IsMenuCurrent "main" .) ($current.HasMenuCurrent "main" .) }}
        {{ $active = or $active (eq $current.RelPermalink (.URL | relURL)) }}
        <a class="nav-link{{ if $active }} is-active{{ end }}" href="{{ .URL | relURL }}">{{ .Name }}</a>
      {{ end }}
    </div>
  </nav>
</header>
```

- [ ] **Step 4: Create the footer partial**

Create `layouts/partials/footer.html`:

```html
<footer class="site-footer">
  <div class="container footer-inner">
    <div>
      <div class="footer-title">{{ site.Title }}</div>
      <div class="footer-tagline">{{ site.Params.tagline }}</div>
    </div>
    <div class="footer-links">
      <a href="{{ "/index.xml" | relURL }}">RSS</a>
      {{ with site.Params.github }}<a href="{{ . }}" target="_blank" rel="noopener noreferrer">GitHub</a>{{ end }}
    </div>
  </div>
</footer>
```

- [ ] **Step 5: Create the article metadata partial**

Create `layouts/partials/article-meta.html`:

```html
<div class="article-meta" aria-label="文章信息">
  {{ if not .Date.IsZero }}
    <time datetime="{{ .Date.Format "2006-01-02" }}">{{ .Date.Format "2006-01-02" }}</time>
  {{ end }}
  {{ with .Params.categories }}
    <span>{{ delimit . " / " }}</span>
  {{ end }}
  {{ if .ReadingTime }}
    <span>{{ .ReadingTime }} 分钟阅读</span>
  {{ end }}
</div>
{{ with .Params.tags }}
  <div class="tag-row" aria-label="标签">
    {{ range . }}
      <a class="tag" href="{{ (printf "/tags/%s/" (. | urlize)) | relURL }}"># {{ . }}</a>
    {{ end }}
  </div>
{{ end }}
```

- [ ] **Step 6: Create the reusable post card partial**

Create `layouts/partials/post-card.html`:

```html
<article class="post-card">
  <a class="post-card-title" href="{{ .RelPermalink }}">{{ .Title }}</a>
  {{ partial "article-meta.html" . }}
  {{ with .Description }}
    <p class="post-card-summary">{{ . }}</p>
  {{ else }}
    <p class="post-card-summary">{{ .Summary | plainify | truncate 140 }}</p>
  {{ end }}
</article>
```

- [ ] **Step 7: Run Hugo to confirm layout errors remain limited to missing CSS/content**

Run:

```bash
hugo --minify
```

Expected: the command may still fail because `assets/css/main.css` and content files are not created. It should not report syntax errors in the templates created in this task.

- [ ] **Step 8: Commit base layout and shared partials**

Run:

```bash
git add layouts/_default/baseof.html layouts/partials/head.html layouts/partials/nav.html layouts/partials/footer.html layouts/partials/article-meta.html layouts/partials/post-card.html
git commit -m "feat: add base Hugo layouts"
```

Expected: commit succeeds.

---

### Task 3: Page Templates, Article Features, And Comments Hook

**Files:**
- Create: `layouts/index.html`
- Create: `layouts/_default/list.html`
- Create: `layouts/_default/single.html`
- Create: `layouts/_default/terms.html`
- Create: `layouts/_default/term.html`
- Create: `layouts/partials/toc.html`
- Create: `layouts/partials/author-signature.html`
- Create: `layouts/partials/post-nav.html`
- Create: `layouts/partials/giscus.html`

- [ ] **Step 1: Create the homepage template**

Create `layouts/index.html`:

```html
{{ define "main" }}
<section class="hero container">
  <p class="eyebrow">Personal Blog</p>
  <h1>{{ site.Title }}</h1>
  <p class="hero-tagline">{{ site.Params.tagline }}</p>
  <div class="hero-actions">
    <a class="button button-primary" href="{{ "/posts/" | relURL }}">阅读文章</a>
    <a class="button" href="{{ "/about/" | relURL }}">关于我</a>
  </div>
</section>

<section class="section container">
  <div class="section-heading">
    <h2>最近文章</h2>
    <a href="{{ "/posts/" | relURL }}">全部文章</a>
  </div>
  <div class="stack-list">
    {{ $posts := first 5 (where site.RegularPages.ByDate.Reverse "Section" "posts") }}
    {{ range $posts }}
      {{ partial "post-card.html" . }}
    {{ else }}
      <p class="muted">还没有文章。</p>
    {{ end }}
  </div>
</section>

<section class="section container">
  <div class="section-heading">
    <h2>专栏</h2>
    <a href="{{ "/series/" | relURL }}">全部专栏</a>
  </div>
  <div class="term-grid">
    {{ range first 6 site.Taxonomies.series.ByCount }}
      <a class="term-card" href="{{ .Page.RelPermalink }}">
        <span>{{ .Page.Title }}</span>
        <strong>{{ .Count }} 篇</strong>
      </a>
    {{ else }}
      <p class="muted">专栏会随着文章自动生成。</p>
    {{ end }}
  </div>
</section>

<section class="section container">
  <div class="section-heading">
    <h2>项目</h2>
    <a href="{{ "/projects/" | relURL }}">全部项目</a>
  </div>
  <div class="stack-list">
    {{ $projects := first 3 (where site.RegularPages.ByDate.Reverse "Section" "projects") }}
    {{ range $projects }}
      {{ partial "post-card.html" . }}
    {{ else }}
      <p class="muted">项目记录会显示在这里。</p>
    {{ end }}
  </div>
</section>
{{ end }}
```

- [ ] **Step 2: Create the generic list template**

Create `layouts/_default/list.html`:

```html
{{ define "main" }}
<section class="page-header container">
  <p class="eyebrow">{{ .Section | default "Index" }}</p>
  <h1>{{ .Title }}</h1>
  {{ with .Content }}<div class="page-intro">{{ . }}</div>{{ end }}
</section>

<section class="container section">
  <div class="stack-list">
    {{ range .Pages.ByDate.Reverse }}
      {{ partial "post-card.html" . }}
    {{ else }}
      <p class="muted">这里还没有内容。</p>
    {{ end }}
  </div>
</section>
{{ end }}
```

- [ ] **Step 3: Create the single page template**

Create `layouts/_default/single.html`:

```html
{{ define "main" }}
<div class="article-layout container">
  <article class="article">
    <header class="article-header">
      <p class="eyebrow">{{ .Section | default "Page" }}</p>
      <h1>{{ .Title }}</h1>
      {{ partial "article-meta.html" . }}
      {{ with .Description }}<p class="article-description">{{ . }}</p>{{ end }}
    </header>

    <div class="prose">
      {{ .Content }}
    </div>

    {{ if eq .Section "posts" }}
      {{ partial "author-signature.html" . }}
      {{ partial "post-nav.html" . }}
      {{ partial "giscus.html" . }}
    {{ end }}
  </article>

  {{ partial "toc.html" . }}
</div>
{{ end }}
```

- [ ] **Step 4: Create the taxonomy terms template**

Create `layouts/_default/terms.html`:

```html
{{ define "main" }}
<section class="page-header container">
  <p class="eyebrow">Taxonomy</p>
  <h1>{{ .Title }}</h1>
</section>

<section class="container section">
  <div class="term-grid">
    {{ range .Data.Terms.Alphabetical }}
      <a class="term-card" href="{{ .Page.RelPermalink }}">
        <span>{{ .Page.Title }}</span>
        <strong>{{ .Count }} 篇</strong>
      </a>
    {{ else }}
      <p class="muted">暂无条目。</p>
    {{ end }}
  </div>
</section>
{{ end }}
```

- [ ] **Step 5: Create the taxonomy term template**

Create `layouts/_default/term.html`:

```html
{{ define "main" }}
<section class="page-header container">
  <p class="eyebrow">{{ .Data.Singular | default "Term" }}</p>
  <h1>{{ .Title }}</h1>
</section>

<section class="container section">
  <div class="stack-list">
    {{ range .Pages.ByDate.Reverse }}
      {{ partial "post-card.html" . }}
    {{ else }}
      <p class="muted">暂无内容。</p>
    {{ end }}
  </div>
</section>
{{ end }}
```

- [ ] **Step 6: Create the TOC partial**

Create `layouts/partials/toc.html`:

```html
{{ $empty := "<nav id=\"TableOfContents\"></nav>" }}
{{ if and (ne .Params.toc false) (ne .TableOfContents $empty) }}
  <aside class="toc" aria-label="文章目录">
    <div class="toc-title">目录</div>
    {{ .TableOfContents }}
  </aside>
{{ end }}
```

- [ ] **Step 7: Create the author signature partial**

Create `layouts/partials/author-signature.html`:

```html
<section class="author-signature" aria-label="作者">
  <div class="avatar" aria-hidden="true">WH</div>
  <div>
    <div class="author-name">{{ site.Params.author }}</div>
    <div class="author-tagline">{{ site.Params.tagline }}</div>
  </div>
</section>
```

- [ ] **Step 8: Create the previous and next post partial**

Create `layouts/partials/post-nav.html`:

```html
{{ if or .PrevInSection .NextInSection }}
<nav class="post-nav" aria-label="文章导航">
  {{ with .PrevInSection }}
    <a class="post-nav-item" href="{{ .RelPermalink }}">
      <span>上一篇</span>
      <strong>{{ .Title }}</strong>
    </a>
  {{ else }}
    <span></span>
  {{ end }}
  {{ with .NextInSection }}
    <a class="post-nav-item next" href="{{ .RelPermalink }}">
      <span>下一篇</span>
      <strong>{{ .Title }}</strong>
    </a>
  {{ end }}
</nav>
{{ end }}
```

- [ ] **Step 9: Create the Giscus comments partial**

Create `layouts/partials/giscus.html`:

```html
{{ $g := site.Params.giscus }}
{{ if and $g.enabled $g.repo $g.repoID $g.category $g.categoryID }}
<section class="comments" aria-label="评论">
  <h2>评论</h2>
  <script src="https://giscus.app/client.js"
    data-repo="{{ $g.repo }}"
    data-repo-id="{{ $g.repoID }}"
    data-category="{{ $g.category }}"
    data-category-id="{{ $g.categoryID }}"
    data-mapping="{{ $g.mapping }}"
    data-strict="{{ $g.strict }}"
    data-reactions-enabled="{{ $g.reactionsEnabled }}"
    data-emit-metadata="{{ $g.emitMetadata }}"
    data-input-position="{{ $g.inputPosition }}"
    data-theme="{{ $g.theme }}"
    data-lang="{{ $g.lang }}"
    crossorigin="anonymous"
    async>
  </script>
</section>
{{ else if $g.enabled }}
<section class="comments comments-empty" aria-label="评论">
  <h2>评论</h2>
  <p>Giscus is not configured yet. Enable Discussions, install the Giscus app, then fill `params.giscus.repoID` and `params.giscus.categoryID` in `hugo.toml`.</p>
</section>
{{ end }}
```

- [ ] **Step 10: Run Hugo to confirm remaining failures are CSS/content-related**

Run:

```bash
hugo --minify
```

Expected: the command may still fail because `assets/css/main.css` and content files are not created. It should not report syntax errors in the templates created in this task.

- [ ] **Step 11: Commit page templates and article features**

Run:

```bash
git add layouts/index.html layouts/_default/list.html layouts/_default/single.html layouts/_default/terms.html layouts/_default/term.html layouts/partials/toc.html layouts/partials/author-signature.html layouts/partials/post-nav.html layouts/partials/giscus.html
git commit -m "feat: add blog page templates"
```

Expected: commit succeeds.

---

### Task 4: Google-Like Minimal CSS

**Files:**
- Create: `assets/css/main.css`

- [ ] **Step 1: Create the stylesheet**

Create `assets/css/main.css`:

```css
:root {
  --bg: #ffffff;
  --bg-soft: #f8fafd;
  --surface: #ffffff;
  --text: #202124;
  --muted: #5f6368;
  --subtle: #80868b;
  --border: #dadce0;
  --border-soft: #e8eaed;
  --blue: #1a73e8;
  --blue-soft: #e8f0fe;
  --green: #188038;
  --yellow: #f9ab00;
  --red: #d93025;
  --shadow: 0 1px 2px rgba(60, 64, 67, 0.12);
  --radius: 8px;
  --content: 760px;
  --wide: 1120px;
  --font-sans: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Noto Sans SC", "PingFang SC", "Microsoft YaHei", Arial, sans-serif;
  --font-mono: "SFMono-Regular", Consolas, "Liberation Mono", Menlo, monospace;
}

* {
  box-sizing: border-box;
}

html {
  font-size: 16px;
  scroll-behavior: smooth;
}

body {
  margin: 0;
  min-height: 100vh;
  background: var(--bg);
  color: var(--text);
  font-family: var(--font-sans);
  line-height: 1.75;
  text-rendering: optimizeLegibility;
  -webkit-font-smoothing: antialiased;
}

a {
  color: var(--blue);
  text-decoration: none;
}

a:hover {
  text-decoration: underline;
}

a:focus-visible,
button:focus-visible {
  outline: 3px solid var(--blue-soft);
  outline-offset: 2px;
}

img {
  max-width: 100%;
  height: auto;
}

.container {
  width: min(100% - 32px, var(--content));
  margin-inline: auto;
}

.site-header {
  position: sticky;
  top: 0;
  z-index: 20;
  background: rgba(255, 255, 255, 0.92);
  backdrop-filter: blur(12px);
  border-bottom: 1px solid var(--border-soft);
}

.nav {
  display: flex;
  align-items: center;
  justify-content: space-between;
  min-height: 64px;
  gap: 24px;
}

.nav-brand {
  flex: 0 0 auto;
  color: var(--text);
  font-size: 1rem;
  font-weight: 600;
}

.nav-links {
  display: flex;
  align-items: center;
  gap: 4px;
  overflow-x: auto;
  scrollbar-width: none;
}

.nav-links::-webkit-scrollbar {
  display: none;
}

.nav-link {
  display: inline-flex;
  align-items: center;
  min-height: 36px;
  padding: 0 12px;
  border-radius: 999px;
  color: var(--muted);
  font-size: 0.92rem;
  white-space: nowrap;
}

.nav-link:hover,
.nav-link.is-active {
  color: var(--blue);
  background: var(--blue-soft);
  text-decoration: none;
}

.site-main {
  min-height: calc(100vh - 180px);
}

.hero {
  padding: 72px 0 56px;
}

.eyebrow {
  margin: 0 0 12px;
  color: var(--blue);
  font-size: 0.82rem;
  font-weight: 600;
  text-transform: uppercase;
}

.hero h1,
.page-header h1,
.article-header h1 {
  margin: 0;
  color: var(--text);
  line-height: 1.18;
}

.hero h1 {
  font-size: clamp(2.3rem, 6vw, 4rem);
  font-weight: 700;
}

.hero-tagline {
  max-width: 680px;
  margin: 20px 0 0;
  color: var(--muted);
  font-size: 1.2rem;
  line-height: 1.65;
}

.hero-actions {
  display: flex;
  flex-wrap: wrap;
  gap: 12px;
  margin-top: 28px;
}

.button {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  min-height: 40px;
  padding: 0 18px;
  border: 1px solid var(--border);
  border-radius: 999px;
  color: var(--blue);
  font-weight: 600;
}

.button:hover {
  background: var(--bg-soft);
  text-decoration: none;
}

.button-primary {
  background: var(--blue);
  border-color: var(--blue);
  color: #fff;
}

.button-primary:hover {
  background: #1558b0;
}

.section {
  padding: 36px 0;
  border-top: 1px solid var(--border-soft);
}

.section-heading {
  display: flex;
  align-items: baseline;
  justify-content: space-between;
  gap: 16px;
  margin-bottom: 18px;
}

.section-heading h2,
.comments h2 {
  margin: 0;
  font-size: 1.2rem;
}

.stack-list {
  display: grid;
  gap: 12px;
}

.post-card {
  display: block;
  padding: 18px 0;
  border-bottom: 1px solid var(--border-soft);
}

.post-card:first-child {
  padding-top: 0;
}

.post-card-title {
  color: var(--text);
  font-size: 1.12rem;
  font-weight: 600;
}

.post-card-title:hover {
  color: var(--blue);
}

.post-card-summary {
  margin: 8px 0 0;
  color: var(--muted);
}

.article-meta {
  display: flex;
  flex-wrap: wrap;
  gap: 8px 14px;
  margin-top: 8px;
  color: var(--subtle);
  font-size: 0.88rem;
}

.tag-row {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  margin-top: 12px;
}

.tag {
  display: inline-flex;
  align-items: center;
  min-height: 28px;
  padding: 0 10px;
  border-radius: 999px;
  background: var(--bg-soft);
  color: var(--muted);
  font-size: 0.84rem;
}

.tag:hover {
  background: var(--blue-soft);
  color: var(--blue);
  text-decoration: none;
}

.page-header {
  padding: 52px 0 28px;
}

.page-header h1 {
  font-size: clamp(2rem, 5vw, 3rem);
}

.page-intro {
  max-width: 680px;
  margin-top: 16px;
  color: var(--muted);
}

.article-layout {
  width: min(100% - 32px, var(--wide));
  display: grid;
  grid-template-columns: minmax(0, var(--content)) 240px;
  gap: 56px;
  align-items: start;
  padding: 52px 0;
}

.article-header {
  margin-bottom: 32px;
}

.article-header h1 {
  font-size: clamp(2rem, 5vw, 3.25rem);
}

.article-description {
  margin: 18px 0 0;
  color: var(--muted);
  font-size: 1.08rem;
}

.prose {
  color: var(--text);
  font-size: 1.02rem;
}

.prose > *:first-child {
  margin-top: 0;
}

.prose h2,
.prose h3,
.prose h4 {
  margin: 2.2em 0 0.8em;
  line-height: 1.3;
}

.prose h2 {
  padding-bottom: 8px;
  border-bottom: 1px solid var(--border-soft);
  font-size: 1.55rem;
}

.prose h3 {
  font-size: 1.25rem;
}

.prose p,
.prose ul,
.prose ol,
.prose blockquote,
.prose table,
.prose pre {
  margin: 1.15em 0;
}

.prose ul,
.prose ol {
  padding-left: 1.4em;
}

.prose li + li {
  margin-top: 0.35em;
}

.prose blockquote {
  padding: 12px 18px;
  border-left: 4px solid var(--blue);
  background: var(--bg-soft);
  color: var(--muted);
}

.prose code {
  padding: 0.15em 0.35em;
  border-radius: 4px;
  background: var(--bg-soft);
  color: var(--red);
  font-family: var(--font-mono);
  font-size: 0.9em;
}

.prose pre {
  overflow-x: auto;
  padding: 18px;
  border: 1px solid var(--border-soft);
  border-radius: var(--radius);
  background: #f6f8fa;
}

.prose pre code {
  padding: 0;
  background: transparent;
  color: inherit;
}

.prose table {
  width: 100%;
  border-collapse: collapse;
  font-size: 0.95rem;
}

.prose th,
.prose td {
  padding: 10px 12px;
  border: 1px solid var(--border);
  text-align: left;
  vertical-align: top;
}

.prose th {
  background: var(--bg-soft);
  font-weight: 600;
}

.prose hr {
  border: 0;
  border-top: 1px solid var(--border-soft);
  margin: 2rem 0;
}

.toc {
  position: sticky;
  top: 88px;
  max-height: calc(100vh - 112px);
  overflow: auto;
  padding: 16px;
  border: 1px solid var(--border-soft);
  border-radius: var(--radius);
  background: var(--surface);
  box-shadow: var(--shadow);
}

.toc-title {
  margin-bottom: 10px;
  color: var(--muted);
  font-size: 0.86rem;
  font-weight: 600;
}

.toc ul {
  margin: 0;
  padding-left: 16px;
}

.toc li {
  margin: 6px 0;
}

.toc a {
  color: var(--muted);
  font-size: 0.88rem;
}

.toc a:hover {
  color: var(--blue);
}

.author-signature {
  display: flex;
  align-items: center;
  gap: 14px;
  margin-top: 44px;
  padding: 20px 0;
  border-top: 1px solid var(--border-soft);
  border-bottom: 1px solid var(--border-soft);
}

.avatar {
  display: grid;
  place-items: center;
  width: 48px;
  height: 48px;
  border-radius: 50%;
  background: var(--blue-soft);
  color: var(--blue);
  font-weight: 700;
}

.author-name {
  font-weight: 700;
}

.author-tagline {
  color: var(--muted);
  font-size: 0.92rem;
}

.post-nav {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 12px;
  margin-top: 28px;
}

.post-nav-item {
  display: grid;
  gap: 4px;
  padding: 14px;
  border: 1px solid var(--border-soft);
  border-radius: var(--radius);
}

.post-nav-item.next {
  text-align: right;
}

.post-nav-item span {
  color: var(--subtle);
  font-size: 0.82rem;
}

.post-nav-item strong {
  color: var(--text);
}

.post-nav-item:hover {
  border-color: var(--blue);
  text-decoration: none;
}

.comments {
  margin-top: 36px;
  padding-top: 28px;
  border-top: 1px solid var(--border-soft);
}

.comments-empty p {
  margin: 12px 0 0;
  color: var(--muted);
  font-size: 0.92rem;
}

.term-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
  gap: 12px;
}

.term-card {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
  padding: 16px;
  border: 1px solid var(--border-soft);
  border-radius: var(--radius);
  color: var(--text);
}

.term-card:hover {
  border-color: var(--blue);
  background: var(--bg-soft);
  text-decoration: none;
}

.term-card strong {
  color: var(--muted);
  font-size: 0.86rem;
  white-space: nowrap;
}

.muted {
  color: var(--muted);
}

.site-footer {
  margin-top: 56px;
  border-top: 1px solid var(--border-soft);
  background: var(--bg-soft);
}

.footer-inner {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 20px;
  padding: 28px 0;
}

.footer-title {
  font-weight: 700;
}

.footer-tagline {
  color: var(--muted);
  font-size: 0.9rem;
}

.footer-links {
  display: flex;
  gap: 14px;
}

@media (max-width: 960px) {
  .article-layout {
    display: block;
    width: min(100% - 32px, var(--content));
  }

  .toc {
    display: none;
  }
}

@media (max-width: 680px) {
  .container,
  .article-layout {
    width: min(100% - 24px, var(--content));
  }

  .nav {
    align-items: flex-start;
    flex-direction: column;
    gap: 8px;
    padding: 12px 0;
  }

  .nav-links {
    width: 100%;
    padding-bottom: 2px;
  }

  .hero {
    padding: 48px 0 40px;
  }

  .section-heading,
  .footer-inner {
    align-items: flex-start;
    flex-direction: column;
  }

  .post-nav {
    grid-template-columns: 1fr;
  }

  .post-nav-item.next {
    text-align: left;
  }
}
```

- [ ] **Step 2: Run Hugo to confirm remaining failures are content-related**

Run:

```bash
hugo --minify
```

Expected: the command may still fail or generate an incomplete site because content files are not created. It should not report missing `assets/css/main.css`.

- [ ] **Step 3: Commit CSS**

Run:

```bash
git add assets/css/main.css
git commit -m "feat: add minimal light blog styling"
```

Expected: commit succeeds.

---

### Task 5: Markdown Starter Content

**Files:**
- Create: `content/_index.md`
- Create: `content/posts/2026/building-this-site.md`
- Create: `content/projects/_index.md`
- Create: `content/projects/personal-blog.md`
- Create: `content/life/_index.md`
- Create: `content/life/first-note.md`
- Create: `content/about.md`

- [ ] **Step 1: Create homepage content**

Create `content/_index.md`:

```markdown
---
title: "WangHaowen99"
description: "如无必要，勿增实体。AI for ALL & ALL for AI"
---
```

- [ ] **Step 2: Create the first technical post**

Create `content/posts/2026/building-this-site.md`:

```markdown
---
title: "用 Hugo 搭建 GitHub Pages 个人博客"
date: 2026-05-11T16:00:00+08:00
draft: false
categories:
  - 技术
tags:
  - Hugo
  - GitHub Pages
  - Markdown
series:
  - 建站笔记
description: "记录这个博客的技术选择、内容组织和部署方式。"
toc: true
---

这个站点使用 Hugo 生成静态页面，通过 GitHub Actions 部署到 GitHub Pages。文章主要用 Markdown 编写，适合长期维护技术笔记、项目记录和生活观察。

## 为什么选择 Hugo

Hugo 的优势很直接：

- 构建速度快。
- Markdown 工作流简单。
- 可以完全控制模板和样式。
- 适合部署到 `*.github.io` 这类静态站点。

## 内容结构

当前站点保留这些主要栏目：

| 栏目 | 用途 |
| --- | --- |
| 文章 | 技术文章和长文记录 |
| 专栏 | 按主题聚合文章 |
| 项目 | 项目说明、工具和实验 |
| 生活 | 非技术类记录 |
| About | 个人介绍和链接 |

## 写作方式

新文章可以放在 `content/posts/YYYY/` 下，例如：

```text
content/posts/2026/example-post.md
```

每篇文章使用 front matter 描述标题、日期、分类、标签和专栏：

```yaml
---
title: "文章标题"
date: 2026-05-11T16:00:00+08:00
categories:
  - 技术
tags:
  - Markdown
series:
  - 建站笔记
toc: true
---
```

## 部署方式

代码推送到 `main` 分支后，GitHub Actions 会运行：

```bash
hugo --minify
```

构建结果发布到 GitHub Pages，最终访问地址是：

```text
https://WangHaowen99.github.io
```

## 下一步

后续可以继续补充真实文章、项目说明、个人介绍和 Giscus 评论配置。
```

- [ ] **Step 3: Create the projects index**

Create `content/projects/_index.md`:

```markdown
---
title: "项目"
description: "记录正在做和已经完成的项目。"
---

这里用于整理工具、实验和长期项目。
```

- [ ] **Step 4: Create the personal blog project entry**

Create `content/projects/personal-blog.md`:

```markdown
---
title: "个人博客"
date: 2026-05-11T16:10:00+08:00
draft: false
categories:
  - 项目
tags:
  - Hugo
  - GitHub Pages
description: "基于 Hugo 和 GitHub Pages 的个人博客。"
toc: false
---

这个项目用于维护 `WangHaowen99.github.io`。

目标是保留简洁的 Markdown 写作体验，同时让文章、专栏、项目和生活记录都有清晰入口。
```

- [ ] **Step 5: Create the life index**

Create `content/life/_index.md`:

```markdown
---
title: "生活"
description: "记录技术之外的观察和片段。"
---

这里保留技术之外的记录。
```

- [ ] **Step 6: Create the first life note**

Create `content/life/first-note.md`:

```markdown
---
title: "第一条生活记录"
date: 2026-05-11T16:20:00+08:00
draft: false
categories:
  - 生活
tags:
  - 记录
description: "为生活栏目保留的第一条记录。"
toc: false
---

这里可以写读书、旅行、日常观察，或者任何不适合放进技术文章的内容。
```

- [ ] **Step 7: Create the About page**

Create `content/about.md`:

```markdown
---
title: "About"
description: "关于 WangHaowen99"
toc: false
---

我是 WangHaowen99。

> 如无必要，勿增实体。AI for ALL & ALL for AI

这个站点用于记录技术文章、项目实践、专题专栏和生活观察。

- GitHub: [WangHaowen99](https://github.com/WangHaowen99)
- RSS: [/index.xml](/index.xml)
```

- [ ] **Step 8: Run full site verification**

Run:

```bash
scripts/verify-site.sh
```

Expected:

```text
site verification passed
```

- [ ] **Step 9: Commit starter content**

Run:

```bash
git add content
git commit -m "feat: add initial blog content"
```

Expected: commit succeeds.

---

### Task 6: Giscus Documentation And Repository Setup Notes

**Files:**
- Create: `docs/giscus.md`

- [ ] **Step 1: Create Giscus setup documentation**

Create `docs/giscus.md`:

```markdown
# Giscus Setup

The site includes a Giscus comments partial. It stays inactive until the repository and category IDs are filled in `hugo.toml`.

## Repository

Use the standard GitHub Pages repository:

```text
WangHaowen99/WangHaowen99.github.io
```

## Steps

1. Enable Discussions for the repository:

   ```bash
   gh repo edit WangHaowen99/WangHaowen99.github.io --enable-discussions
   ```

2. Install or authorize the Giscus GitHub App for the repository:

   ```text
   https://github.com/apps/giscus
   ```

3. Open the Giscus configuration page:

   ```text
   https://giscus.app
   ```

4. Use these values:

   ```text
   Repository: WangHaowen99/WangHaowen99.github.io
   Page discussions mapping: pathname
   Discussion category: Announcements
   Theme: Light
   Language: Chinese Simplified
   ```

5. Copy the generated `data-repo-id` and `data-category-id` values into `hugo.toml`:

   ```toml
   [params.giscus]
   repoID = "COPY_REPO_ID_FROM_GISCUS"
   categoryID = "COPY_CATEGORY_ID_FROM_GISCUS"
   ```

6. Commit and push the updated config:

   ```bash
   git add hugo.toml
   git commit -m "config: enable giscus comments"
   git push
   ```

Until `repoID` and `categoryID` are configured, article pages show a short setup note instead of a broken comments widget.
```

- [ ] **Step 2: Run full site verification**

Run:

```bash
scripts/verify-site.sh
```

Expected:

```text
site verification passed
```

- [ ] **Step 3: Commit Giscus documentation**

Run:

```bash
git add docs/giscus.md
git commit -m "docs: add giscus setup guide"
```

Expected: commit succeeds.

---

### Task 7: Final Verification, GitHub Repository, And Pages Deployment

**Files:**
- Modify: remote repository state on GitHub

- [ ] **Step 1: Confirm local verification passes**

Run:

```bash
scripts/verify-site.sh
```

Expected:

```text
site verification passed
```

- [ ] **Step 2: Confirm the working tree is clean**

Run:

```bash
git status --short
```

Expected: no output.

- [ ] **Step 3: Create the standard user Pages repository**

Run:

```bash
gh repo create WangHaowen99/WangHaowen99.github.io --public --source=. --remote=origin --push
```

Expected: GitHub creates the public repository, adds `origin`, and pushes `main`.

- [ ] **Step 4: Enable Discussions for Giscus**

Run:

```bash
gh repo edit WangHaowen99/WangHaowen99.github.io --enable-discussions
```

Expected: no output and exit code `0`.

- [ ] **Step 5: Enable GitHub Pages with workflow builds**

Run:

```bash
gh api --method POST repos/WangHaowen99/WangHaowen99.github.io/pages -f build_type=workflow
```

Expected: the API creates a Pages configuration. If the response says Pages already exists, run this instead:

```bash
gh api --method PUT repos/WangHaowen99/WangHaowen99.github.io/pages -f build_type=workflow
```

Expected: the API updates the Pages configuration.

- [ ] **Step 6: Watch the deployment workflow**

Run:

```bash
gh run list --repo WangHaowen99/WangHaowen99.github.io --limit 5
```

Expected: the newest run is `Deploy Hugo site to Pages`.

Then run:

```bash
gh run watch --repo WangHaowen99/WangHaowen99.github.io
```

Expected: the workflow completes successfully.

- [ ] **Step 7: Verify the live site**

Run:

```bash
curl -I https://WangHaowen99.github.io
```

Expected: HTTP status is `200` or `301/302` followed by a reachable `200` after GitHub Pages propagation.

Then run:

```bash
curl -L --max-time 20 https://WangHaowen99.github.io | grep -F "如无必要，勿增实体。AI for ALL & ALL for AI"
```

Expected: the tagline is printed.

- [ ] **Step 8: Report Giscus manual follow-up**

Tell the user:

```text
The site is deployed. Giscus is wired but still needs the Giscus App authorization and repo/category IDs from https://giscus.app before live comments appear. The setup steps are in docs/giscus.md.
```

---

## Self-Review

Spec coverage:

- Standard repository `WangHaowen99.github.io`: Task 7.
- Hugo and Markdown workflow: Tasks 1 and 5.
- Navigation without `闪念`: Task 1 `hugo.toml`.
- Google-like minimal style: Task 4.
- Home, posts, projects, life, About, tags, categories, series, RSS: Tasks 1, 3, and 5.
- Article metadata, TOC, author signature, previous/next navigation, comments: Tasks 2 and 3.
- Giscus setup and missing-ID behavior: Tasks 3 and 6.
- GitHub Actions Pages deployment: Tasks 1 and 7.
- Local build verification: Tasks 1, 5, 6, and 7.

Placeholder scan:

- The plan contains concrete file contents, commands, and expected results.
- The Giscus IDs are intentionally blank in `hugo.toml` because Giscus generates them only after repository authorization. The implementation handles blank IDs with visible setup text and documents the exact configuration path.

Type and name consistency:

- `params.giscus` keys match `layouts/partials/giscus.html`.
- Taxonomies in `hugo.toml` match generated URLs used by `article-meta.html`.
- Verification paths match content paths.
