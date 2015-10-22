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

from check_links import CheckLinks

from core.download_plugin import DownloadPlugin
from core.url_open import URLOpen
from core.slots import Slots

class FormParser(HTMLParser):
	""""""
	def __init__(self, url):
		""""""
		HTMLParser.__init__(self)
		self.form_action = None
		self.url = None
		self.wait = None
		try:
			self.feed(URLOpen().open(url).read())
			self.close()
			form = {"dl.start": "Free", "":"Free user"}
			self.data = urllib.urlencode(form)
			if self.form_action:
				for line in URLOpen().open(self.form_action, self.data).readlines():
					if not self.url:
						self.feed(line)
					else:
						if "var c=" in line:
							self.wait = int(line.split("var c=")[1].split(";")[0])
		except Exception, e:
			logger.exception("%s: %s" % (url, e))

	def handle_starttag(self, tag, attrs):
		""""""
		if tag == "form":
			if attrs[0][1] == "ff":
				self.form_action = attrs[1][1]
			elif attrs[0][1] == "dlf":
				self.url = attrs[1][1]

class AnonymousDownload(DownloadPlugin, Slots):
	""""""
	def __init__(self):
		""""""
		Slots.__init__(self, 1)
		DownloadPlugin.__init__(self)

	def check_links(self, url):
		""""""
		return CheckLinks().check(url)

	def add(self, path, link, file_name):
		""""""
		if self.get_slot():
			parser = FormParser(link)
			if parser.url:
				return self.start(path, parser.url, file_name, parser.wait)
			else:
				self.add_wait()
				self.return_slot()
				logger.warning("Limit Exceded.")

	def delete(self, file_name):
		""""""
		if self.stop(file_name):
			logger.warning("Stopped %s: %s" % (file_name, self.return_slot()))
