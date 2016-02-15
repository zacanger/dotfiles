#!/bin/bash

# Usage: `serialgen [width]` (default: 8 B)

[[ $# -lt 1 ]] &&
B=8 ||
B=$1

dd if=/dev/urandom bs=1 count="$B" 2>/dev/null |
od -A n -t d"$B" |
sed 's/^[[:space:]]*//'
