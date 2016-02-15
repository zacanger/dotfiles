#!/bin/bash

if [ ! "$1" ]; then
  echo "usage: $0 (command)"
  exit 1
fi

until $1; do
  echo "trying again in a minute"
  sleep 60
done

