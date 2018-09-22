import sys, math, os, pprint

sys.ps1 = '> '
sys.ps2 = '. '

def paste():
    exec(sys.stdin.read(), globals())

pp = pprint.pprint
