#!/bin/sh
#
# shorten urls with is.gd

hash curl &>/dev/null || { echo "Could not find curl.."; exit 1; }
curl -s "http://is.gd/api.php?longurl=$@"
