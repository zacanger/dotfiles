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

from core.url_open import URLOpen
import core.cons as cons

class CheckLinks(HTMLParser):
	""""""
	def __init__(self):
		""""""
		HTMLParser.__init__(self)
		self.active = False
		self.unable = False

	def handle_starttag(self, tag, attrs):
		""""""
		if tag == "div":
			if ((len(attrs) > 0) and (attrs[0][1] == "dldcontent")):
				self.active = True
			elif ((len(attrs) > 0) and (attrs[0][1] == "downloadError")):
				if len(attrs) > 1:
					self.unable = True

	def close(self):
		HTMLParser.close(self)
		self.active = False

	def check(self, url):
		""""""
		name = None
		size = 0
		unit = None
		for line in URLOpen().open(url).readlines():
			if not self.active:
				self.feed(line)
			else:
				if "<p><strong>Name</strong>" in line:
					name = line.split("<b>")[1].split("</b>")[0].strip()
				elif "<p>Size:" in line:
					tmp = line.split("<span>")[1].split("</span>")[0].strip()
					if cons.UNIT_KB in tmp:
						unit = cons.UNIT_KB
						size = int(float(tmp.split(cons.UNIT_KB)[0]))
					elif cons.UNIT_MB in tmp:
						unit = cons.UNIT_MB
						size = int(float(tmp.split(cons.UNIT_MB)[0]))
					elif cons.UNIT_GB in tmp:
						unit = cons.UNIT_GB
						size = int(float(tmp.split(cons.UNIT_GB)[0]))
				if "get.php?d=" not in url:
					name = url.split("/").pop()
		if self.unable:
			name = url
			size = -1
		self.close()
		return name, size, unit
