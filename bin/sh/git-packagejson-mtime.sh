#!/usr/bin/env bash

# changes mtime of package.json to be the same time as the last file change
# in git. useful for docker, so it'll use the cached version; quicker build
# times!

# for BSD-based systems (including macs):
# REV=$(git rev-list -n 1 HEAD 'package.json');
# STAMP=$(git show --pretty=format:%at --abbrev-commit "$REV" | head -n 1);
# DATE=$(date -r "$STAMP" '+%Y%m%d%H%M.%S');
# touch -h -t "$DATE" package.json;

# For unix based systems, it’s fairly similar:
# and on *n*x:
REV=$(git rev-list -n 1 HEAD 'package.json');
STAMP=$(git show --pretty=format:%ai --abbrev-commit "$REV" | head -n 1);
touch -d "$STAMP" package.json;

