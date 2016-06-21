#!/bin/bash

if [ "x$1" == "x-" ]; then
    jp.py | less
fi

cat "$1" | jp.py | less
