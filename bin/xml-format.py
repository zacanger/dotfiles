#!/usr/bin/env python

import sys
import xml.dom.minidom

filename = sys.argv[1]
dom = xml.dom.minidom.parse(filename)
pretty = dom.toprettyxml(indent="  ")

with open(filename, "r+") as f:
    f.seek(0)
    f.write(pretty)
    f.close()
