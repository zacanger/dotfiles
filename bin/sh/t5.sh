#!/bin/bash
# prints top 5 cpu hogs every 10 seconds; change 'hr' to 'echo " "' if you don't have an hr script/function
hr.sh; ps -eo pcpu,pid,user,args | sort -rk1 | head -6 | column -t; hr.sh;

