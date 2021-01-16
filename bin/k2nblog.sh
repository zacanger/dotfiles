#!/usr/bin/env bash
set -e

names.sh .

for f in *; do
  aunpack "$f"
  rm "$f"
done

names.sh .

find . -type f -name 'k2nblog*.url' -exec rm {} +
find . -type f -name 'kpopstan*.url' -exec rm {} +
find . -type f -name 'thumbs.db' -exec rm {} +

for f in *; do
  new_name=$(echo "$f" \
    | sed -r 's/(_-)?(www.)?k2nblog\.com(-)?//' \
    | sed -r 's/(_-)?(www.)?kpopstan\.com(-)?//')
  if [ "$f" != "$new_name" ]; then
    mv "$f" "$new_name"
  fi
done

echo 'Potential files for removal:'
find . | grep 'inst'
