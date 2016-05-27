#!/usr/bin/env bash

# call with ./thisscript.sh yourpassword commandtorun
# useful for example when you need to sleep x amount first,
# or... idk, whatever.

echo $1 | sudo -S $2

