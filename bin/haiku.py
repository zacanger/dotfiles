#! /usr/bin/env python
import random

def get_possibilities(syllables):
    """
    returns list of all the ways to break down that many syllables into ones
    and zeroes
    """
    out = []
    c = syllables 
    while c >= 0:
        out.append([0]*(c/2) + [1]*(syllables - ((c/2)*2)))
        c -= 2 
    return out

def haiku_line(n):
    """
    makes a line of n syllables
    """
    l = random.choice(get_possibilities(n))
    random.shuffle(l) 
    return l

def say_in_english(line):
    out = ''
    for l in line:
        if l == 0:
            out += "zero"
        else:
            out += "one"
        out += ' '
    out = out[:-1] # snip off last space
    return out.capitalize()

def print_haiku():
    print say_in_english(haiku_line(5)) + ','
    print say_in_english(haiku_line(7)) + ','
    print say_in_english(haiku_line(5)) + '.'

if __name__ == "__main__":
    print_haiku()
