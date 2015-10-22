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
import cookielib

from core.url_open import URLOpen

class PremiumCookie:
	""""""
	def get_cookie(self, user, password, url=None):
		""""""
		cookie = cookielib.CookieJar()
		opener = URLOpen(cookie)
		opener.open("http://www.megaupload.com/?c=login", urllib.urlencode({"login": "1", "redir": "1", "username": user, "password": password}))
		if len(cookie) > 0:
			return cookie

if __name__ == "__main__":
	c = PremiumCookie()
	print c.get_cookie("","")