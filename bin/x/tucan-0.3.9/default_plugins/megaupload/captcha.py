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
from core.tesseract import Tesseract

CAPTCHACODE = "captchacode"
MEGAVAR = "megavar"

class CaptchaParser(HTMLParser):
	""""""
	def __init__(self, data):
		""""""
		HTMLParser.__init__(self)
		self.located = False
		self.captcha = None
		self.captchacode = ""
		self.megavar = ""
		self.feed(data)
		self.close()

	def handle_starttag(self, tag, attrs):
		""""""
		if tag == "td":
			if self.get_starttag_text() == '<TD width="100" align="center" height="40">':
				self.located = True
		elif tag == "img":
			if self.located:
				self.located = False
				self.captcha = attrs[0][1]
		elif tag == "input":
			if attrs[1][1] == CAPTCHACODE:
				self.captchacode = attrs[2][1]
			elif attrs[1][1] == MEGAVAR:
				self.megavar = attrs[2][1]

class CaptchaForm(HTMLParser):
	""""""
	def __init__(self, url):
		""""""
		HTMLParser.__init__(self)
		self.link = None
		self.located = False
		tmp = url.split("/")
		if len(tmp) > 4:
			del tmp[3]
			url = "/".join(tmp)
		while not self.link:
			p = CaptchaParser(URLOpen().open(url).read())
			if p.captcha:
				handle = URLOpen().open(p.captcha)
				if handle.info()["Content-Type"] == "image/gif":
					self.tess = Tesseract(handle.read())
					captcha = self.get_captcha()
					if captcha:
						handle = URLOpen().open(url, urllib.urlencode([(CAPTCHACODE, p.captchacode), (MEGAVAR, p.megavar), ("captcha", captcha)]))
						self.reset()
						self.feed(handle.read())
						self.close()
						logger.info("Captcha %s: %s" % (p.captcha, captcha))

	def handle_starttag(self, tag, attrs):
		""""""
		if tag == "a":
			if ((self.located) and (attrs[0][0] == "href")):
				self.located = False
				self.link = attrs[0][1]
		elif tag == "div":
			if ((len(attrs) > 1) and (attrs[1][1] == "downloadlink")):
				self.located = True

	def get_captcha(self):
		result = self.tess.get_captcha()
		if len(result) == 4:
			return result

if __name__ == "__main__":
	c = CaptchaForm("http://www.megaupload.com/?d=RDAJ2PYH")
	print c.link
