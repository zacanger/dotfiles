#!/usr/bin/env bash

ps -eo pcpu,pid,user,args | sort -rk1 | head -6 | column -t
