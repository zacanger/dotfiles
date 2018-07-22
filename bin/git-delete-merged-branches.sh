#!/bin/sh

git branch --merged | egrep -v "(^\*|master|dev)" | xargs git branch -d
