#!/usr/bin/env bash

div() {
  local LINE=''
  while (( ${#LINE} < "$(tput cols)" ))
  do
    LINE="$LINE#"
  done
  echo "${LINE}"
}

div

echo Your tweet?

read TWEET

twidge update "${TWEET}"

echo Tweeted!

div

