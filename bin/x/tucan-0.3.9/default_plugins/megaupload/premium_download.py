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
import logging
logger = logging.getLogger(__name__)

from premium_cookie import PremiumCookie
from premium_parser import PremiumParser
from check_links import CheckLinks

from core.accounts import Accounts
from core.service_config import SECTION_PREMIUM_DOWNLOAD, ServiceConfig
from core.download_plugin import DownloadPlugin

class PremiumDownload(DownloadPlugin, Accounts):
	""""""
	def __init__(self, config):
		""""""
		Accounts.__init__(self, config, SECTION_PREMIUM_DOWNLOAD, PremiumCookie())
		DownloadPlugin.__init__(self)

	def add(self, path, link, file_name):
		""""""
		cookie = self.get_cookie()
		if cookie:
			parser = PremiumParser(link, cookie)
			link = parser.get_url()
			if link:
				return self.start(path, link, file_name, None, cookie)

	def delete(self, file_name):
		""""""
		logger.warning("Stopped %s: %s" % (file_name, self.stop(file_name)))

	def check_links(self, url):
		""""""
		return CheckLinks().check(url)

if __name__ == "__main__":
	p = PremiumDownload(ServiceConfig("/home/crak/.tucan/plugins/megaupload/"))
	p.check_links("http://www.megaupload.com/es/?d=RDAJ2PYH")
