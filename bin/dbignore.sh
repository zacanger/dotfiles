#!/usr/bin/env bash
set -e

a="$1"
f=$(realpath "$a")

if [[ $(uname) == 'Darwin' ]]; then
    xattr -w com.dropbox.ignored 1 "$f"
elif [[ $(uname) == 'Linux' ]]; then
    attr -s com.dropbox.ignored -V 1 "$f"
fi
