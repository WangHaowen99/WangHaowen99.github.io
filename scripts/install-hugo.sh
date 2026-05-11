#!/usr/bin/env bash
set -euo pipefail

version="0.161.1"
arch="$(uname -m)"

case "$arch" in
  x86_64|amd64)
    deb_arch="amd64"
    sha256="c89632f5bd7727746df2560313dc5dbeebef0a8823566c6479dbdd3c4f06aad9"
    ;;
  aarch64|arm64)
    deb_arch="arm64"
    sha256="4d5a5eb338f4b47fbec6c00e0e3696e904fc0efb6ca499df5f8330e99eeb8cf7"
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
echo "${sha256}  ${deb_path}" | sha256sum -c -

if ! "${sudo_cmd[@]}" dpkg -i "$deb_path"; then
  "${sudo_cmd[@]}" apt-get update
  "${sudo_cmd[@]}" apt-get install -f -y
fi

hugo version
