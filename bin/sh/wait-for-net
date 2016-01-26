#!/usr/bin/env sh

set -e

until [ -n "$(ping -c 2 8.8.8.8 | grep received)" ]; do
  sleep 3 ;
  echo
done
echo "finally!"

