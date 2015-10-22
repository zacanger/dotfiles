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
import threading

import logging
logger = logging.getLogger(__name__)

import cons

class Link:
	""""""
	def __init__(self, url, plugin, type, service):
		""""""
		self.active = False
		self.url = url
		self.plugin = plugin
		self.plugin_type = type
		self.service = service

class DownloadItem:
	""""""
	def __init__(self, path, name, links, total_size, size_unit):
		""""""
		self.path = path
		self.name = name
		self.status = cons.STATUS_PEND
		self.links = []
		for url, plugin, type, service in links:
			self.links.append(Link(url, plugin, type, service))
		self.progress = 0
		self.total_size = total_size
		self.total_size_unit = size_unit
		self.actual_size = 0
		self.actual_size_unit = cons.UNIT_KB
		self.speed = 0
		self.prev_speed = 0
		self.time = 0

	def update(self, status=cons.STATUS_STOP, progress=0, actual_size=0, size_unit=cons.UNIT_KB, speed=0, prev_speed=0, time=0):
		""""""
		self.status = status
		self.progress = progress
		self.actual_size = actual_size
		self.actual_size_unit = size_unit
		self.speed = speed
		self.prev_speed = prev_speed
		self.time = time

class DownloadManager:
	""""""
	def __init__(self, get_plugin, services):
		""""""
		self.services = services
		self.get_plugin = get_plugin
		self.limits = []
		self.pending_downloads = []
		self.active_downloads = []
		self.complete_downloads = []
		self.timer = None
		self.scheduling = False

	def delete_link(self, name, link):
		""""""
		for download in self.pending_downloads:
			if download.name == name:
				for url in download.links:
					if link == url.url:
						del download.links[download.links.index(url)]
						return True

	def get_files(self):
		""""""
		result = []
		for downloads in [self.pending_downloads, self.active_downloads, self.complete_downloads]:
			for download in downloads:
				result.append(download)
		self.update()
		return result

	def clear(self, files):
		""""""
		result = False
		complete = [tmp.name for tmp in self.complete_downloads]
		pending = [tmp.name for tmp in self.pending_downloads]
		for name in files:
			if name in complete:
				logger.info("Cleared %s" % name)
				del self.complete_downloads[complete.index(name)]
				del complete[complete.index(name)]
				result = True
			elif name in pending:
				logger.info("Deleted %s" % name)
				del self.pending_downloads[pending.index(name)]
				del pending[pending.index(name)]
				result = True
		return result

	def add(self, path, name, links, total_size, size_unit):
		""""""
		if name not in [tmp.name for tmp in (self.active_downloads + self.pending_downloads)]:
			self.pending_downloads.append(DownloadItem(path, name, links, total_size, size_unit))
			threading.Timer(1, self.scheduler).start()
			return True

	def start(self, name):
		""""""
		for download in self.pending_downloads:
			if name == download.name:
				download.status = cons.STATUS_WAIT
				for link in download.links:
					link.plugin, link.type = self.get_plugin(link.service)
					if link.plugin.add(download.path, link.url, download.name):
						try:
							self.pending_downloads.remove(download)
						except:
							pass
						else:
							self.active_downloads.append(download)
						link.active = True
						return True
					else:
						link.active = False
						if download.status != cons.STATUS_ERROR:
							download.status = cons.STATUS_PEND

	def stop(self, name):
		""""""
		for download in self.pending_downloads:
			if name == download.name:
				download.status = cons.STATUS_STOP
		for download in self.active_downloads:
			if name == download.name:
				for link in download.links:
					if link.active:
						if link.plugin.stop(download.name):
							if "return_slot" in dir(link.plugin):
								link.plugin.return_slot()
							link.active = False
							self.pending_downloads.append(download)
							self.active_downloads.remove(download)
							download.update()
							return True

	def update(self):
		""""""
		new_speed = 0
		permanent = True
		speeds = [download.speed for download in self.active_downloads if download.status == cons.STATUS_ACTIVE]
		current_active = len(speeds)
		#print max_downloads, max_download_speed
		#print current_active, speeds
		remain_speed = max_download_speed
		for speed in speeds:
			remain_speed -= speed
		#print remain_speed
		if current_active > 0:
			if remain_speed < 0:
				new_speed = max_download_speed/current_active
				permanent = False
		for download in self.active_downloads:
			plugin = None
			for link in download.links:
				if link.active:
					plugin = link.plugin
					break
			if plugin:
				if permanent:
					if download.speed == 0:
						if remain_speed <= 0:
							new_speed = 20
						else:
							new_speed = remain_speed
					elif download.prev_speed >= download.speed:
						new_speed = download.prev_speed
						if remain_speed - 2 > 0:
							new_speed += 2
							remain_speed -= 2
						else:
							new_speed += remain_speed
							remain_speed = 0
					else:
						new_speed = download.speed
				status, progress, actual_size, unit, speed, time = plugin.get_status(download.name, new_speed)
				#print download.name, status, progress, actual_size, unit, speed, new_speed, time
				if status:
					download.update(status, progress, actual_size, unit, speed, new_speed, time)
					if status in [cons.STATUS_PEND, cons.STATUS_ERROR]:
						if status == cons.STATUS_ERROR:
							logger.error("%s %s %s %s %s %s %s" % (download.name, status, progress, actual_size, unit, speed, time))
						if "return_slot" in dir(link.plugin):
							plugin.return_slot()
						link.active = False
						self.pending_downloads.append(download)
						self.active_downloads.remove(download)
						self.scheduler()
					elif status == cons.STATUS_CORRECT:
						logger.info("%s %s %s %s %s %s %s" % (download.name, status, progress, actual_size, unit, speed, time))
						if "return_slot" in dir(link.plugin):
							plugin.return_slot()
						download.progress = 100
						self.complete_downloads.append(download)
						self.active_downloads.remove(download)

	def scheduler(self):
		""""""
		if not self.scheduling:
			self.scheduling = True
			if len(self.pending_downloads + self.active_downloads) > 0:
				logger.debug("scheduling")
				try:
					for download in self.pending_downloads:
						if len(self.active_downloads) < max_downloads:
							if download.status not in [cons.STATUS_STOP]:
								if self.start(download.name):
									logger.info("Started: %s" % download.name)
									logger.debug("Active: %s" % [tmp.name for tmp in self.active_downloads])
									logger.debug("Pending: %s" % [tmp.name for tmp in self.pending_downloads])
									logger.debug("Complete: %s" % [tmp.name for tmp in self.complete_downloads])
									break
				except Exception, e:
					logger.exception(e)
				if self.timer:
					self.timer.cancel()
				self.timer = threading.Timer(5, self.scheduler)
				self.timer.start()
			else:
				events.trigger_all_complete()
			self.scheduling = False

	def quit(self):
		""""""
		if self.timer:
			self.scheduling = True
			self.timer.cancel()
