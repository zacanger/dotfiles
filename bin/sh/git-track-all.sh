#!/usr/bin/env bash

# this tracks all remote branches
git branch -r | grep -v '\->' | while read remote; do git branch --track "${remote#origin/}" "$remote"; done

# and then fetching and pulling all remote branches
git fetch --all
git pull --all

