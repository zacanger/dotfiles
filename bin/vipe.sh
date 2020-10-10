#!/usr/bin/env bash
set -e

# https://www.uninformativ.de/git/bin-pub/file/vipe.html
# See also https://joeyh.name/code/moreutils/ for a Perl version

tmp=$(mktemp)
trap 'rm -f "$tmp"' 0

cat >"$tmp"
${EDITOR:-vim} "$tmp" </dev/tty >/dev/tty
cat "$tmp"
