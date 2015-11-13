#: c01:myFunction.py
def myFunction(response):
  val = 0
  if response == "yes":
    print "affirmative"
    val = 1
  print "continuing..."
  return val

print myFunction("no")
print myFunction("yes")
#<hr>
output = '''
continuing...
0
affirmative
continuing...
1
'''
