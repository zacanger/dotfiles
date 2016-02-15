#!/usr/bin/env python

import sys

if len(sys.argv) > 1:
    n = int(sys.argv[1]) - 1
else:
    n = 20

print r'''
_______
   \   \
    \   \
''',
print '     |   |\n' * n,
print r'''     |   |
    /   /
___/___/
'''
