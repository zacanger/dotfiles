#!/usr/bin/env bash

## Case in-sensitive comparison
shopt -s nocasematch

since=${1:-"today"}

if [[ $# -gt 1 ]] || [[ ! $since =~ ^(yesterday|today|lastweek)$ ]] ; then
    >&2 echo "Usage: $0 today|yesterday|lastweek"
    exit 1
fi


if [[ $since = "today" ]] ; then
    since="6am"
fi

if [[ $since = "lastweek" ]] ; then
    since="last week"
fi

git shortlog -ns --since="$since" --all | sort -n | awk -F '\t' '{printf "\033[1m\033[37m %-20s =====> \033[1m\033[31m #%-5d\n",$2,$1}'
