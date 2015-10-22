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

import urllib2

from HTMLParser import HTMLParser

class PremiumParser(HTMLParser):
	""""""
	def __init__(self, url, cookie):
		""""""
		HTMLParser.__init__(self)
		self.located = False
		self.url = None
		self.size = None
		self.handler = urllib2.build_opener(urllib2.HTTPCookieProcessor(cookie)).open(urllib2.Request(url))
		if "text/html" in self.handler.info()["Content-Type"]:
			for line in self.handler.readlines():
				self.feed(line)
				if "File size:" in line:
					self.size = line.strip()
			self.close()
		else:
			self.url = self.handler.geturl()

	def handle_starttag(self, tag, attrs):
		""""""
		if tag == "div":
			if ((len(attrs) > 1) and (attrs[1][1] == "downloadlink")):
				self.located = True
		elif tag == "a":
			if self.located:
				self.located = False
				self.url = attrs[0][1]

	def get_url(self):
		""""""
		return self.url

if __name__ == "__main__":
	from premium_cookie import PremiumCookie
	c = PremiumCookie()
	p = PremiumParser("http://www.megaupload.com/?d=RDAJ2PYH", c.get_cookie("",""))
	print p.get_url()
