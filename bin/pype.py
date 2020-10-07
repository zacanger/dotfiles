#!/usr/bin/env python

# example:
# echo three |  pype.py "print('one two {0}'.format(','.join(stdin)))"

import csv
import functools
import itertools
import json
import math
import operator
import os
import pprint
import sys
from sys import stdin, stdout
from sys import stdout


pp = pprint.pprint
args = list(sys.argv)
command = args.pop(1)
sys.argv = args
exec(command)
