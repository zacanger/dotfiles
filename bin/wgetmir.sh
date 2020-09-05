#!/usr/bin/env bash

# Mirrors a site locally; pretends to be Google to make sure it works
# Warning: very impolite script - don't use on servers that aren't your own

command -v wget >/dev/null 2>&1 || { echo "wget not found. Please install it and try again"; exit 1; }

if test -z "$1"; then { echo "Please provide URL to be mirrored"; exit 1; }; fi

wget --recursive \
  --no-clobber \
  --random-wait \
  --page-requisites \
  --html-extension \
  --convert-links \
  --restrict-file-names=windows \
  --no-parent \
  --user-agent="Mozilla/5.0 (compatible; Googlebot/2.1; +http://www. google.com/bot.html)" \
  -e robots=off "$1"
