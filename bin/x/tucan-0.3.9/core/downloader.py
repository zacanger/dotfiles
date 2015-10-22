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
import urllib2
import threading
import time
import logging
logger = logging.getLogger(__name__)

from url_open import URLOpen

import cons

BASE_SIZE = 4
BUFFER_SIZE = BASE_SIZE * 1024

class Downloader(threading.Thread):
	""""""
	def __init__(self, path, url, file_name, wait, cookie, post_wait):
		""""""
		threading.Thread.__init__(self)

		self.max_speed = 0

		self.post_wait = post_wait
		self.status = cons.STATUS_WAIT
		self.path = path
		self.url = url
		self.file = file_name
		self.wait = wait
		self.stop_flag = False
		self.start_time = time.time()
		self.time_remaining = 0
		self.total_size = 1
		self.actual_size = 0
		self.speed = 0
		self.tmp_time = 0
		self.tmp_size = 0
		#build opener
		self.opener = URLOpen(cookie)

	def run(self):
		""""""
		name = os.path.join(self.path, self.file)
		if self.wait:
			while ((self.wait > 0) and not self.stop_flag):
				time.sleep(1)
				self.wait -= 1
				self.time_remaining = self.wait
		if not self.stop_flag:
			try:
				if self.post_wait:
					handle = self.post_wait(self.url)
				else:
					handle = self.opener.open(self.url)
				if handle:
					self.status = cons.STATUS_ACTIVE
					logger.debug("%s :%s" % (self.file, handle.info().getheader("Content-Type")))
					self.total_size = int(handle.info().getheader("Content-Length"))
					if not os.path.exists(self.path):
						os.makedirs(self.path)
					f = open("%s.part" % name, "wb")
					self.start_time = time.time()
					data = "None"
					while ((len(data) > 0) and not self.stop_flag):
						tmp_size = 0
						if self.max_speed > 0:
							max_size = self.max_speed/BASE_SIZE
						else:
							max_size = 0
						start_seconds = time.time()
						while (time.time() - start_seconds) < 1:
							if max_size == 0 or tmp_size < max_size:
								data = handle.read(BUFFER_SIZE)
								f.write(data)
								self.actual_size += len(data)
								tmp_size += 1
							else:
								time.sleep(0.1)
						self.speed = BASE_SIZE * tmp_size
					self.time_remaining = time.time() - self.start_time
					f.flush()
					os.fsync(f.fileno())
					f.close()
					if self.stop_flag:
						os.remove("%s.part" % name)
						self.status = cons.STATUS_PEND
					else:
						self.stop_flag = True
						if self.actual_size == self.total_size:
							os.rename("%s.part" % name, name)
							self.status = cons.STATUS_CORRECT
						else:
							self.status = cons.STATUS_ERROR
				else:
					self.stop_flag = True
					self.status = cons.STATUS_PEND					
			except Exception, e:
				self.stop_flag = True
				logger.exception("%s: %s" % (self.file, e))
				if os.path.exists("%s.part" % name):
					os.remove("%s.part" % name)
				self.status = cons.STATUS_ERROR

	def get_speed(self):
		"""return int speed KB/s"""
		elapsed_time = time.time() - self.tmp_time
		size = self.actual_size - self.tmp_size
		if size > 0:
			self.speed = int(float(size/1024)/float(elapsed_time))
			self.tmp_time = time.time()
			self.tmp_size = self.actual_size
		return self.speed
