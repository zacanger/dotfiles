#!/usr/bin/env bash
set -e

if hash gfind 2>/dev/null; then
    _find=$(which gfind)
else
    _find=$(which find)
fi

if hash gnumfmt 2>/dev/null; then
    _numfmt=$(which gnumfmt)
else
    _numfmt=$(which numfmt)
fi

n=${1:-10}

$_find . -type f -printf '%s %p\n' | \
    sort -nr | \
    head -n "$n" | \
    $_numfmt --to=iec
