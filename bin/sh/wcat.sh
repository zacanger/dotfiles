#!/bin/sh
exec wget -q -O - "$@" -e robots=off | most
