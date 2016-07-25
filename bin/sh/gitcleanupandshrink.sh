#!/bin/sh
git gc --aggressive --prune=now && git reflog expire --all --expire=now && git gc --prune=now --aggressive
