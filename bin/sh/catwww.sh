#!/bin/sh

# cat website into pager

exec wget -q -O - "$@" -e robots=off | less

