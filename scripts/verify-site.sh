#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$script_dir/.." && pwd)"
cd "$repo_root"

if ! command -v hugo >/dev/null 2>&1; then
  echo "hugo is required. Run scripts/install-hugo.sh first." >&2
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
