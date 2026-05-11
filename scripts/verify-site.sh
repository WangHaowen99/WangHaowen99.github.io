#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$script_dir/.." && pwd)"
cd "$repo_root"

if ! command -v hugo >/dev/null 2>&1; then
  echo "hugo is required. Run scripts/install-hugo.sh first." >&2
  exit 1
fi
if ! command -v perl >/dev/null 2>&1; then
  echo "perl is required for generated HTML checks." >&2
  exit 1
fi

hugo_version="$(hugo version)"
if [[ "$hugo_version" != *"v0.161.1"* || "$hugo_version" != *"+extended"* ]]; then
  echo "hugo v0.161.1+extended is required. Found: $hugo_version" >&2
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
nav_text="$(
  perl -0ne '
    if (m{<div class=nav-links>(.*?)</div>}s) {
      my $links = $1;
      while ($links =~ m{<a\b[^>]*>(.*?)</a>}sg) {
        my $label = $1;
        $label =~ s/<[^>]+>//g;
        $label =~ s/^\s+|\s+$//g;
        print "$label\n";
      }
    }
  ' public/index.html
)"
expected_nav=$'首页\n文章\n专栏\n项目\n生活\nAbout'
if [ "$nav_text" != "$expected_nav" ]; then
  echo "Unexpected navigation links." >&2
  printf 'Expected:\n%s\nActual:\n%s\n' "$expected_nav" "$nav_text" >&2
  exit 1
fi
if grep -R -Fq "闪念" public; then
  echo "Unexpected 闪念 content found in generated site." >&2
  exit 1
fi
grep -Fq "目录" public/posts/2026/building-this-site/index.html
grep -Fq "评论" public/posts/2026/building-this-site/index.html
grep -Fq "Giscus is not configured yet" public/posts/2026/building-this-site/index.html

giscus_tmp_dir="$(mktemp -d)"
trap 'rm -rf "$giscus_tmp_dir"' EXIT
giscus_config="$giscus_tmp_dir/giscus.toml"
giscus_public="$giscus_tmp_dir/public"
cat > "$giscus_config" <<'TOML'
[params.giscus]
enabled = true
repo = "WangHaowen99/WangHaowen99.github.io"
repoID = "R_test_repo_id"
category = "Announcements"
categoryID = "DIC_test_category_id"
mapping = "pathname"
strict = "0"
reactionsEnabled = "1"
emitMetadata = "0"
inputPosition = "bottom"
theme = "light"
lang = "zh-CN"
TOML

hugo --minify --destination "$giscus_public" --config hugo.toml,"$giscus_config" >/dev/null
giscus_page="$giscus_public/posts/2026/building-this-site/index.html"
grep -Fq 'https://giscus.app/client.js' "$giscus_page"
grep -Fq 'data-repo=WangHaowen99/WangHaowen99.github.io' "$giscus_page"
grep -Fq 'data-repo-id=R_test_repo_id' "$giscus_page"
grep -Fq 'data-category=Announcements' "$giscus_page"
grep -Fq 'data-category-id=DIC_test_category_id' "$giscus_page"
grep -Fq 'data-mapping=pathname' "$giscus_page"
grep -Fq 'data-theme=light' "$giscus_page"
grep -Fq 'data-lang=zh-CN' "$giscus_page"

echo "site verification passed"
