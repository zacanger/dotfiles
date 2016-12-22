#!/usr/bin/env bash
JANEDIR=$HOME/jane
for D in $(\ls -1 "$JANEDIR") ; do
  cd $D
  git stash
  git checkout master
  git pull --prune
  git checkout -
  git stash pop
  cd ..
done
