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
import urllib2
import cookielib
import logging
logger = logging.getLogger(__name__)

from parsers import CheckLinks, FormParser

from core.download_plugin import DownloadPlugin

class AnonymousDownload(DownloadPlugin):
	""""""
	def __init__(self):
		""""""
		DownloadPlugin.__init__(self)

	def check_links(self, url):
		""""""
		return CheckLinks().check(url)

	def add(self, path, link, file_name):
		""""""
		cookie = cookielib.CookieJar()
		f = FormParser(link, cookie)
		if f.url:
			if self.start(path, f.url, file_name, None, cookie):
				return True

	def delete(self, file_name):
		""""""
		if self.stop(file_name):
			logger.warning("Stopped %s" % file_name)
