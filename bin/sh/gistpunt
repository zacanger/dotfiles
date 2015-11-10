#!/bin/bash

if [ -d .git ]; then
    git add .
    git commit -a -m "~gist"
    git push
else
    echo Not a git repository
    exit 1
fi;
