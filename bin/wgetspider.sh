#!/bin/sh

wget --spider -r -nd -nv -H -l ${2:=4} -w 1 -D $1 -o site.log "http://${1}/"
