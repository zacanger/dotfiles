#!/bin/bash

D=$1
[ "$1" = "" ] && D=`pwd`
du -hs --apparent-size $D
exit 0
