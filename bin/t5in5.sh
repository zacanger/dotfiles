#!/usr/bin/env bash

for i in $(seq 1 10); do sleep 5 && ps -eo pcpu,pid,user,args | sort -rk1 | head -6; echo; done
