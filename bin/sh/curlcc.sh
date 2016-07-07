#!/usr/bin/env bash

url=$1; shift

headers_file=/tmp/curlcc-tmp.headers
ofile=/tmp/curlcc-tmp.ofile.c
execfile=/tmp/curlcc-tmp.exec

curl -s -o "$ofile" -D "$headers_file" "$url"

content_type=$( cat "$headers_file" | grep -i 'Content-type' | awk -F ': ' '{ print $2 }' | tr -d '\r' )

if [[ "$content_type" != "text/x-csrc" ]]; then
  echo "Incorrect content type. can't do: '$content_type'"
  exit 1
fi

gcc -o "$execfile" "$ofile"

"$execfile" "$@"
