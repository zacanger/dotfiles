#! /bin/sh

SEARCH="$1"
shift

find "$SEARCH" ! -name . ! -name .. -name ".*" -prune -o -type f -print0 | xargs -0r -- "$@"
