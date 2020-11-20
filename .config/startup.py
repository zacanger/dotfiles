import csv
import functools
import itertools
import json
import math
import operator
import os
import pprint
import sys


sys.ps1 = "> "
sys.ps2 = ". "
pp = pprint.pprint


def paste():
    exec(sys.stdin.read(), globals())


def doc(x):
    print(x.__doc__)
