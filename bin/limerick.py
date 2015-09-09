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

def limerick_line(syllables, rhyme):
    """
    makes a line of n syllables, ending in the rhyme
    """
    syl = syllables - len(rhyme)
    l = random.choice(get_possibilities(syl))
    random.shuffle(l) 
    return l + rhyme

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

def bit():
    return random.choice([0,1])

def make_rhyme():
    if bool(random.getrandbits(1)):
        return [bit(), bit()]
    else:
        return [bit(), bit(), bit()]

def punc():
    return random.choice(['', '.', ','])

def end_punc():
    return random.choice(['!', '...', '.'])

def print_limerick():
    rhyme_a = make_rhyme()
    rhyme_b = make_rhyme()
    count_a = random.choice([8, 9, 10, 11])
    count_b = random.choice([5, 6, 7])

    print say_in_english(limerick_line(count_a, rhyme_a)) + punc()
    print say_in_english(limerick_line(count_a, rhyme_a)) + punc()
    print say_in_english(limerick_line(count_b, rhyme_b)) + punc()
    print say_in_english(limerick_line(count_b, rhyme_b)) + punc()
    print say_in_english(limerick_line(count_a, rhyme_a)) + end_punc()

if __name__ == "__main__":
    print_limerick()
