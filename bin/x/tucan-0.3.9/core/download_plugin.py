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

import time

from downloader import Downloader

import cons

class DownloadPlugin(object):
	""""""
	def __init__(self):
		""""""
		self.active_downloads = {}

	def start(self, path, url, file_name, wait=None, cookie=None, post_wait=None):
		""""""
		if file_name not in self.active_downloads:
			th = Downloader(path, url, file_name, wait, cookie, post_wait)
			th.start()
			self.active_downloads[file_name] = th
			return True

	def stop(self, file_name):
		""""""
		if file_name in self.active_downloads:
			while self.active_downloads[file_name].isAlive():
				self.active_downloads[file_name].stop_flag = True
				time.sleep(0.1)
			del self.active_downloads[file_name]
			return True

	def stop_all(self):
		""""""
		for th in self.active_downloads.values():
			while th.isAlive():
				th.stop_flag = True

	def get_status(self, file_name, speed=0):
		"""return (status, progress, actual_size, unit, speed, time)"""
		result = cons.STATUS_ERROR, 0, 0, None, 0, 0
		th = None
		if file_name in self.active_downloads:
			th = self.active_downloads[file_name]
			if self.active_downloads[file_name].stop_flag:
				del self.active_downloads[file_name]
		if th:
			actual_size, unit = self.get_size(th.actual_size)
			if th.status == cons.STATUS_ACTIVE:
				progress = int((float(th.actual_size)/float(th.total_size))*100)
				th.max_speed = speed
				speed = th.speed
				if speed > 0:
					time = int(float((th.total_size - th.actual_size)/1024)/float(speed))
				else:
					time = 0
			else:
				if not th.status == cons.STATUS_CORRECT:
					actual_size = 0
				progress = 0
				speed = 0
				time = int(th.time_remaining)
			result = th.status, progress, actual_size, unit, speed, time
		return result

	def get_size(self, num):
		""""""
		result = 0, cons.UNIT_KB
		tmp = int(num/1024)
		if  tmp > 0:
			result = tmp, cons.UNIT_KB
			tmp = int(tmp/1024)
			if tmp > 0:
				result = tmp, cons.UNIT_MB
		return result
