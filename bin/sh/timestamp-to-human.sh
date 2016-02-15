#!/usr/bin/env bash

# convert unix timestamp in primary x selection
# to human-readable time in local tz

date -d @`
    xclip -o |
    sed -r 's/[0-9]{3}$/.&/'
`

