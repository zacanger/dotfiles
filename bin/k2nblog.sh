#!/usr/bin/env bash

names.sh .

for f in *
do
  aunpack "$f"
  rm "$f"
done

names.sh .

find . -type f -name 'k2nblog*.url' -exec rm {} +

# TODO: rename files from foobar-_-www.k2nblog.com, where any part after foobar may not be there

# https://stackoverflow.com/questions/23509186/remove-punctuation-standard-input?lq=1
# https://apple.stackexchange.com/questions/93322/how-to-strip-a-filename-of-special-characters
# https://www.google.com/search?q=bash+trim+punctuation+from+filename&oq=bash+trim+punctuation+from+filename&aqs=chrome..69i57j0.5199j1j1&sourceid=chrome&ie=UTF-8

# TODO: strip www.knblog.com comment from every file
