#!/usr/bin/env bash

# reads timestamp from read
# converts to date format

echo "enter the timestamp plz"
read $ts
echo "your timestamp in date format is:"
date -d "1970-01-01 $ts sec GMT"
echo
