#!/bin/bash -e

colordiff -u "$@" |
less

read -p 'Diff OK? (y/N) '
[[ $REPLY == y || $REPLY == Y ]]
