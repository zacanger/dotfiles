#/usr/bin/env bash

mkdnpy "$*" &
${EDITOR} "$*"
kill %1
