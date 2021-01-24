#!/usr/bin/env bash
set -e

is_dir() {
    [[ -d $1 ]]
}

for r in *; do
    if is_dir "$r"; then
        cd "$r"
        git fetch --all
        git pull
        cd ..
    fi
done
