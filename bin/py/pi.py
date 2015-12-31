#!/usr/bin/env python

"""Spigot generators for decimal digits of pi, implemented in python.

Algorithms from Jeremy Gibbons:
http://web.comlab.ox.ac.uk/oucl/work/jeremy.gibbons/publications/spigot.pdf
"""

def decimal_digits():
  """Proved-correct generator for digits of pi"""
  q,r,t,k,n,l = 1,0,1,1,3,3
  while True:
    if 4*q+r-t < n*t:
      yield n
      q,r,t,k,n,l = (10*q,10*(r-n*t),t,k,(10*(3*q+r))//t-10*n,l)
    else:
      q,r,t,k,n,l = (q*k,(2*q+r)*l,t*l,k+1,(q*(7*k+2)+r*l)/(t*l),l+2)

def decimal_digits_fast():
  """Faster but not-proved correct generator for digits of pi"""
  q,r,t,j = 1,180,60,2
  while True:
    u,y = (3*(3*j+1)*(3*j+2), (q*(27*j-12)+5*r)//(5*t))
    yield y
    q,r,t,j = (10*q*j*(2*j-1),10*u*(q*(5*j-2)+r-y*t),t*u,j+1)

if __name__ == '__main__':
  import sys
  digits = decimal_digits_fast()
  print '%5d: %d.%s' % (
      0, digits.next(), ''.join([str(digits.next()) for j in xrange(49)]))
  count = 50
  while 1:
    print '%6d: %s' % (
      count, ''.join([str(digits.next()) for j in xrange(50)]))
    count += 50
    sys.stdout.flush()