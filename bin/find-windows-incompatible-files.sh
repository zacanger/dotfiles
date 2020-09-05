#!/usr/bin/env bash

# files with reserve names and characters
LC_ALL=C find . -name '*[[:cntrl:]<>:"\\|?*]*' \
  -o -iname 'CON' \
  -o -iname 'PRN' \
  -o -iname 'AUX' \
  -o -iname 'NUL' \
  -o -iname 'COM[1-9]' \
  -o -iname 'LPT[1-9]' \
  -o -name '* ' \
  -o -name '?*.'

# case insensitivity
find . \
  | sort \
  | LC_ALL=C tr '[:upper:]' '[:lower:]' | \
  uniq -c | \
  grep -v '^      1 ' | \
  cut -c '9-'

# > 260 chars
find "$PWD" | while IFS= read -r path; do
  if [ "${#path}" -gt 260 ]; then
    printf '%s\n' "$path"
  fi
done
