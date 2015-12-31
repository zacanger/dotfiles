#!/usr/bin/python

# StackFizzBuzz.py 
# (c) 2015 Tim Babb

# The FizzBuzz problem requires the construction of a well-known list of 
# interleaved numbers and nonsense words. The list has been studied 
# extensively, and recent work at CERN has constrained its utility to less 
# than 10^-16 of a mosquito's left nut. In modern times, the task of its 
# production is typically relegated to computer programs. It is also an open 
# question why some institutions continue to use FizzBuzz as a test of 
# programming ability, given universal knowledge of the test and the wide 
# availability of solutions on Google and StackOverflow. 

# Programs that solve FizzBuzz are typically constructed by hand in an ad-hoc 
# manner, often by inexperienced computer scientists. Below is presented an 
# algorithmic solution to the second-order problem of generating such 
# programs. In general, we define a class of nth-order FizzBuzz problems 
# which require the production of a program which solves the (n-1)th-order 
# FizzBuzz problem.

# We use a variation on the stacksort algorithm due to Munroe (2013) and 
# first implemented by Koberger (2013), which mimics a technique commonly 
# employed in the wild. Here, the availability of solutions on StackOverflow 
# is exploited to solve the second-order FizzBuzz problem in quadratic 
# time[citation needed].

# With reasonable probability, StackFizzBuzz finds, downloads, and executes a 
# FizzBuzz solution. Also, with small but nonzero probability, FizzBuzz may 
# root your computer. It is recommended that StackFizzBuzz not ever be run.

import os
import sys
import json
import re
import urllib2      as ul
import zlib         as zl
import gzip         as gz
import StringIO     as sio
import HTMLParser   as html
from htmlentitydefs import name2codepoint

# TODO: This will never find a correct answer if an intermediate test program loops 
#       forever. It should be a trivial matter to write some routine which detects 
#       ahead of time whether the test program will halt. This is left as an exercise 
#       to the reader.

SO_API         = 'http://api.stackexchange.com/2.2/'
INTERACTIVE    = True
NUMBERSTEXT_RE = re.compile('\d+|\w+', re.MULTILINE)


class FindCode(html.HTMLParser):
    # parse through html finding nodes that look like code blocks.
    # code blocks are simultaneously inside <code> and <pre> tags.
    
    def __init__(self):
        html.HTMLParser.__init__(self)
        self._codedepth = 0
        self._predepth  = 0
        self._code      = []
        self._cur_code  = ""
        
    def in_codeblock(self):
        return self._codedepth > 0 and self._predepth > 0
    
    def handle_starttag(self, tag, attrs):
        if tag.lower() == 'code':
            self._codedepth += 1
        elif tag.lower() == 'pre':
            self._predepth  += 1
    
    def handle_endtag(self, tag):
        popped = True
        if tag.lower() == 'code':
            self._codedepth -= 1
        elif tag.lower() == 'pre':
            self._predepth  -= 1
        else:
            popped = False
        if popped and len(self._cur_code) > 0:
            self._code.append(self._cur_code)
            self._cur_code = ""
    
    def handle_data(self, data):
        if self.in_codeblock():
            self._cur_code += data
    
    def handle_entityref(self, name):
        if self.in_codeblock():
            self._cur_code += unichr(name2codepoint[name])
    
    def handle_charref(self, name):
        if self.in_codeblock():
            if name.startswith('x'):
                c = unichr(int(name[1:], 16))
            else:
                c = unichr(int(name))
            self._cur_code += c
    
    def get_code(self):
        return self._code



def decode(response):
    """Decode an HTTP response packet."""
    enc = response.info().get("content-encoding")
    content = response.read()
    if enc in ('gzip', 'x-gzip'):
        content = gz.GzipFile('', 'rb', 9, sio.StringIO(content)).read()
    elif enc == 'deflate':
        content = zlib.decompress(content)
    return content


def get_request(req):
    """Make an HTTP request."""
    opener  = ul.build_opener()
    opener.addheaders = [('Accept-Encoding', 'gzip')]
    response = opener.open(req)
    data = decode(response)
    response.close()
    return data
    

def stackoverflow_req(call, params):
    """Make a StackOverflow query."""
    params.update({'site':'stackoverflow'})
    ext = "&".join(['%s=%s' % (ul.quote(k), ul.quote(str(v))) for k,v in params.iteritems()])
    url = SO_API + ( "?".join( (call, ext) ) )
    res = get_request(url)
    return json.loads(res)


def runcode(code, interactive=True):
    """Execute some python code `code` and capture its output, returning it as a string.
    If `code` is not a valid python program, return False. If `interactive` is true,
    present the code and prompt the user before executing."""
    
    # in case the sample program expects user input/interaction,
    # generate a list of 100 numbers for the program to read.
    s = "\n".join([str(x+1) for x in range(100)])
    numinput   = sio.StringIO(s)
    fizzoutput = sio.StringIO()
    
    if interactive:
        print "Running the following code:"
        print "---------------------------"
        print code
        print "---------------------------"
        if not raw_input("OK? (y/n): ").startswith('y'): return False
    
    sys.stdin  = numinput
    sys.stdout = fizzoutput
    success    = True
    
    
    ### DANGER DANGER ###
    try:
        exec(code)
    except:
        success = False
    #####################
    
    sys.stdout = sys.__stdout__
    sys.stdin  = sys.__stdin__
    
    if success:
        fizzoutput.seek(0)
        return fizzoutput.read()
    else:
        return False


def verify_fizzbuzz(code, interactive=True):
    """Verify that the python program `code` produces a valid FizzBuzz list.""" 
    data = runcode(code, interactive)
    if not data: return False
    
    # we are forgiving with separating junk
    # (whitespace, commas, quotes, etc.)
    # pull out the meaty bits and make sure they are correct
    matches = NUMBERSTEXT_RE.findall(data)
    
    # if we don't get a single "fizzbuzz", then we 
    # don't really have any evidence the program works, do we?
    if len(matches) < 15: return False
    
    for i,val in enumerate(matches):
        
        j = i + 1
        if   j % 3 == 0 and j % 5 == 0: expected  = 'fizzbuzz'
        elif j % 3 == 0:                expected  = 'fizz'
        elif j % 5 == 0:                expected  = 'buzz'
        else:                           expected  = str(j)
        
        if expected != val.lower(): return False
    
    return True
    

def second_order_fizzbuzz(interactive=True):
    """Find some code on StackOverflow that solves the FizzBuzz problem."""
    
    page = 1
    while True:
        # find some questions that match the tag
        results = stackoverflow_req('questions', 
                                    {'sort'     : 'activity', 
                                     'tagged'   : 'fizzbuzz;python',
                                     'page'     : str(page),
                                     'pagesize' : '25',
                                     'order'    : 'desc'})
        
        if len(results['items']) < 1: return False
        
        # iterate over the questions
        for q in results['items']:
            # list answers belonging to this question
            answers = stackoverflow_req('questions/%s/answers' % q['question_id'],
                                        {'sort'   : 'votes',
                                         'filter' : 'withbody'})['items']
            
            for a in answers:
                fc = FindCode()
                # parse HTML looking for nested <pre> and <code>
                fc.feed(a['body'])
                code = fc.get_code()
                
                # check each codeblock
                for c in code:
                    if len(code) > 0 and verify_fizzbuzz(c, interactive):
                        # got a valid fizzbuzz!
                        return c
        page += 1


############# Main program #############

if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser(
                        description="Solve the FizzBuzz problem by looking it up on StackOverflow. "
                       "This program downloads random code from the internet and executes it. "
                       "This is a terrible idea and should not be done ever.")
    parser.add_argument('--interactive', default=False, action="store_true",
                        help='Present code and prompt before executing each candidate')
    parser.add_argument('--yes', default=False, action="store_true",
                        help='Pass this flag to affirm that running this program is a bad idea.')
    parser.add_argument('--order', type=int, default=2,
                        help='Which meta-level of solution is desired?\n'
                        '1 = just print the damn list\n'
                        '2 = produce a program that prints the list\n'
                        '3 = produce a program that prints a program which produces the list')
    
    args = parser.parse_args()
    
    if not args.yes:
        print "\nRunning this program is a terrible idea because it downloads " \
              "random code from the internet and executes it. "
        print "Pass --yes to affirm that you understand how dumb it is to do this.\n"
        sys.exit(1)
    
    if args.order >= 3:
        with open(__file__, 'r') as f:
            print f.read()
    else:
        prog = second_order_fizzbuzz(args.interactive)
        if args.order == 1:
            exec(prog)
        elif args.order == 2:
            print prog
