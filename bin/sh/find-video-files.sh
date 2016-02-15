#!/bin/bash

for obj in "$@"; do
  if [ -f "$obj" ]; then 
    echo "$obj"; 
  elif [ -d "$obj" ]; then
    find "$obj" -type f -size +1k -print0  \
      | xargs -0 file --mime -N -F:::      \
      | perl -ne 'print "$1\n" if /(.+):::\s+video\//'
  fi
done

# vim:ts=2:sw=2:sts=2:et:ft=sh
