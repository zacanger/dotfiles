#!/usr/bin/env bash

# because python

for a in "$@"
do
  cd $a
  for b in *.txt # change this depending on your needs
  do
    native2ascii -encoding UTF-8 $b $b
    echo "Cleaned $b."
  done
  cd ..
done
