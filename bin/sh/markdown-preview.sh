#!/usr/bin/env bash

# converts markdown to temp html file, opens it in browser (see lines 6 and 11)

command -v pandoc >/dev/null 2>&1 || { echo "Please install Pandoc and try again."; exit 1; }
command -v roaster.py >/dev/null 2>&1 || { echo "Configured browser is not installed. Please try a different one."; exit 1; }

if [ -f "$1" ]; then
  TEMPFILE=/tmp/$$.html
  pandoc -s "$1" -o "$TEMPFILE"
  roaster.py "$TEMPFILE"
else
  echo Sorry, $1 does not exist.
  echo Usage: markdown-preview filename
fi

