#!/usr/bin/env bash

wall_path=$HOME/Dropbox/Pictures/walls/
wall=`ls -1 $wall_path | shuf -n1`

feh --bg-fill $wall_path$wall
