#!/usr/bin/env bash

# usage:
# $open http://example.com
# $open $someOtherVariable
# $open foo.txt
# should be linux, mac, cygwin, and windows compatible.
# should work for any files the OS knows how to handle.
# throw it in your own script, or keep it on its own.

for opener in xdg-open open cygstart "start"; {
  if command -v $opener; then
    open=$opener;
    break;
  fi
}

$open "$1"

