#!/usr/bin/env bash
set -e

# Source: https://github.com/whiteinge/dotfiles
# Slightly modified to use a different fuzzy finder

curl -sS https://api.somafm.com/channels.json | \
    jq -r '.channels[] |
        "\(.title)\t\(.description)\t\(.playlists[] |
        limit(1;select(.quality == "low")) |
        .url)\n"' | \
    fuzzy.py | \
    cut -f3 | \
    xargs mpv
