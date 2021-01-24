# shellcheck shell=bash

aah() {
    thing=$1
    place=$2
    if [ -z "$place" ];
        then place=.
    fi
    ls -a "$place" | ag --passthrough "$thing"
}
