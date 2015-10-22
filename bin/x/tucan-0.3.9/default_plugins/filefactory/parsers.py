###############################################################################
## Tucan Project
##
## Copyright (C) 2008-2009 Fran Lupion crak@tucaneando.com
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; if not, write to the Free Software
## Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
###############################################################################

import urllib
import logging
logger = logging.getLogger(__name__)

from HTMLParser import HTMLParser

from core.url_open import URLOpen

BASE_URL = "http://www.filefactory.com"

class Parser(HTMLParser):
	def __init__(self, url):
		""""""
		HTMLParser.__init__(self)
		self.link_found = False
		self.time_found = False
		self.link = None
		self.wait = None
		try:
			for line in URLOpen().open(url).readlines():
				if 'alt="Download Now"' in line:
					button_action = "%s%s" % (BASE_URL, line.split('<a href="')[1].split('">')[0])
					self.feed(URLOpen().open(button_action, urllib.urlencode({"freeBtn": "Free Download"})).read())
			self.close()
		except Exception, e:
			logger.exception("%s :%s" % (url, e))

	def handle_starttag(self, tag, attrs):
		""""""
		if tag == "a":
			if self.link_found:
				self.link = attrs[0][1]
				self.link_found = False
		elif tag == "div":
			if len(attrs) > 0:
				if attrs[0][1] == "basicBtn":
					self.time_found = True
				elif attrs[0][1] == "downloadLink":
					self.link_found = True
		elif tag == "input":
			if self.time_found:
				self.wait = int(attrs[2][1])
				self.time_found = False

class CheckLinks:
	""""""
	def check(self, url):
		""""""
		name = None
		size = 0
		unit = None
		try:
			for line in URLOpen().open(url).readlines():
				if '<span href="" class="last">' in line:
					name = line.split('<span href="" class="last">')[1].split('</span>')[0]
					if ".." in name:
						tmp = url.split("/").pop().split("_")
						name = ".".join(tmp)
				elif "file uploaded" in line:
					tmp = line.split("file uploaded")[0].split("<span>")[1].split(" ")
					size = int(float(tmp[0]))
					if size == 0:
						size = 1
					unit = tmp[1]
			if not name:
				name = url
				size = -1
		except Exception, e:
			name = url
			size = -1
			logger.exception("%s :%s" % (url, e))
		return name, size, unit

if __name__ == "__main__":
	c = Parser("http://www.filefactory.com/file/cc646e/n/Music_Within_2007_Sample_avi")
	print c.link
	#print CheckLinks().check("http://www.filefactory.com/file/cc646e/n/Music_Within_2007_Sample_avi")
