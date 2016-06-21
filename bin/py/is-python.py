#!/usr/bin/env python

import json
import sys

changes = json.load(sys.stdin)

binpkgs = changes['Binary'].split()
for pkg in binpkgs:
    if "python" in pkg:
        print "I: PT: I think this is a python package."
        sys.exit(0)
print "I: PT: I don't think this is a python package."
sys.exit(1)
