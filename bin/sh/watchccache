#!/bin/bash
while :; do
    ccache -s
    sleep 2
done |
awk '
    /^cache hit / {
        type = gensub(/\((.*)\)/, "\\1", "", $3)
        if (hits[type] != $NF)
            print type, $NF - hits[type], "\a"
        hits[type] = $NF
    }
'
