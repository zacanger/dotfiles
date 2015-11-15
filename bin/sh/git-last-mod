#!/bin/sh
# grabbed from http://serverfault.com/questions/401437/how-to-retrieve-the-last-modification-date-of-all-files-in-a-git-repository
git ls-tree -r --name-only HEAD | while read filename; do
  echo "$(git log -1 --format="%cd" -- $filename) $filename"
done

