#!/usr/bin/env bash
set -e

is_dir() {
    [[ -d $1 ]]
}

for r in *; do
    if is_dir "$r"; then
        cd "$r"
        git reflog expire --all --expire=all
        git gc --prune --aggressive
        cd ..
    fi
done
