#!/bin/bash

NAME=$1

if [ "x$NAME" == x ] ; then
  NAME=you
fi

read -d '' SONG <<LYRICS
Happy birthday to you!
Happy birthday to you!
Happy birthday, dear $(tput bold)$NAME$(tput sgr0)!
Happy birthday to you!
LYRICS

clear

sing() {
  tput setaf $(( $RANDOM % 5 + 1 ))
  echo -n "$1"
  tput sgr0
  sleep $(echo "$(echo $1 | wc -c) / 8.0" | bc -l)
}

IFS=$'\n'
for line in $SONG; do
  IFS=" "

  first_word=$(echo $line | cut -d ' ' -f 1)
  sing "$first_word"

  for word in $(echo $line | cut -d ' ' -f 2-); do
    sing " $word"
  done

  echo
  sleep 0.7
done

sh -c 'sleep 2; echo "...and many more!"' &