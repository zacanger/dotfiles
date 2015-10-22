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

from core.url_open import URLOpen

class Parser:
	""""""
	def __init__(self, url):
		""""""
		self.link = None
		try:
			if "/video/" in url:
				url = url.replace("/video/", "/download/")
			elif "/audio/" in url:
				url = url.replace("/audio/", "/download/")
			elif "/image/" in url:
				url = url.replace("/image/", "/download/")
			opener = URLOpen()
			form = urllib.urlencode([("referer2", ""), ("download", 1), ("imageField.x", 81), ("imageField.y", 29)])
			for line in opener.open(url, form).readlines():
				if "var link_enc=new Array(" in line:
					tmp = line.strip().split("var link_enc=new Array(")[1].split(");")[0]
					tmp = eval("[%s]" % tmp)
					self.link = "".join(tmp)
		except Exception, e:
			logger.exception("%s :%s" % (url, e))

class CheckLinks:
	""""""
	def check(self, url):
		""""""
		name = None
		size = 0
		unit = None
		name_found = False
		try:
			for line in URLOpen().open(url).readlines():
				if "File Name:" in line:
					name_found = True
				elif name_found:
					name_found = False
					name = line.strip().split('<font color="#666666"  align="left">')[1].split('</font></td>')[0]
				elif "Size:" in line:
					tmp = line.strip().split('<font color="#666666">')[1].split('</font></td>')[0]
					if "KB" in tmp:
						size = int(float(tmp.split("KB")[0]))
						unit = "KB"
					elif "MB" in tmp:
						size = int(float(tmp.split("MB")[0]))
						unit = "MB"
					elif "GB" in tmp:
						size = int(float(tmp.split("GB")[0]))
						unit = "GB"
			if not name:
				name = url
				size = -1
		except Exception, e:
			name = url
			size = -1
			logger.exception("%s :%s" % (url, e))
		return name, size, unit

if __name__ == "__main__":
	#c = Parser("http://www.zshare.net/download/58856573188bda3b/")
	print CheckLinks().check("http://www.zshare.net/download/58856573188bda3b/")
