#!/usr/bin/env bash
set -e

f="$1"

if [ "$f" == "*.jpg" ] || [ "$f" == "*.jpeg" ]; then
    jpegoptim "$f"
elif [ "$f" == "*.png" ]; then
    optipng "$f"
elif [ "$f" == "*.svg" ]; then
    mv "$f" "$f.bak.svg"
    svgo "$f.bak.svg" -o "$f"
fi
