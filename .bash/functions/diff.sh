# shellcheck shell=bash

if hash git 2>/dev/null; then
    diff() {
        git diff --no-index --color-words "$@"
    }
fi
