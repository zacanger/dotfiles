#!/usr/bin/env bash
set -e

if [ -z "$1" ]; then
    echo 'names: make file and directory names command-friendly, recursively'
    echo 'usage: names.sh path/to/directory'
    exit 0
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

if hash gtr 2>/dev/null; then
    _tr=$(which gtr)
else
    _tr=$(which tr)
fi

"$_find" "$1" -depth -name '*' | while read -r file; do
    directory=$(dirname "$file")
    oldfilename=$(basename "$file")
    # shellcheck disable=1112
    newfilename=$(echo "$oldfilename" \
        | "$_tr" 'A-Z' 'a-z' \
        | "$_tr" ',' '_' \
        | "$_tr" '[' '-' \
        | "$_tr" ']' '-' \
        | "$_tr" '\`' '-' \
        | "$_tr" "'" '-' \
        | "$_tr" '"' '-' \
        | "$_tr" ' ' '_' \
        | "$_tr" '(' '-' \
        | "$_tr" ')' '-' \
        | "$_tr" '!' '-' \
        | "$_tr" ':' '-' \
        | "$_sed" 's/&/and/g' \
        | "$_sed" 's/[‘’｜﹂﹁「」“„『』【】]/__/g' \
        | "$_sed" 's/_-_/-/g')

    if [ "$oldfilename" != "$newfilename" ]; then
        mv -i "$directory/$oldfilename" "$directory/$newfilename"
        # shellcheck disable=SC2086
        echo ""$directory/$oldfilename" -> "$directory/$newfilename""
    fi
done
exit 0
