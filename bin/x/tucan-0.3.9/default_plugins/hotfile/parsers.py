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

BASE_URL = "http://hotfile.com"

class CaptchaParser(HTMLParser):
	def __init__(self, url,  form):
		""""""
		HTMLParser.__init__(self)
		self.link = None
		self.action_captcha = None
		self.captchaid = None
		self.hash1 = None
		self.hash2 = None
		self.captcha_url = None
		try:
			opener = URLOpen()
			tmp = opener.open(url, form).readlines()
			for line in tmp:
				self.feed(line)
				self.close()
			if self.action_captcha:
				tes = Tesseract(opener.open(self.captcha_url).read(), self.filter_image)
				captcha = tes.get_captcha()
				logger.warning("Captcha: %s" % captcha)
				form = urllib.urlencode([("action", self.action_captcha), ("captchaid", self.captchaid), ("hash1", self.hash1), ("hash2", self.hash2), ("captcha", captcha)])
				tmp = opener.open(url, form).readlines()
			for line in tmp:
				if '<table class="downloading"><tr><td>Downloading <b>' in line:
					if "href" in line:
						tmp = line.split('<a href="')[1].split('">')[0].split("/")
						tmp.append(urllib.quote(tmp.pop()))
						self.link = "/".join(tmp)
		except Exception, e:
			logger.exception("%s :%s" % (url, e))

	def handle_starttag(self, tag, attrs):
		""""""
		if tag == "input":
			if ("name", "action") in attrs:
				for ref, value in attrs:
					if ref == "value" and value == "checkcaptcha":
						self.action_captcha = value
			elif ("name", "captchaid") in attrs:
				for ref, value in attrs:
					if ref == "value":
						self.captchaid = value
			elif ("name", "hash1") in attrs:
				for ref, value in attrs:
					if ref == "value":
						self.hash1 = value
			elif ("name", "hash2") in attrs:
				for ref, value in attrs:
					if ref == "value":
						self.hash2 = value
		elif tag == "img":
			self.captcha_url = "%s%s" % (BASE_URL, attrs[0][1])
			
	def filter_image(self, image):
		""""""
		image = image.point(self.filter_pixel)
		image = ImageOps.grayscale(image)
		return image

	def filter_pixel(self, pixel):
		""""""
		if pixel > 110:
			return 255
		if pixel > 90:
			return 100
		else:
			return 1

class Parser(HTMLParser):
	def __init__(self, url):
		""""""
		HTMLParser.__init__(self)
		self.link = None
		self.form = None
		self.tm = None
		self.tmhash = None
		self.waithash = None
		self.wait = None
		try:
			opener = URLOpen()
			self.feed(opener.open(url).read())
			self.close()
			self.form = urllib.urlencode([("action", "capt"), ("tm", self.tm), ("tmhash", self.tmhash), ("wait", self.wait), ("waithash", self.waithash)])
		except Exception, e:
			logger.exception("%s :%s" % (url, e))

	def handle_starttag(self, tag, attrs):
		""""""
		if self.link:
			if tag == "input":
				if ("name", "tm") in attrs:
					for ref, value in attrs:
						if ref == "value":
							self.tm = value
				elif ("name", "tmhash") in attrs:
					for ref, value in attrs:
						if ref == "value":
							self.tmhash = value
				elif ("name", "wait") in attrs:
					for ref, value in attrs:
						if ref == "value":
							self.wait = int(value)
				elif ("name", "waithash") in attrs:
					for ref, value in attrs:
						if ref == "value":
							self.waithash = value
		else:
			if tag == "form":
				if len(attrs) > 3:
					self.link = "%s%s" % (BASE_URL, attrs[1][1])

class CheckLinks:
	""""""
	def check(self, url):
		""""""
		name = None
		size = 0
		unit = None
		try:
			for line in URLOpen().open(url).readlines():
				if '<table class="downloading">' in line:
					name = line.split('Downloading <b>')[1].split('</b>')[0]
					tmp = line.split('<span class="size">|')[1].strip().split('</span>')[0]
					unit = tmp[-2:].upper()
					size = int(round(float(tmp[:-2])))
			if not unit:
				name = url
				size = -1
		except Exception, e:
			name = url
			size = -1
			logger.exception("%s :%s" % (url, e))
		return name, size, unit

if __name__ == "__main__":
	c = Parser("http://hotfile.com/dl/7174149/00fbb47/Sander_Van_Doorn-Live_at_Sensation_White_Saint-Petersburg-12062009.mp3.html")
	print c.link
	print c.form
	import time
	for i in range(c.wait):
		print i
		time.sleep(1)
	m = CaptchaParser(c.link, c.form)
	print m.link
	#print CheckLinks().check("http://hotfile.com/dl/10804393/9f439e8/Bruno_-_www.crostuff.net.part1.rar.html")
