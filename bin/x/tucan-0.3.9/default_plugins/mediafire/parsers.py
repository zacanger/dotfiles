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

from core.tesseract import Tesseract
from core.url_open import URLOpen

class FormParser:
	""""""
	def __init__(self, url, cookie):
		""""""
		self.url = None
		server = None
		random = ""
		link = None
		name = None
		error = False
		try:
			opener = URLOpen(cookie)
			if "/file/" in url:
				tmp = url.split("file/")
				url = "%s?%s" % (tmp[0], tmp[1].split("/")[0])
			for line in opener.open(url).readlines():
				if "cu(" in line:
					tmp = eval(line.split("cu(")[1].split(");")[0])
					handle = opener.open("http://www.mediafire.com/dynamic/download.php?%s" % (urllib.urlencode([("qk", tmp[0]), ("pk", tmp[1]), ("r", tmp[2])])))
					tmp = handle.readlines()
					vars = {}
					
					tmp1 = tmp[2].split("function dz()")[0].split(";", 4)
					sum = tmp[2].split("+mL+'/' ")[1].split(" 'g/'+mH+'/'+mY+'")[0]
					
					server = tmp1[1].split("'")[1]
					link = tmp1[2].split("'")[1]
					name = tmp1[3].split("'")[1]

					for var in tmp1.pop().strip().split(";"):
						var = var.split("var")
						if len(var) > 1:
							var = var[1].strip().split("=")
							if ((len(var) > 1) and ("'" in var[1])):
								vars[var[0]] = var[1].split("'")[1]
					for var in sum.split("+"):
						if len(var) > 0:
							if var in vars.keys():
								random += vars[var]
							else:
								error = True
		except Exception, e:
			error = True
			logger.exception("%s: %s" % (url, e))
		if server and random and link and name and not error:
			self.url = "http://%s/%sg/%s/%s" % (server, random, link, name)

class CheckLinks:
	""""""
	def check(self, url):
		""""""
		name = None
		size = 0
		unit = None
		try:
			if "/file/" in url:
				tmp = url.split("file/")
				url = "%s?%s" % (tmp[0], tmp[1].split("/")[0])
			for line in URLOpen().open(url).readlines():
				if "You requested:" in line:
					tmp = line.split("You requested:")[1].split("</div>")[0].strip().split(" ")
					unit = tmp.pop().split(")")[0]
					size = int(float(tmp.pop().split("(")[1]))
					name = "_".join(tmp)
				if not name:
					name = url
					size = -1
		except Exception, e:
			name = url
			size = -1
			logger.exception("%s: %s" % (url, e))
		return name, size, unit

if __name__ == "__main__":
	f = FormParser("http://www.mediafire.com/download.php?0zhaznzw3oz", cookielib.CookieJar())
	print f.url
	#print CheckLinks().check("http://www.mediafire.com/file/jdzq4mn44ay/tHe.uNvTd.XvId.part7.rar")
