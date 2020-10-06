#!/usr/bin/env python

'''
Reformat a one-line shell command as a multiline shell command

From:

    someshellcommand.sh -f --foo 'this is a --string do not split'

To:

    someshellcommand.sh \
        -f  \
        --foo 'this is a --string do not split'

This is useful for, among other things, taking the "Copy as CURL" from the
Chrome developer tools network tab and making it readable.
'''

# https://github.com/whiteinge/dotfiles

import shlex
import sys

prev = ''
for i in shlex.shlex():
    if i.startswith('-'):
        if prev == '-':
            sys.stdout.write(i)
        else:
            sys.stdout.write(' \\\n    %s' % i)
    else:
        if prev == '-':
            sys.stdout.write('%s ' % i)
        else:
            sys.stdout.write(i)

    prev = i
