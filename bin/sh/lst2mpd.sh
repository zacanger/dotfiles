#!/bin/bash

[ -z "$1" ] && echo "Usage: $0 LST_FILE" && exit 1

lst_file="$1"

if ! command -v wget &>/dev/null; then
    echo 1>&2 'wget not found. Aborting.'
    exit 1
fi

while read -r line
do
    url=$(echo "$line"|sed 's/\s*;.*$//g')
    comment=$(echo "$line"|sed 's/^.*;//g')

    if [ -z $url ]; then
        continue
    fi

    if [[ "$url" == *.m3u || "$url" == *.pls ]]; then
        wget "$url" --connect-timeout=1 --read-timeout=1 --tries=1 -qO- |\
        grep -o 'http://.*' |\
        while read -r sub_url; do
            echo "Adding $sub_url"
            echo "$sub_url"|mpc add
        done
    else
        echo "Adding $url"
        echo "$url"|mpc add
    fi
done < "$lst_file"
