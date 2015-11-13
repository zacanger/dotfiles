#: c04:statemachine:State.py
# A State has an operation, and can be moved
# into the next State given an Input:

class State:
  def run(self): 
    assert 1, "run not implemented"
  def next(self, input):
    assert 1, "next not implemented"
#:~