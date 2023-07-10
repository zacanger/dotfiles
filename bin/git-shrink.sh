#!/usr/bin/env bash
set -e

git reflog expire --all --expire=all
git gc --prune --aggressive
