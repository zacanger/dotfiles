#!/bin/bash

[ -z "$1" -o -z "$2" ] && echo "Usage: $0 LST_FILE PLS_FILE" && exit 1

lst_file="$1"
pls_file="$2"

if ! command -v wget &>/dev/null; then
    echo 1>&2 'wget not found. Aborting.'
    exit 1
fi

echo '[playlist]' > "$pls_file"

index=1
while read -r line
do
    url=$(echo "$line"|sed 's/\s*;.*$//g')
    comment=$(echo "$line"|sed 's/^.*;//g')

    if [ -z $url ]; then
        continue
    fi

    echo "$url"
    if [[ "$url" == *.m3u || "$url" == *.pls ]]; then
        tmp_file=$(mktemp -u)
        wget "$url" --connect-timeout=1 --read-timeout=1 --tries=1 -qO- |\
        grep -o 'http://.*' >"$tmp_file"

        while read -r sub_url; do
            echo -e "\t$sub_url"
            echo "Title$index=$comment" >> "$pls_file"
            echo "File$index=$sub_url" >> "$pls_file"
            ((index++))
        done < "$tmp_file"

        rm "$tmp_file"
    else
        echo "Title$index=$comment" >> "$pls_file"
        echo "File$index=$url" >> "$pls_file"
        ((index++))
    fi
done < "$lst_file"

echo "Version=2" >> "$pls_file"
echo "NumberOfEntries=$index" >> "$pls_file"

echo "$pls_file created."
