#!/usr/bin/env python

import re
import os
import sys
import codecs
# If using html2text localling instead of installed via pip/requirements:
# sys.path.insert(0, os.path.join(os.getcwd(), 'html2text'))

import html2text

ROOT_DIR = 'blog-posts'
HTML_EXT = re.compile('(.*?).html', re.IGNORECASE)

TITLE = re.compile('^# \[(.*)\]\((.*)\)')
AUTH = re.compile('^By \[(.*)\].*', re.IGNORECASE)
DATE = re.compile('^  .*: (\d{4}-\d{2}-\d{2})T.*', re.IGNORECASE)

def get_file_contents(filepath):
  with codecs.open(filepath, 'r', 'utf-8') as f:
    return f.read()

def format_author_tag(value):
  return '\n'.join(['author:', '  name: \'' + value + '\''])

def format_date_tag(value):
  return 'date: \'' + value + '\''

def format_title_tag(value):
  return 'title: \'' + value + '\''

def format_url_tag(value):
  return 'url: \'' + value + '\''

def tag_markdown(markdown):
  credits = ['---']
  stripped = []
  for line in iter(markdown.splitlines()):
    if TITLE.match(line):
      credits.append(format_title_tag(TITLE.match(line).group(1)))
      credits.append(format_url_tag(TITLE.match(line).group(2)))
    elif AUTH.match(line):
      credits.append(format_author_tag(AUTH.match(line).group(1)))
    elif DATE.match(line):
      credits.append(format_date_tag(DATE.match(line).group(1)))
    else:
      stripped.append(line)
  credits.append('---\n')
  return '\n'.join(credits) + '\n'.join(stripped)

def markup_to_markdown(markup):
  converter = html2text.HTML2Text()
  converter.body_width = 0
  converter.unicode_snob = 1
  markdown = converter.handle(markup).encode('utf-8')
  markdown = tag_markdown(markdown)
  return markdown

def convert_file(path):
  markup = get_file_contents(path)
  out = path.split('.html')[0] + '.md'
  with open(out, 'w') as f:
    markdown = markup_to_markdown(markup)
    f.write(markdown)

def convert_files(root_dir):
  for root, dirs, files in os.walk(root_dir):
    for f in files:
      if HTML_EXT.match(f):
        path = os.path.abspath(os.path.join(root, f))
        convert_file(path)

if __name__ == '__main__':
  convert_files(ROOT_DIR)
