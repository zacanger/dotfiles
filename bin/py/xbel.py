#!/usr/bin/python

## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
## (at your option) any later version.

## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.

## You should have received a copy of the GNU General Public License
## along with this program; if not, write to the Free Software
## Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

# Copyright 2001 by Lennart Poettering <mz7862656c6d61726b@poettering.de>
# This script will create a HTML page of your Galeon/XBEL XML Bookmarks

# Further information, usage examples and current versions may be found on
# http://www.stud.uni-hamburg.de/users/lennart/projects/xbelmark/

# You might want to change the first line to adapt it to your local
# python installation

import sys, string, re, time, locale, getopt
from xml.sax import make_parser, handler, SAXException
from xml.sax.saxutils import *

extractMode = 0
noIndexMode = 0
noTopLinksMode = 0

def htmlize(text) :
	return text.replace("&", "&amp;").replace("\"", "&quot;").replace("<", "&gt;").replace("<", "&lt;")

class Bookmark:

	def __init__(self, name, url):
		self.name = name
		self.url = url

	def toHtml(self):
		return "<a href=\"%s\">%s</a>" % (htmlize(self.url), htmlize(self.name))

	def __cmp__(self, other):
		return cmp(self.name, other.name)

class Folder:

	def __init__(self, name = ""):
		self.name = name
		self.name = ""
		self.bookmarks = []
		self.subfolders = []

	def addBookmark(self, name = "", url = ""):
		b = Bookmark(name, url)
		self.bookmarks.append(b)
		return b

	def addSubfolder(self, name = ""):
		f = Folder(name)
		self.subfolders.append(f)
		return f

	def toHtml(self, level=0, prefix=""):
		self.bookmarks.sort()
		self.subfolders.sort()

		s = ""

		if level != 0:
			s = "<a name=\"%s\"/><h%i>%s. %s</h%i>\n<div style=\"margin-left:20px\">\n" % (prefix, level+1, prefix, htmlize(self.name), level+1)
			prefix += "."

		for b in self.bookmarks:
			s += "%s<br>\n" % b.toHtml()

		i = 1
		for f in self.subfolders:
			s += "%s" % f.toHtml(level+1, prefix + `i`)
			i += 1

		if level != 0:
			s += "</div>\n"

		if not noTopLinksMode and level == 1:
			s += "<br><small><a href=\"#top\">Top</a></small>\n"

		return s

	def toHtmlIndex(self, level=0, prefix=""):
		self.subfolders.sort()

		s = ""

		if level != 0:
			s = "<tr><td>%s.</td><td><a href=\"#%s\">%s</a></td></tr>\n" % (prefix, prefix, htmlize(self.name))
			prefix += "."

		if level < 1:
			if level == 0:
				s = "<table summary=\"Index\">\n"
			
			i = 1
			for f in self.subfolders:
				s += "%s" % f.toHtmlIndex(level+1, prefix + `i`)
				i += 1

			if level == 0:
				s += "</table>\n"

		return s

	def __cmp__(self, other):
		return cmp(self.name, other.name)

class MyHandler(handler.ContentHandler):

	def __init__(self):
		self.title = ""
		self.folderStack = []
		self.currentFolder = None
		self.currentBookmark = None

		self.bookmarkCount = 0
		self.folderCount = 0

	def startDocument(self):
		self.currentFolder = Folder("root")

	def endDocument(self):
		pass

	def startElement(self, name, attrs):

		if name == "folder":
			self.folderStack.append(self.currentFolder)
			self.currentFolder = self.currentFolder.addSubfolder("unknown")
			self.folderCount += 1

		elif name == "bookmark" and attrs.has_key("href"):
			self.currentBookmark = self.currentFolder.addBookmark("unknown", attrs["href"])
			self.bookmarkCount += 1

		elif name == "title":
			self.title = ""

	def endElement(self, name):

		if name == "folder":
			self.currentFolder = self.folderStack.pop()

		elif name == "bookmark":
			self.currentBookmark = None

		elif name == "title":
			if not self.currentBookmark is None:
				self.currentBookmark.name = self.correctCharset(self.title)
			elif not self.currentFolder is None:
				self.currentFolder.name = self.correctCharset(self.title)


	def characters(self, content):
		self.title += content

	def correctCharset(self, s):
		return s #unicode(s.encode("iso8859-1"), "utf-8")

	def toHtml(self):

		s = ""

		if not extractMode:
			s = '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">\n'
			s += '<html>\n<head>\n'
			s += '<style type="text/css">\n body,p,td,div,tr,h1,h2,h3,h4 { font-family: verdana,arial,sans-serif; }\n</style>'
			s += '<meta http-equiv="content-type" content="text/html; charset=iso-8859-1">\n'
			s += '<title>Bookmarks for %s</title>\n<body bgcolor="white" text="black" link="red" alink="red" vlink="red">\n<a name="top"/>\n' % os.environ['USER'].capitalize()
			s += '<h1>Bookmarks for %s</h1>' % os.environ['USER'].capitalize()

		if not noIndexMode:
			s += self.currentFolder.toHtmlIndex().encode("iso8859-1", "replace")

			s += '<p><small>This file consists of %i bookmarks in %i folders.</small></p>\n' % (self.bookmarkCount, self.folderCount)
			s += '<hr>'
		
		s += self.currentFolder.toHtml().encode("iso8859-1", "replace")

		if not extractMode:
			s += '<br><hr>'
			s += '<small>Generated with <a href="http://www.stud.uni-hamburg.de/users/lennart/projects/xbelmark/xbelmark.html">xbelmark.py</a> by <a href="mailto:mz7862656c6d61726b@poettering.de">Lennart Poettering</a> 2002</small>\n'
			s += '</body>\n</html>\n'

		return s
		
def usage():
	print "%s [-e] [-i] [-h] [-t]\n  -e Extract mode (disables HTML headers)\n  -i No index mode\n  -h Help mode\n  -t No top links" % sys.argv[0]

def main():
	global extractMode, noIndexMode, noTopLinksMode
	
	try:
		opts, args = getopt.getopt(sys.argv[1:], "heit", ["help", "extract", "noindex", "notop"])
	except getopt.GetoptError:
		usage()
		sys.exit(2)
		
	for o, a in opts:
		if o in ("-h", "--help"):
			usage()
			sys.exit()
			
		if o in ("-e", "--extract"):
			extractMode = 1

		if o in ("-i", "--noindex"):
			noIndexMode = 1

		if o in ("-t", "--notop"):
			noTopLinksMode = 1

	if len(args) != 0:
		if args[0] != "-":
			f = args[0]
		else:
			f = sys.stdin
	else:
		f = "%s/.galeon/bookmarks.xbel" % os.environ['HOME']

	m = MyHandler()
	parser = make_parser()
	parser.setContentHandler(m)

	try:
		parser.parse(f)
		print m.toHtml(),
	except OSError, e:
		print "Could not read file: %s" % str(e)
	except SAXException, e:
		print "Could not parse file: %s" % str(e)

if __name__ == "__main__":
	main()
