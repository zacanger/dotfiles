#!/bin/bash

die() {
    echo -e $1; exit 1
}

depend() {
    for COMMAND in $@; do
        which $COMMAND &> /dev/null || die "FATAL ERROR: Required command '$COMMAND' is missing."
    done
}

usage() {
    echo "USAGE: $(basename $0) PID SENSOR STEMP RTEMP INTERVAL"
    echo "Suspend PID when SENSOR temp exceeds STEMP, then resume it once it falls below RTEMP. Check the temperature every INTERVAL seconds."
    exit 1
}

depend sensors

[[ $# -eq 5 ]] || usage
PID=$1
SENSOR=$2
STEMP=$3
RTEMP=$4
INTERVAL=$5

while ps -p ${PID} > /dev/null
do
    if [[ $[$(sensors -A ${SENSOR} | grep temp | cut -d+ -f2 -s | cut -d\. -f1) > ${STEMP}] -eq 1 ]]
    then
        kill -TSTP ${PID}
        until [[ $[$(sensors -A ${SENSOR} | grep temp | cut -d+ -f2 -s | cut -d\. -f1) < ${RTEMP}] -eq 1 ]]
        do
            sleep ${INTERVAL}s
        done
        kill -CONT ${PID}
    fi
    sleep ${INTERVAL}s
done
