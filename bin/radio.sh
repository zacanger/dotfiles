#!/usr/bin/env bash
set -e

# Source: https://github.com/whiteinge/dotfiles
# Modified to not use a fuzzy finder, since
# I don't really like those

curl -sS https://api.somafm.com/channels.json | \
  jq -r '.channels[] |
    "\(.title)\n\(.description)\n\(.playlists[] |
    limit(1;select(.quality == "low")) |
    .url)\n"' | \
  vipe.sh | \
  xargs mpv
