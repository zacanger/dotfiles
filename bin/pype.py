#!/usr/bin/env python

# example:
# echo three | pype.py "print('one two {0}'.format(','.join(stdin)))"

import pprint
import sys


pp = pprint.pprint
args = list(sys.argv)
command = args.pop(1)
sys.argv = args
exec(command)
