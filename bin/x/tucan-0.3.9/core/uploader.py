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

"""
import MultipartPostHandler, urllib2, cookielib

cookies = cookielib.CookieJar()
opener = urllib2.build_opener(urllib2.HTTPCookieProcessor(cookies), MultipartPostHandler.MultipartPostHandler)
params = { "username" : "bob", "password" : "riviera", "file" : open("filename", "rb") }
opener.open("http://wwww.bobsite.com/upload/", params)
"""

import urllib
import urllib2

from HTMLParser import HTMLParser

class Uploader(HTMLParser):
	""""""
	def __init__(self, file_name):
		""""""
		HTMLParser.__init__(self)

if __name__ == "__main__":
	c = Uploader("/home/crak/mierda.html")
