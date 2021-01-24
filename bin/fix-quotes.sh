#!/usr/bin/env bash
set -e

ext="$1"

if [ -z "$ext" ]; then
    echo "Usage: fix-quotes.sh '*.md"
    echo 'Runs recursively on all files to find and fix quote marks'
    exit 1
fi

if hash gfind 2>/dev/null; then
    _find=$(which gfind)
else
    _find=$(which find)
fi

if hash gsed 2>/dev/null; then
    _sed=$(which gsed)
else
    _sed=$(which sed)
fi

"$_find" . -type f -name "$ext" -exec "$_sed" -i s/[﹂﹁「」“„»«『』]/'"'/g {} +
"$_find" . -type f -name "$ext" -exec "$_sed" -i s/[‘’]/"'"/g {} +
