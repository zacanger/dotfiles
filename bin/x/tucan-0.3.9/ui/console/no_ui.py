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

import os
import sys
import time
import __builtin__
import gettext
import logging
logger = logging.getLogger(__name__)

from core.core import Core

import core.config as config
import core.cons as cons

class NoUi(Core):
	""""""
	def __init__(self, conf, links_file):
		""""""
		self.configuration = conf
		self.links_file = links_file
		Core.__init__(self, self.configuration)

	def run(self):
		""""""
		self.load_file()
		while len(self.download_manager.active_downloads + self.download_manager.pending_downloads) > 0:
			self.download_manager.update()
			time.sleep(1)
		self.quit()

	def load_file(self):
		""""""
		if self.links_file:
			try:
				f = open(self.links_file, "r")
				links =	[link.lower().strip() for link in f.read().split("\n") if link and not link.startswith("#")]
				f.close()
				self.manage_packages(self.create_packages(self.check_links(links)), [])
			except Exception, e:
				logger.error(e)
				

	def check_links(self, link_list):
		""""""
		result = {}
		for service, links in self.filter_service(link_list).items():
			if service != cons.TYPE_UNSUPPORTED:
				tmp = []
				check, plugin_type = self.get_check_links(service)
				for link in links:
					file_name, size, size_unit = check(link)
					if file_name:
						if size > 0:
							tmp.append((link, file_name, size, size_unit, plugin_type))
					else:
						file_name = link
					logger.info("Checked: %s %s %s" % (file_name, size, size_unit))
				if len(tmp) > 0:
					result[service] = tmp
		return result

	def manage_packages(self, packages, packages_info):
		""""""
		if not len(packages_info) > 0:
			default_path = self.configuration.get_downloads_folder()
			packages_info = [(default_path, name, None) for name, package_files in packages]
		for package_name, package_downloads in packages:
			info = packages_info[packages.index((package_name, package_downloads))]
			package_name = info[1].replace(" ", "_")
			package_path = os.path.join(info[0], package_name, "")
			for download in package_downloads:
				tmp = []
				for service in download[2]:
					plugin, plugin_type = self.get_download_plugin(service)
					tmp.append((download[0][download[2].index(service)], plugin, plugin_type, service))
				self.download_manager.add(package_path, download[1], tmp, download[3], download[4])

	def quit(self):
		""""""
		self.stop_all()
		tucan_exit(0)
