#!/usr/bin/env bash

# changes mtime of package.json to be the same time as the last file change
# in git. useful for docker, so it'll use the cached version; quicker build
# times!

if [ "$(uname)" == "Darwin" ]; then
  REV=$(git rev-list -n 1 HEAD 'package.json')
  STAMP=$(git show --pretty=format:%at --abbrev-commit "$REV" | head -n 1)
  DATE=$(date -r "$STAMP" '+%Y%m%d%H%M.%S')
  touch -h -t "$DATE" package.json
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
  REV=$(git rev-list -n 1 HEAD 'package.json')
  STAMP=$(git show --pretty=format:%ai --abbrev-commit "$REV" | head -n 1)
  touch -d "$STAMP" package.json
elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW32_NT" ]; then
  echo 'sorry, you are sol. please come back witih a real computer.'
fi

