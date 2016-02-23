#!/usr/bin/env python3
'''
4ChainThreadDumper.py
Copyright 2013 Wohlfe
Licensed under the WTFPLv2

Guess what this does? It takes a 4Chan board and thread and dumps that shit to your hard drive.
It does it via the API to, like it fucking should. Stop relying on third parties to save your "precious" threads.
Requires Python 3 and requests.

DON'T SPAM THIS SHIT more than once every 5 seconds, moot is watching you.
It's called 4Chain because moot's a cockslave to advertisers.
https://github.com/4chan/4chan-API#api-terms-of-service

syntax: 4ChanThreadDumper.py <board> <thread>
example: 4ChanThreadDumper.py c 12345

Coming soon:
Make it classy
Maybe some more configuration options
'''

import os
import sys
import requests
import json

if sys.version_info < (3, 0): #Checks the Python version
    raise "You have to use Python 3 or change the script."

try:
    board = sys.argv[1].rstrip().lower() #Expects a board, strips whitespace from it, makes it lowercase.
    thread = sys.argv[2].rstrip() #Expects a thread, strips whitespace from it.

    if board.startswith('/') or board.endswith('/'): #Checks if someone didn't follow the god damn directions and put slashes in the board name
        board = board.replace('/', '') #Replaces them shits

    if not isinstance(thread, int): #Checks if the thread syntax is an integer
        raise "You fucked up the thread syntax." #If not it tells you how much of an idiot you are

except IndexError:
    sys.exit("You fucked up the syntax:", err)

def ThreadDump(board, thread):
    URI = ''.join('http://api.4chan.org/', board, '/res/', thread, '.json')
    request = requests.

