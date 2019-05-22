#!/usr/bin/env bash

for i in {1..65535}; do
  nc -w 2 open.zorinaq.com $i
  rc=$?
  if [[ $rc == 0 ]] ; then
    echo "Port $i unblocked"
  fi
done
