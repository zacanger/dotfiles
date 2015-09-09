#!/usr/bin/env bash

#
# If called with a single argument, try running the help builtin for the given
# keyword, writing its output to a file. If it succeeds, show that. If not,
# pass the call to man(1).
#
# This was written so it could be used as a 'keywordprg' in Vim for Bash files;
# you can then use the K normal-mode binding over both shell builtins (e.g. read,
# set, export) and external programs (e.g. cat, grep, ed).
#
#     :set keywordprg=han
#
# You could put the above command in ~/.vim/after/ftplugin/sh.vim like this:
#
#     " Use han(1) as a man(1) wrapper for Bash files if available
#     if exists("b:is_bash") && executable('han')
#       setlocal keywordprg=han
#     endif
#
# Author: Tom Ryder <tom@sanctum.geek.nz>
# Copyright: 2015 Inspire Net Ltd
#
self=han

# Give up completely if no BASH_VERSINFO (<2.0)
if ! test "$BASH_VERSINFO" ; then
    return
fi

# Figure out the options with which we can call help; Bash >=4.0 has an -m
# option which prints the help output in a man-page like format.
declare -a helpopts
if ((BASH_VERSINFO[0] >= 4)) ; then
    helpopts=(-m)
fi

# Create a temporary file and set up a trap to get rid of it.
tmpdir=$(mktemp -dt "$self".XXXXX) || exit
cleanup() {
    rm -fr -- "$tmpdir"
}
trap cleanup EXIT

# If we have exactly one argument and a call to the help builtin with that
# argument succeeds, display its output with `pager -s`.
if (($# == 1)) && \
   help "${helpopts[@]}" "$1" >"$tmpdir"/"$1".help 2>/dev/null ; then
    (cd -- "$tmpdir" && pager -s -- "$1".help)

# Otherwise, just pass all the arguments to man(1).
else
    man "$@"
fi

