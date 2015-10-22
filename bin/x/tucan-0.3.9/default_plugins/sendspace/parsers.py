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

import HTMLParser

from core.url_open import URLOpen

B64S = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_"';

class Parser(HTMLParser.HTMLParser):
	""""""
	def __init__(self, url):
		""""""
		HTMLParser.HTMLParser.__init__(self)
		self.link = None
		code = ""
		vars = ""
		var1 = ""
		var2 = ""
		try:
			for line in URLOpen().open(url).readlines():
				if "base64ToText" in line:
					code = line.split("base64ToText('")[1].split("')));")[0]
				elif "enc(text)" in line:
					vars = line.split(";")
					var1 = int(vars[1].split("=")[1])
					var2 = vars[5].split("=")[1].split("'")[1]
			self.feed(self.decode(code, var1, var2))
		except Exception, e:
			logger.exception("%s :%s" % (url, e))

	def handle_starttag(self, tag, attrs):
		""""""
		if tag == "a":
			for ref, value in attrs:
				if ref == "href":
					self.link = value

	def decode(self, code, num, text):
		""""""
		#base64ToText
		r = ""
		m = 0
		a = 0
		for n in range(len(code)):
			c = B64S.index(code[n])
			if c >= 0:
				if m:
					r += chr((c << (8 - m))&255 | a)
				a = c >> m
				m += 2
				if m == 8:
					m = 0
		code = r
		#enc
		array1 = range(num)
		array2 = array1
		num4 = 0
		for num3 in range(num):
			num4 = (ord(text[num3%len(text)]) + array2[num3] + num4)%num
			text2 = array2[num3]
			array2[num3] = array2[num4]
			array2[num4] = text2
			array2[num4] = array2[num4]^5
		num4 = 0
		tmp = ""
		for num6 in range(len(code)):
			num5 = num6%num
			num4 = (array2[num5] + num4)%num
			text3 = array2[num5]
			array2[num5] = array2[num4]
			array2[num4] = text3
			tmp += chr((ord(code[num6])^array2[(array2[num5] + array2[num4])%num]))			
		#utf8_decode
		result = ""
		i = 0
		while i < len(tmp):
			c = ord(tmp[i])
			if c < 128:
				result += chr(c)
				i += 1
			elif ((c > 191) and (c < 224)):
				c2 = ord(tmp[i+1])
				result += chr(((c & 31) << 6) | (c2 & 63))
				i += 2
			else:
				c2 = ord(tmp[i+1])
				c3 = ord(tmp[i+2])
				result += chr(((c & 15) << 12) | ((c2 & 63) << 6) | (c3 & 63))
				i += 3
		return result

class CheckLinks:
	""""""
	def check(self, url):
		""""""
		name = None
		size = 0
		unit = None
		size_found = False
		try:
			for line in URLOpen().open(url).readlines():
				if "<b>Name:</b>" in line:
					name = line.split("<b>Name:</b>")[1].split("<br><b>Size:</b>")[0].strip()
					tmpsize = []
					tmpunit = []
					for char in line.split("<br><b>Size:</b>")[1].split("<br>")[0].strip():
						try:
							int(char)
						except:
							tmpunit.append(char)
						else:
							tmpsize.append(char)
					size = int("".join(tmpsize))
					unit = "".join(tmpunit)
		except Exception, e:
			logger.exception("%s :%s" % (url, e))
		if not name:
			name = url
			size = -1
		return name, size, unit

if __name__ == "__main__":
	#c = Parser("http://www.sendspace.com/file/lpd6p3")
	print CheckLinks().check("http://www.sendspace.com/file/z57jja")
	print CheckLinks().check("http://www.sendspace.com/file/x1itz8")
