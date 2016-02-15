#!/bin/bash

# Download a thread from 8chan with all of its files.

if [ -z "$1" ]; then
    echo 'Please provide an 8chan URL' 1>&2
    exit 1
fi

url="$1"

if [[ ! "$url" == http* ]]; then
    # Add on the protocol if it's missing.
    url="http://$url"
else
    # Change http: to https:, for privacy and speed (SPDY)
    url=https:"$(echo "$url" | cut -d: -f2-)"
fi

cd ~/content/text/html/

wget --recursive --level=1 --timestamping --convert-links \
    --reject '*.php,robots.txt,boards.html,bans.html,faq.html,index.html,catalog.html' \
    --domains=8ch.net --span-hosts -e robots=off \
    "$1"