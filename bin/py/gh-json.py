#!/usr/bin/env python

import sys, json

def print_json(json, attrs):
  if type(json) == list:
    for item in json:
      print_json(item, attrs)
  else:
    for attr in attrs:
      dot = attr.find('.')
      if (dot == -1):
        print json[attr]
      else:
        print_json(json[attr[0:dot]], [attr[dot+1:]])

try:
  json = json.load(sys.stdin, strict=False)
  print_json(json, sys.argv[1:])

except ValueError:
  sys.exit(1)
