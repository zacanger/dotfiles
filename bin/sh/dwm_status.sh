#!/bin/bash
#
# dwm_status.sh
#
# CREATED:  long ago
# MODIFIED: 2009-08-26 18:31

host=$(hostname)
user=$USER

while true
do
    date=$(date +"%I:%M")
    echo "$user@$host  [ $date ]"
    sleep 1m
done
