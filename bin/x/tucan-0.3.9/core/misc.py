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
import urllib
import logging
logger = logging.getLogger(__name__)

import url_open
import cons

REPORT_URL = "http://crak.appspot.com/add"

def main_info(log=logger):
	""""""
	log.info("%s %s" % (cons.TUCAN_NAME, cons.TUCAN_VERSION))
	log.debug("OS: %s" % sys.platform)
	log.debug("Main path: %s" % cons.PATH)
	log.debug("Configuration path: %s" % cons.CONFIG_PATH)
	
def report_log(email="", comment=""):
	""""""
	try:
		f = open(cons.LOG_FILE, "r")
		log = f.read()
		f.close()
	except Exception, e:
		logger.exception("%s" % e)
	else:
		form = urllib.urlencode([("uuid", configuration.get_uuid()), ("email", email), ("comment", urllib.quote(comment)), ("log", urllib.quote(log))])
		try:
			id = url_open.URLOpen().open(REPORT_URL, form).read().strip()
			logger.info("REPORT ID: %s" % id)
		except Exception, e:
			logger.exception("Could not report: %s" % e)
		else:
			return id
