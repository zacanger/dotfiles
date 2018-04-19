#!/usr/bin/env python3

import os
import sys
import getopt
from lxml import etree

def getxpath(fd, xpath, attribute=None, encoding=None):
  try:
    parser = etree.HTMLParser(encoding=encoding)
    xml = etree.parse(fd, parser)
    sels = xml.xpath(xpath)

  except AssertionError:
    return None

  if attribute != None:
    return "\n".join(["".join(i.attrib[attribute]) for i in sels])

  return "".join([("".join(i.itertext())).strip() for i in sels])

def usage(app):
  app = os.path.basename(app)
  sys.stderr.write("usage: %s [-h] [-e encoding] "\
                   "[-a attribute] xpath\n" % (app))
  sys.exit(1)

def main(args):
  try:
    opts, largs = getopt.getopt(args[1:], "he:a:")
  except getopt.GetoptError as err:
    print(str(err))
    usage(args[0])

  encoding = None
  attribute = None

  for o, a in opts:
    if o == "-h": usage(args[0])
    elif o == "-e": encoding = a
    elif o == "-a": attribute = a
    else: assert False, "unhandled option"

  if len(largs) < 1: usage(args[0])

  rpath = getxpath(sys.stdin, largs[0], attribute, encoding)

  if rpath == None: return 1

  sys.stdout.write(rpath)

  return 0

if __name__ == "__main__":
  sys.exit(main(sys.argv))
