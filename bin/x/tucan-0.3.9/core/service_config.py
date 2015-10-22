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
import pickle
import base64
import logging
logger = logging.getLogger(__name__)

from ConfigParser import SafeConfigParser

import cons

SECTION_MAIN = "main"

SECTION_ANONYMOUS_DOWNLOAD = "anonymous_download"
SECTION_USER_DOWNLOAD = "user_download"
SECTION_PREMIUM_DOWNLOAD = "premium_download"

SECTION_ANONYMOUS_UPLOAD = "anonymous_upload"
SECTION_USER_UPLOAD = "user_upload"
SECTION_PREMIUM_UPLOAD = "premium_upload"

OPTION_UPDATE = "update"
OPTION_NAME = "name"
OPTION_ICON = "icon"
OPTION_ENABLED = "enabled"

OPTION_PREMIUM_COOKIE = "premium_cookie"
OPTION_USER_COOKIE = "user_cookie"

OPTION_DOWNLOADS = "downloads"
OPTION_UPLOADS = "uploads"

OPTION_PATH = "path"
OPTION_AUTHOR = "author"
OPTION_VERSION = "version"
OPTION_SLOTS = "slots"
OPTION_CAPTCHA = "captcha"
OPTION_ACCOUNTS = "accounts"

CONF = "service.conf"

class ServiceConfig(SafeConfigParser):
	""""""
	def __init__(self, path, fd=None):
		""""""
		SafeConfigParser.__init__(self)
		self.path = path
		if fd:
			self.readfp(fd)
		elif os.path.exists(os.path.join(self.path, CONF)):
			self.read(os.path.join(self.path, CONF))

	def check_config(self):
		""""""
		if self.has_section(SECTION_MAIN):
			return True

	def enable(self, enabled):
		""""""
		self.set(SECTION_MAIN, OPTION_ENABLED, str(enabled))
		self.save()

	def get_name(self):
		""""""
		if self.has_option(SECTION_MAIN, OPTION_NAME):
			return self.get(SECTION_MAIN, OPTION_NAME)

	def get_update(self):
		""""""
		if self.has_option(SECTION_MAIN, OPTION_UPDATE):
			return self.getint(SECTION_MAIN, OPTION_UPDATE)
		else:
			return 0

	def get_icon(self):
		""""""
		if self.has_option(SECTION_MAIN, OPTION_ICON):
			if self.get(SECTION_MAIN, OPTION_ICON) != "None":
				return self.path + self.get(SECTION_MAIN, OPTION_ICON)

	def premium_cookie(self):
		""""""
		get_cookie = None
		if self.has_option(SECTION_MAIN, OPTION_PREMIUM_COOKIE):
			get_cookie = self.get(SECTION_MAIN, OPTION_PREMIUM_COOKIE)
		return OPTION_PREMIUM_COOKIE, get_cookie

	def user_cookie(self):
		""""""
		get_cookie = None
		if self.has_option(SECTION_MAIN, OPTION_USER_COOKIE):
			get_cookie = self.get(SECTION_MAIN, OPTION_USER_COOKIE)
		return OPTION_USER_COOKIE, get_cookie

	def get_plugins(self, sections):
		""""""
		result = []
		for section, section_type in sections:
			if ((self.has_section(section)) and (len(self.items(section)) > 0)):
				result.append((section, self.get(section, OPTION_NAME), section_type))
		return result

	def get_download_plugins(self):
		""""""
		result = []
		if self.has_option(SECTION_MAIN, OPTION_DOWNLOADS):
			if self.getboolean(SECTION_MAIN, OPTION_DOWNLOADS):
				result = self.get_plugins([(SECTION_ANONYMOUS_DOWNLOAD, cons.TYPE_ANONYMOUS), (SECTION_USER_DOWNLOAD, cons.TYPE_USER), (SECTION_PREMIUM_DOWNLOAD, cons.TYPE_PREMIUM)])
		return result

	def get_upload_plugins(self):
		""""""
		result = []
		if self.has_option(SECTION_MAIN, OPTION_UPLOADS):
			if self.getboolean(SECTION_MAIN, OPTION_UPLOADS):
				result = self.get_plugins([(SECTION_ANONYMOUS_UPLOAD, cons.TYPE_ANONYMOUS), (SECTION_USER_UPLOAD, cons.TYPE_USER), (SECTION_PREMIUM_UPLOAD, cons.TYPE_PREMIUM)])
		return result

	def get_accounts(self, section):
		""""""
		result = {}
		if self.has_section(section):
			if os.path.exists(self.path + self.get(section, OPTION_ACCOUNTS)):
				try:
					f = open(self.path + self.get(section, OPTION_ACCOUNTS), "rb")
					result = pickle.loads(base64.b64decode((f.read())))
					f.close()
				except EOFError, e:
					logger.error("Unable to load account: %s" % e)
		return result

	def set_accounts(self, section, accounts):
		""""""
		if self.has_section(section):
			f = open(self.path + self.get(section, OPTION_ACCOUNTS), "wb")
			f.write(base64.b64encode(pickle.dumps(accounts)))
			f.close()

	def save(self):
		""""""
		f = open(self.path + CONF, "w")
		self.write(f)
		f.close()

if __name__ == "__main__":
	c = ServiceConfig("/home/crak/.tucan/plugins/megaupload/")
