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

import logging
logger = logging.getLogger(__name__)

from parsers import CheckLinks, WaitParser, CaptchaParser

from core.download_plugin import DownloadPlugin
from core.slots import Slots

class AnonymousDownload(DownloadPlugin, Slots):
	""""""
	def __init__(self):
		""""""
		Slots.__init__(self, 1, 300)
		DownloadPlugin.__init__(self)

	def check_links(self, url):
		""""""
		return CheckLinks().check(url)

	def add(self, path, link, file_name):
		""""""
		if self.get_slot():
			parser = WaitParser(link)
			if parser.wait:
				if self.start(path, link, file_name, parser.wait, None, self.post_wait):
					return True
			else:
				logger.warning("Limit Exceded.")
				self.add_wait()
				self.return_slot()

				
	def post_wait(self, link):
		"""Must return handle"""
		parser = CaptchaParser(link)
		if parser.captcha_url:
			return parser.handle

	def delete(self, file_name):
		""""""
		if self.stop(file_name):
			logger.warning("Stopped %s: %s" % (file_name, self.return_slot()))
