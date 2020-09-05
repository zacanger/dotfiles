#!/usr/bin/env bash
set -e

D="$1"
[ "$1" = "" ] && D=$(pwd)
du -hs --apparent-size "$D"
