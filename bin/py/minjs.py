#!/usr/bin/env python

# -*- coding: utf-8 -*-
import sys
import requests

try:
    js_file = sys.argv[1]
except:
    print("please specify input file")
    sys.exit()

# Grab the file contents
with open(js_file, 'r') as c:
    js = c.read()

# Pack it, ship it
payload = {'input': js}
url = 'https://javascript-minifier.com/raw'
print("minifying {}. . .".format(c.name))
r = requests.post(url, payload)

# Write out minified version
minified = js_file.rstrip('.js')+'.min.js'
with open(minified, 'w') as m:
    m.write(r.text)

print("minified! See {}".format(m.name))
