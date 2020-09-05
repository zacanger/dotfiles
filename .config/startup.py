import sys
import math
import os
import pprint

sys.ps1 = "> "
sys.ps2 = ". "


def paste():
    exec(sys.stdin.read(), globals())


pp = pprint.pprint
