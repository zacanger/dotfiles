#!/usr/bin/env bash

#
# edda(1) -- Run ed(1) over multiple files, duplicating stdin. Example:
#
#   $ edda -s /etc/app.d/*.conf <<EOF
#   ,s/foo/bar/g
#   w
#   EOF
#
# Author: Tom Ryder <tom@sanctum.geek.nz>
# Copyright: 2015
# License: Public domain
#

# Name self
self=edda

# Define usage function
usage() {
    printf 'USAGE: %s [OPTS] [--] FILE1 [FILE2...]\n' "$self"
}

# Need at least one file
if ! (($#)) ; then
    usage >&2
    exit 1
fi

# Need ed(1) -- some systems daring to call themselves UNIX-like don't have it
# installed by default. What's POSIX, precious?
hash ed || exit

# Parse options out, give help if necessary
declare -a opts
for arg ; do
    case $arg in
        --help|-h|-\?)
            usage
            exit
            ;;
        --)
            shift
            break
            ;;
        -*)
            shift
            opts=("${opts[@]}" "$arg")
            ;;
    esac
done

# Duplicate stdin into a file, which we'll remove on exit
stdin=$(mktemp) || exit
cleanup() {
    rm -f -- "$stdin"
}
trap cleanup EXIT
cat > "$stdin"

# Run ed(1) over each file with the options and stdin given
for file ; do
    ed "${opts[@]}" -- "$file" < "$stdin"
done

