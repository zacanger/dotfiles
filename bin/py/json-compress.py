#!/usr/bin/env python

import sys
import json

js = sys.stdin.read()

try:
    foo = json.loads(js)
    string = json.dumps(foo, sort_keys=True)
    print string
except ValueError:
    print js
