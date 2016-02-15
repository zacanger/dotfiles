#!/bin/bash

while getopts S: opt; do
  case $opt in
    S)
      syntax=$OPTARG
      shift 2
      ;;
  esac
done

highlight -O xterm256 -s molokai ${syntax:+-S $syntax} $1 |
less -R
