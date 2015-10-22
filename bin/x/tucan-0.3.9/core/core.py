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

import sys
import __builtin__
import logging
logger = logging.getLogger(__name__)

from events import Events
from service_manager import ServiceManager
from download_manager import DownloadManager

import misc
import cons

class Core(ServiceManager):
	""""""
	def __init__(self, configuration):
		""""""
		misc.main_info(logger)

		if not configuration.configured:
			logger.warning("No configuration found!")
			
		#events system
		__builtin__.events = Events()

		ServiceManager.__init__(self, configuration)
		self.download_manager = DownloadManager(self.get_download_plugin, self.services)

	def stop_all(self):
		""""""
		for service in self.services:
			for plugin in [service.anonymous_download_plugin, service.user_download_plugin, 
					service.premium_download_plugin, service.anonymous_upload_plugins, 
					service.user_upload_plugins, service.premium_upload_plugins]:
				if plugin:
					plugin.stop_all()
			self.download_manager.quit()
