#!/bin/bash

usage() {
    echo "USAGE: $(basename $0) TZ..."
    echo
    echo "Prints clocks for each timezone indicated by one or more TZs."
    echo
    echo "Each TZ should either be a timezone name (example: PST8PDT), or a combination
of display name and timezone name in the format DISPLAYNAME:TZNAME (example:
Seattle:PST8PDT)."
    exit 1
}

tz_date() {
    DISPLAY_NAME=${1%%:*}
    TZ_NAME=${1##*:}
    echo "$DISPLAY_NAME: $(TZ=$TZ_NAME date +%H:%M:%S)"
}

[[ $# -ge 1 ]] || usage
for tz_name in $* ; do
    echo -n " $(tz_date $tz_name) "
done
