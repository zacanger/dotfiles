#: c01:differentReturns.py
def differentReturns(arg):
  if arg == 1:
    return "one"
  if arg == "one":
    return 1

print differentReturns(1)
print differentReturns("one")
#<hr>
output = '''
one
1
'''
