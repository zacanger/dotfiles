#: c04:StateDemo.py
# Simple demonstration of the State pattern.

class State_d:
  def __init__(self, imp): 
    self.__implementation = imp 
  def changeImp(self, newImp):
    self.__implementation = newImp
  # Delegate calls to the implementation:
  def __getattr__(self, name):
    return getattr(self.__implementation, name)

class Implementation1:
  def f(self): 
    print "Fiddle de dum, Fiddle de dee," 
  def g(self): 
    print "Eric the half a bee." 
  def h(self): 
    print "Ho ho ho, tee hee hee," 

class Implementation2:
  def f(self): 
    print "We're Knights of the Round Table." 
  def g(self): 
    print "We dance whene'er we're able." 
  def h(self): 
    print "We do routines and chorus scenes" 

def run(b):
  b.f()
  b.g()
  b.h()
  b.g()

b = State_d(Implementation1())
run(b)
b.changeImp(Implementation2())
run(b)
#<hr>
output = '''
Fiddle de dum, Fiddle de dee,
Eric the half a bee.
Ho ho ho, tee hee hee,
Eric the half a bee.
We're Knights of the Round Table.
We dance whene'er we're able.
We do routines and chorus scenes
We dance whene'er we're able.
'''
