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

import ImageOps

from core.tesseract import Tesseract
from core.url_open import URLOpen

BASE_URL = "http://www.easy-share.com"

class WaitParser:
	""""""
	def __init__(self, url):
		""""""
		self.wait = None
		try:
			opener = URLOpen()
			tmp = opener.open(url).readlines()
			for line in tmp:
				if "u=" in line:
					for line in opener.open("%s%s" % (BASE_URL, line.split("'")[1])).readlines():
						if "w=" in line:
							self.wait = int(line.split("'")[1]) + 1
							logger.info("%s wait %s seconds" % (url, self.wait))
		except Exception, e:
			logger.exception("%s :%s" % (url, e))


class CaptchaParser(HTMLParser):
	""""""
	def __init__(self, url):
		""""""
		HTMLParser.__init__(self)
		self.link = None
		self.form_action = None
		self.id = None
		self.handle = None
		self.captcha_url = None
		try:
			opener = URLOpen()
			for line in opener.open(url).readlines():
				self.feed(line)
			self.close()
			repeat = True
			if self.captcha_url:
				while True:
					tes = Tesseract(opener.open(self.captcha_url).read(), self.filter_image)
					captcha = tes.get_captcha()
					if len(captcha) > 4 and len(captcha) < 7:
						logger.warning("Captcha: %s" % captcha)
						self.handle = opener.open(self.form_action, urllib.urlencode([("captcha", captcha), ("id", self.id)]))
						if self.handle.info().getheader("Content-Type") != "text/html":
							break
		except Exception, e:
			logger.exception("%s :%s" % (url, e))

	def handle_starttag(self, tag, attrs):
		""""""
		if tag == "form":
			if attrs[0][1] == "captcha1":
				self.form_action = attrs[2][1]
		elif tag == "input":
			if self.form_action:
				if attrs[1][1] == "id":
					self.id =  attrs[2][1]
		elif tag == "img":
			if self.form_action:
				self.captcha_url = "%s%s" % (BASE_URL, attrs[0][1])

	def filter_image(self, image):
		""""""
		image = ImageOps.grayscale(image)
		return image

class CheckLinks:
	""""""
	def check(self, url):
		""""""
		name = None
		size = 0
		unit = None
		try:
			for line in URLOpen().open(url).readlines():
				if '<title>' in line:
					name = line.split("<title>Download ")[1].split(", upload your files and earn money.</title>")[0]
				if '<p class="pt15 pb0 px18 txtgray family2 c">' in line:
					tmp = line.split('<p class="pt15 pb0 px18 txtgray family2 c">')[1].split('</p>')[0].split(" ")
					unit = tmp.pop().split(")")[0]
					size = int(round(float(tmp.pop().split("(")[1])))
			if not unit:
				name = url
				size = -1
		except Exception, e:
			name = url
			size = -1
			logger.exception("%s :%s" % (url, e))
		return name, size, unit

if __name__ == "__main__":
	c = Parser("http://www.easy-share.com/1903816814/Frank%20Gehry%20-%20The%20City%20and%20the%20Music.pdf")
	#print CheckLinks().check("http://www.easy-share.com/1903816814/Frank%20Gehry%20-%20The%20City%20and%20the%20Music.pdf")
