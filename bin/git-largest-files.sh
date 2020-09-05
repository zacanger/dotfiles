#!/usr/bin/env bash

git verify-pack -v .git/objects/pack/pack-*.idx |
grep blob | sort -k3nr | head |
while read s x b x; do
  git rev-list --all --objects | grep $s |
  awk '{print "'"$b"'",$0;}';
done
