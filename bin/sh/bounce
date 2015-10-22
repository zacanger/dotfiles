#!/bin/bash -i
kill -WINCH $$
set $(stty size)
LINES=${2:=24}
COLUMNS=${1:=80}
while :; do echo -n "[$((RANDOM%LINES));$((RANDOM%COLUMNS))H"; sleep 3; done &
