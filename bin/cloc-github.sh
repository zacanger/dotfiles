#!/usr/bin/env bash

if ! hash cloc 2>/dev/null ; then
  echo 'please install cloc'
  exit 1
fi

git clone --depth 1 "$1" temp-linecount-repo &&
  printf "('temp-linecount-repo' will be deleted automatically)\n\n\n" &&
  cloc temp-linecount-repo &&
  rm -rf temp-linecount-repo
