#!/bin/bash

# author Tasos Latsas
#
# copy contents of a file in X cliboard
# requires the xclip utility

hash xclip &>/dev/null || { echo "xclip is not installed"; exit 1; }

[[ -f "$1" ]] || { echo "$1 not a regular file"; exit 1; }

xclip -in -selection clipboard < "$1"
if [[ $? -eq 0 ]]; then
    echo "File copied successfully to clipboard"
    exit 0
fi

echo "Copy failed"
exit 1
