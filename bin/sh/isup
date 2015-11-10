#!/bin/sh

# check if a website is up
# depends on the lynx text browser

hash lynx &>/dev/null || { echo "Cannot find lynx"; exit 1; }
[[ -z "$1" ]] && { echo "You must give a URL to check if it is up"; exit 1; }

ISUP_URL="http://www.downforeveryoneorjustme.com"

lynx -dump "$ISUP_URL/${1}" | head -1 | sed 's/...//' | sed 's/\[1\]//'
