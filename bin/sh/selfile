#!/bin/sh
def=$1; shift
case "$#" in
  0) if test -t 0; then
        cat -- $def
     else
         cat
     fi;;
  *) cat -- "$@";;
esac
