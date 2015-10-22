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

import os
import sys
import subprocess
import tempfile

import ImageFile
import Image
import TiffImagePlugin

import cons

IMAGE_SUFFIX = ".tif"
TEXT_SUFFIX = ".txt"

class Tesseract:
	""""""
	def __init__(self, data, filter=None):
		""""""
		if cons.OS_WINDOWS:
			self.image_name = os.path.join(sys.path[0], "tmp.tif")
			self.text_name = os.path.join(sys.path[0], "tmp")
			self.tesseract = os.path.join(sys.path[0], "tesseract", "tesseract.exe")
		else:
			if cons.OS_OSX:
				os.environ["TESSDATA_PREFIX"] = os.path.join(sys.path[0], "tesseract", "")
				self.tesseract = os.path.join(sys.path[0], "tesseract", "tesseract")
			else:
				self.tesseract = "tesseract"
			self.text = tempfile.NamedTemporaryFile(suffix=TEXT_SUFFIX)
			self.image = tempfile.NamedTemporaryFile(suffix=IMAGE_SUFFIX)
			self.image_name = self.image.name
			self.text_name = self.text.name.rsplit(TEXT_SUFFIX, 1)[0]
		p = ImageFile.Parser()
		p.feed(data)
		if filter:
			image = filter(p.close())
		else:
			image = p.close()
		image.save(self.image_name)

	def get_captcha(self):
		""""""
		captcha = ""
		try:
			if cons.OS_WINDOWS:
				if subprocess.call([self.tesseract, self.image_name, self.text_name], stdout=subprocess.PIPE, stderr=subprocess.PIPE, creationflags=134217728) == 0:
					f = file(self.text_name + TEXT_SUFFIX, "r")
					captcha = f.readline().strip()
					f.close()
			else:
				if subprocess.call([self.tesseract, self.image_name, self.text_name], stdout=subprocess.PIPE, stderr=subprocess.PIPE) == 0:
					captcha = self.text.file.readline().strip()
				self.text.file.close()
				self.image.file.close()
		except Exception, e:
			logger.critical("No tesseract available: %s" % e)
			return ""
		else:
			return captcha

if __name__ == "__main__":
	f = file("tmp.tif", "r")
	t = Tesseract(f.read())
	print t.get_captcha()
