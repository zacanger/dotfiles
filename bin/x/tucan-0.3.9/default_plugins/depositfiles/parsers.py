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

BASE_URL = "http://depositfiles.com"

class Parser(HTMLParser):
	def __init__(self, url):
		""""""
		HTMLParser.__init__(self)
		self.link = None
		self.form_action = None
		self.input = None
		self.wait = None
		self.found = False
		try:
			opener = URLOpen()
			self.feed(opener.open(url).read())
			self.close()
			if self.form_action:
				form = urllib.urlencode({"": self.input, "gateway_result":"1"})
				for line in opener.open("%s%s" % (BASE_URL, self.form_action), form).readlines():
					if self.wait:
						self.feed(line)
					else:
						if '<td><span id="download_waiter_remain">' in line:
							self.wait = int(line.split('<td><span id="download_waiter_remain">')[1].split('</span></td>')[0])
				self.close()
		except Exception, e:
			logger.exception("%s :%s" % (url, e))

	def handle_starttag(self, tag, attrs):
		""""""
		if self.wait:
			if self.found:
				if tag == "form":
					self.link = attrs[0][1]
				elif tag == "input":
					for ref, value in attrs:
						if ref == "value":
							self.input = value
							self.found = False
			elif tag == "div":
				if len(attrs) > 0 and attrs[0][1] == "download_url":
					self.found = True
			
		else:
			if self.found:
				if tag == "form":
					self.form_action = attrs[0][1]
				elif tag == "input":
					for ref, value in attrs:
						if ref == "value":
							self.input = value
							self.found = False
			elif tag == "div":
				if attrs[0][1] == "downloadblock":
					self.found = True



class CheckLinks:
	""""""
	def check(self, url):
		""""""
		name = None
		size = 0
		unit = None
		try:
			for line in URLOpen().open(url).readlines():
				if '<b title="' in line:
					name = line.split('<b title="')[1].split('">')[0]
				if '<span class="nowrap">' in line:
					tmp = line.split('<b>')[1].split('</b>')[0].split("&nbsp;")
					unit = tmp.pop()
					size = int(round(float(tmp.pop())))
			if not unit:
				name = url
				size = -1
		except Exception, e:
			name = url
			size = -1
			logger.exception("%s :%s" % (url, e))
		return name, size, unit

if __name__ == "__main__":
	c = Parser("http://depositfiles.com/files/7n5ulr17r")
	#print CheckLinks().check("http://depositfiles.com/files/7n5ulr17r")
