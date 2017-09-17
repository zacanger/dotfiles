#!/usr/bin/env bash

git remote rm origin
rm -rf .git/refs/original/ .git/refs/remotes/ .git/*_HEAD .git/logs/
git for-each-ref --format="%(refname)" refs/original/ | xargs -n1 --no-run-if-empty git update-ref -d

git -c gc.reflogExpire=0 -c gc.reflogExpireUnreachable=0 -c gc.rerereresolved=0 \
    -c gc.rerereunresolved=0 -c gc.pruneExpire=now gc "$@"

git tag | xargs git tag -d

