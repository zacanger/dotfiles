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
import os
import locale
import logging

#project constants
TUCAN_NAME = "Tucan Manager"
TUCAN_VERSION = "0.3.9 alpha"
WEBPAGE = "http://www.tucaneando.com"
DOC = "http://doc.tucaneando.com"

#OS constants
OS_UNIX = False
OS_WINDOWS = False
OS_OSX = False
if sys.platform.startswith("win"):
	OS_WINDOWS = True
elif "darwin" in sys.platform:
	OS_OSX = True
else:
	OS_UNIX = True

#user agent
USER_AGENT = {"User-Agent":"Mozilla/5.0 (X11; U; Linux i686) Gecko/20081114 Firefox/3.0.4"}

#status constants
STATUS_PEND = "pending"
STATUS_ACTIVE = "active"
STATUS_WAIT = "waiting"
STATUS_STOP = "stoped"
STATUS_CORRECT = "correct"
STATUS_ERROR = "error"

#message constants
SEVERITY_INFO = "info"
SEVERITY_WARNING = "warning"
SEVERITY_ERROR = "error"

#size unit constants
UNIT_KB = "KB"
UNIT_MB = "MB"
UNIT_GB = "GB"

#speed unit constant
UNIT_SPEED = "KB/s"

#time constants
MINUTE = 60
HOUR = 3600

#service type constans
TYPE_ANONYMOUS = "Anonymous"
TYPE_USER = "User"
TYPE_PREMIUM = "Premium"
TYPE_UNSUPPORTED = "unsupported"

#path constants
if OS_WINDOWS:
	PATH = os.path.abspath(os.path.dirname(sys.argv[0]))
	DEFAULT_PATH = os.path.join(os.path.expanduser("~"), "").decode(locale.getdefaultlocale()[1])
	if PATH not in sys.path:
		sys.path.insert(0, PATH)
else:
	if OS_OSX:
		PATH = os.path.abspath(os.path.dirname(sys.argv[0]))
	else:
		PATH = os.path.join(sys.path[0], "")
	DEFAULT_PATH = os.path.join(os.path.expanduser("~"), "")
CONFIG_PATH = os.path.join(DEFAULT_PATH, ".tucan" ,"")

#log constants
LOG_FILE = os.path.join(CONFIG_PATH, "tucan.log")
LOG_FORMAT = "[%(asctime)s] %(name)s %(levelname)s: %(message)s"

#plugin constants
PLUGIN_PATH = os.path.join(CONFIG_PATH, "plugins")
DEFAULT_PLUGINS = os.path.join(PATH, "default_plugins", "")

#session constants
SESSION_FILE = os.path.join(CONFIG_PATH, "last.session")

#localization constants
NAME_LOCALES = "tucan"
PATH_LOCALES = os.path.join(PATH, "i18n")

#events constants
EVENT_ALL_COMPLETE = "all-complete"
EVENT_LIMIT_ON = "limit-exceeded-on"
EVENT_LIMIT_OFF = "limit-exceeded-off"
EVENT_LIMIT_CANCEL = "limit-exceeded-cancel"
