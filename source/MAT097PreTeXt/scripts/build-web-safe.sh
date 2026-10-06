#!/bin/zsh

set -euo pipefail

script_dir=$(cd -- "$(dirname -- "$0")" && pwd)
project_root=$(cd -- "$script_dir/.." && pwd)

if ! command -v pretext >/dev/null 2>&1; then
  echo "error: pretext CLI was not found in PATH" >&2
  exit 1
fi

if ! command -v rsync >/dev/null 2>&1; then
  echo "error: rsync is required for this build helper" >&2
  exit 1
fi

tmp_root=$(mktemp -d /tmp/MAT097PreTeXt-build.XXXXXX)
stage_dir="$tmp_root/project"

cleanup() {
  rm -rf "$tmp_root"
}

trap cleanup EXIT

echo "Staging project in $stage_dir"
cp -R "$project_root" "$stage_dir"

echo "Building web target from ASCII-only temp path"
(
  cd "$stage_dir"
  pretext build web
)

mkdir -p "$project_root/output/web"
rsync -a --delete "$stage_dir/output/web/" "$project_root/output/web/"

echo "Build complete. Web output copied to:"
echo "  $project_root/output/web"
