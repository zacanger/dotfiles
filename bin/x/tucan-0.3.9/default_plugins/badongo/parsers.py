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
import cookielib
import logging
logger = logging.getLogger(__name__)

import ImageOps

from HTMLParser import HTMLParser

from core.tesseract import Tesseract
from core.url_open import URLOpen

BASE_URL = "http://www.badongo.com"

class Parser(HTMLParser):
	def __init__(self, url):
		""""""
		HTMLParser.__init__(self)
		self.link = None
		self.form_action = None
		self.cap_id = None
		self.cap_secret = None
		self.captcha_url = None
		self.wait = None
		try:
			while not self.link:
				cookie = cookielib.CookieJar()
				self.opener = URLOpen(cookie)
				data = urllib.urlencode([("rs", "refreshImage"), ("rst", ""), ("rsrnd", "1247603497783")])
				tmp = self.opener.open(url, data).read().split("+:var res = '")[1].split("'; res;")[0].replace('\\"', '"')
				self.feed(tmp)
				self.close()
				if self.captcha_url:
					unresolved = True
					cont = 0
					while unresolved and cont < 4:
						tes = Tesseract(self.opener.open(self.captcha_url).read(), self.filter_image)
						captcha = tes.get_captcha()
						if len(captcha) == 4 and captcha.isalpha() and captcha.isupper():
							logger.info("Captcha: %s" % captcha)
							data = urllib.urlencode([("user_code", captcha), ("cap_id", self.cap_id), ("cap_secret", self.cap_secret)])
							handle = self.opener.open(self.form_action, data)
							for line in handle.readlines():
								if "var check_n = " in line:
									self.wait = int(line.split("var check_n = ")[1].split(";")[0])
								elif 'req.open("GET",' in line:
									unresolved = False
									self.link = line.split(",")[1].split('"')[1].replace("status", "loc")
							cont += 1
		except Exception, e:
			logger.exception("%s :%s" % (url, e))

	def handle_starttag(self, tag, attrs):
		""""""
		if tag == "form":
			self.form_action = attrs[1][1]
		elif tag == "input":
			if attrs[1][1] == "cap_id":
				self.cap_id =  attrs[2][1]
			elif attrs[1][1] == "cap_secret":
				self.cap_secret =  attrs[2][1]
		elif tag == "img":
			self.captcha_url = "%s%s" % (BASE_URL, attrs[0][1])

	def filter_image(self, image):
		""""""
		image = ImageOps.grayscale(image)
		image = image.point(self.filter_pixel)
		return image

	def filter_pixel(self, pixel):
		""""""
		if pixel > 85:
			return 255
		else:
			return 1

class CheckLinks:
	""""""
	def check(self, url):
		""""""
		name = None
		size = 0
		unit = None
		try:
			for line in URLOpen().open(url).readlines():
				if '<div class="finfo">' in line:
					name = line.split('<div class="finfo">')[1].split('</div>')[0]
					if ".." in name:
						tmp = url.split("/").pop().split("_")
						name = ".".join(tmp)
				elif '<div class="ffileinfo">' in line:
					tmp = line.split(':').pop().split("</div>")[0].strip().split(" ")
					size = int(tmp[0])
					if size == 0:
						size = 1
					unit = tmp[1]
					if unit == "B":
						size = 1
						unit = "KB"
			if not name:
				name = url
				size = -1
		except Exception, e:
			name = url
			size = -1
			logger.exception("%s :%s" % (url, e))
		return name, size, unit

if __name__ == "__main__":
	c = Parser("http://www.badongo.com/file/15008452")
	#print CheckLinks().check("http://www.badongo.com/file/15008452")
