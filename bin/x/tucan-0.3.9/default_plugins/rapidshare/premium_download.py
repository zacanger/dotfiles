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

from premium_cookie import PremiumCookie
from check_links import CheckLinks

from core.service_config import SECTION_PREMIUM_DOWNLOAD
from core.download_plugin import DownloadPlugin
from core.accounts import Accounts
from core.url_open import URLOpen

import core.cons as cons

class FormParser(HTMLParser):
	""""""
	def __init__(self, url, cookie):
		""""""
		HTMLParser.__init__(self)
		self.form_action = None
		self.url = None
		self.close()
		try:
			opener = URLOpen(cookie)
			handler = opener.open(url)
			if "text/html" in handler.info()["Content-Type"]:
				self.feed(handler.read())
				if self.form_action:
					for line in opener.open(self.form_action, urllib.urlencode({"dl.start": "PREMIUM", "":"Premium user"})).readlines():
						self.feed(line)
			else:
				self.url = url
		except Exception, e:
			print e
			logger.error("%s: %s" % (url, e))

	def handle_starttag(self, tag, attrs):
		""""""
		if tag == "form":
			if len(attrs) == 2:
				self.form_action = attrs[0][1]
			elif attrs[0][1] == "dlf":
				self.url = attrs[1][1]

class PremiumDownload(DownloadPlugin, Accounts):
	""""""
	def __init__(self, config):
		""""""
		Accounts.__init__(self, config, SECTION_PREMIUM_DOWNLOAD, PremiumCookie())
		DownloadPlugin.__init__(self)

	def check_links(self, url):
		""""""
		return CheckLinks().check(url)

	def add(self, path, link, file_name):
		""""""
		cookie = self.get_cookie()
		if cookie:
			f = FormParser(link, cookie)
			if f.url:
				return self.start(path, f.url, file_name, None, cookie)

	def delete(self, file_name):
		""""""
		logger.warning("Stopped %s: %s" % (file_name, self.stop(file_name)))

if __name__ == "__main__":
	c = PremiumCookie()
	p = FormParser("", c.get_cookie("",""))
