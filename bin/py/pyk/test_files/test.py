#!/usr/bin/env python
# -*- coding: utf-8 -*-

## Second comment type

__version__ = "0.1.3"

list1 = [a,b,c]
dic1 = {a:b, c:d}
tup1 = (x,y,z)

number1 = 0.823
number2 = -6L

# Problematic cases with Python highlighting:    

str1 = 'ali' # there
str2 = "baba" # here
str3 = """do not 
		kill """ # a comment here
str4 = '''koa
		las''' #fsfsdfsdfsd

x = """
...
""" # a comment behind

x = "this is a comment # inside a string" # this is a real 'comment' isn't it ?

y = ("#00ffcc", x)

# End problematic cases with Python highlighting:  

import os
from PyQt4 import QtGui, QtCore
import generic_highlighter

def somefunction(koala):
    print "I'm %s"%(koala)

class Foo(object):
    _instances = 0
	
    def __init__(self, parent):
        self.parent = parent
        self.connect( self, QtCore.SIGNAL( "textChanged()" ),  QtCore.SLOT("update()") )
        
    @classmethod
    def add(cls):
        cls.instances += 1

if __name__ == "__main__":
    print 'toto!'
