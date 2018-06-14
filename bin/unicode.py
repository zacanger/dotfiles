#!/usr/bin/python3

unicodeChars = chr(1)

for i in range(2, 1114111):
  try:
    unicodeChars = str(unicodeChars + chr(i))
    print(i)
  except UnicodeEncodeError:
    print('UnicodeEncodeError')

print(unicodeChars)
