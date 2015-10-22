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

import uuid
import os
import shutil

from ConfigParser import SafeConfigParser

import service_config
import cons

CONF = "tucan.conf"

COMMENT = """# Tucan Manager's default configuration.
# Dont change anything unless you really know what are doing, 
# instead use the preferences dialog of the GUI."""

SECTION_MAIN = "main"
SECTION_SERVICES = "services"
SECTION_ADVANCED = "advanced"

OPTION_VERSION = "version"
OPTION_UUID = "uuid"

OPTION_LANGUAGE = "language"
OPTION_MAX_DOWNLOADS = "max_downloads"
OPTION_MAX_DOWNLOAD_SPEED = "max_download_speed"
OPTION_MAX_UPLOADS = "max_uploads"
OPTION_DOWNLOADS_FOLDER = "downloads_folder"

OPTION_TRAY_CLOSE = "tray_close"
OPTION_ADVANCED_PACKAGES = "advanced_packages"
OPTION_SAVE_SESSION = "save_session"
OPTION_AUTO_UPDATE = "auto_update"
OPTION_SHOW_UPLOADS = "show_uploads"
OPTION_ENABLE_PROXY = "enable_proxy"
OPTION_PROXY_URL = "proxy_url"
OPTION_PROXY_PORT = "proxy_port"

DEFAULTS = {SECTION_MAIN: {OPTION_VERSION: cons.TUCAN_VERSION, OPTION_LANGUAGE: "en", OPTION_MAX_DOWNLOADS: "5", OPTION_MAX_DOWNLOAD_SPEED: "0", OPTION_MAX_UPLOADS: "5", OPTION_DOWNLOADS_FOLDER: cons.DEFAULT_PATH.encode("utf-8")}
	, SECTION_SERVICES: {}
	, SECTION_ADVANCED: {OPTION_TRAY_CLOSE: "False", OPTION_SAVE_SESSION: "True", OPTION_ADVANCED_PACKAGES: "False", OPTION_AUTO_UPDATE: "True",OPTION_SHOW_UPLOADS: "False", OPTION_ENABLE_PROXY: "False", OPTION_PROXY_URL: "", OPTION_PROXY_PORT: "0"}}

class Config(SafeConfigParser):
	""""""
	def __init__(self):
		""""""
		SafeConfigParser.__init__(self)
		self.configured = True
		if not os.path.exists(cons.CONFIG_PATH):
			os.mkdir(cons.CONFIG_PATH)
		if not os.path.exists(cons.CONFIG_PATH + CONF):
			self.create_config()
			self.configured = False
		else:
			self.read(cons.CONFIG_PATH + CONF)
			if not self.check_config():
				self.create_config()
				self.configured = False
		if not os.path.exists(cons.PLUGIN_PATH):
			shutil.copytree(cons.DEFAULT_PLUGINS, cons.PLUGIN_PATH)
			for service in os.listdir(cons.PLUGIN_PATH):
				if os.path.isdir(os.path.join(cons.PLUGIN_PATH, service)):
					path = os.path.join(cons.PLUGIN_PATH, service, "")
					package, icon, name, enabled, config = self.service(path)
					if name:
						self.set(SECTION_SERVICES, name, path.encode("utf-8"))
			self.save()

	def check_config(self):
		""""""
		for section, options in DEFAULTS.items():
			if self.has_section(section):
				if section == SECTION_MAIN:
					if self.has_option(section, OPTION_VERSION):
						if self.get(section, OPTION_VERSION) != cons.TUCAN_VERSION:
							shutil.rmtree(cons.PLUGIN_PATH)
							return False
					else:
						shutil.rmtree(cons.PLUGIN_PATH)
						return False
				for option, value in options.items():
					if option not in [option for option, value in self.items(section)]:
						return False
			else:
				return False
		return True

	def create_config(self):
		""""""
		for section, options in DEFAULTS.items():
			if not self.has_section(section):
				self.add_section(section)
			for option, value in options.items():
				self.set(section, option, value)
		#set uuid
		self.set(SECTION_MAIN, OPTION_UUID, str(uuid.uuid1()))
		self.save()
		
	def get_uuid(self):
		""""""
		if self.has_option(SECTION_MAIN, OPTION_UUID):
			return self.get(SECTION_MAIN, OPTION_UUID)
		else:
			new_uuid = str(uuid.uuid1())
			self.set(SECTION_MAIN, OPTION_UUID, new_uuid)
			self.save()
			return new_uuid
			
	def get_downloads_folder(self):
		""""""
		if self.has_option(SECTION_MAIN, OPTION_DOWNLOADS_FOLDER):
			return self.get(SECTION_MAIN, OPTION_DOWNLOADS_FOLDER).decode("utf-8")
		else:
			return cons.DEFAULT_PATH
			
	def set_downloads_folder(self, path):
		""""""
		self.set(SECTION_MAIN, OPTION_DOWNLOADS_FOLDER, path.encode("utf-8"))
			
	def get_services(self):
		""""""
		result = []
		for service, path in self.items(SECTION_SERVICES):
			result.append(self.service(path.decode("utf-8")))
		return sorted(result)

	def service(self, path):
		""""""
		result = path, None, None, None, None
		config = service_config.ServiceConfig(path)
		if config.check_config():
			icon = config.get_icon()
			name = config.get(service_config.SECTION_MAIN, service_config.OPTION_NAME)
			enabled = config.getboolean(service_config.SECTION_MAIN, service_config.OPTION_ENABLED)
			result = os.path.split(os.path.split(path)[0])[1], icon, name, enabled, config
		return result

	def get_proxy(self):
		""""""
		result = None, None
		if self.has_section(SECTION_ADVANCED):
			if self.getboolean(SECTION_ADVANCED, OPTION_ENABLE_PROXY):
				result = self.get(SECTION_ADVANCED, OPTION_PROXY_URL), self.getint(SECTION_ADVANCED, OPTION_PROXY_PORT)
		return result

	def save(self, comment=True):
		""""""
		f = open(cons.CONFIG_PATH + CONF, "w")
		if comment:
			f.write(COMMENT + "\n\n")
		self.write(f)
		f.close()

if __name__ == "__main__":
	c = Config()
	print c.configured
