#!/usr/bin/env bash

## Assumes lists of URLS in .md files in same directory
## Ideally format is:
## * [Title](http(s)://url.tld/optionalstring)

for file in *.md; do
  echo "====== Reading file: ${file} ======"
  while read line; do

    url=$(echo "$line" | sed s/.*\(// | sed s/\)// | sed s/^##.*//)

    if [[ ! -z "$url" ]]; then
      echo "- Checking URL: ${url}"
      curl -sI "${url}" | grep "HTTP/1.[01] [^23].."
    fi
  done <"$file"
done
