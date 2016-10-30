#!/bin/sh

# Collect data from a pipe in a temporary file and pass that file as an
# argument to the command given in arguments.
#
# Example:
# 	ls | giveto google-chrome

t=$(tempfile -p'giveto')
cat > "$t"
sleep 3 &
"$@" "$t"
wait
rm -f -- "$t"
