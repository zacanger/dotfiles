#!/usr/bin/env bash
set -e

# git-deleted-files.sh -M PATH
# -M will not show renamed files

git log \
  --raw \
  --no-renames \
  --date=short \
  --format="%h %cd" "$@" |
  awk '/^[0-9a-f]/ { commit=$1; date=$2 }
       /^:/ && $5 == "D" { print date, commit "^:" $6 }' |
  less
