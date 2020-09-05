#!/usr/bin/env bash

# kills whatever is listening on the port, passed as first parameter
lsof -i :$1 |  grep -v COMMAND | awk '{ print $2 }' | xargs kill -9
