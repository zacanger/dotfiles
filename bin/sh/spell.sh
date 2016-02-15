#!/bin/sh

# check word spelling
# depends on hunspell

hash hunspell &>/dev/null || { echo "Hunspell is not installed"; exit 1; }

echo $@ | hunspell -a  | sed '1d' | awk -F ': ' '{ print $2 }'
