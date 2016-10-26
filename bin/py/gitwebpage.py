#!/usr/bin/env python3

import webbrowser

from subprocess import Popen, PIPE

with Popen(['git', 'remote', 'get-url', 'origin'], stdout=PIPE) as proc:
  out = proc.stdout.read()

if len(out) != 0:
  url = out.rstrip().decode('utf-8')
  if url.endswith('.git'):
    url = url[:-4]
  if url.startswith('git@'):
    url = url[4:].replace(':', '/')
  if not url.startswith('https://'):
    url = 'https://' + url
  webbrowser.open(url)
