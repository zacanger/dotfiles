#!/usr/bin/env bash

BASE62=($(echo {0..9} {a..z} {A..Z}))
for i in $(bc <<< "obase=62; 9207903953"); do
    echo -n ${BASE62[$(( 10#$i ))]}
done && echo

