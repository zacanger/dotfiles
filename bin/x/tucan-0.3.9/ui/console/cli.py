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

import threading
import time
import curses
import logging
logger = logging.getLogger(__name__)

from no_ui import NoUi
from core.log_stream import LogStream

import core.cons as cons

STATUS_LINES = 1
DOWNLOAD_LINES = 60
LOG_LINES = 50
WIDTH = 100

class Cli(NoUi):
	""""""		
	def __init__(self, *kwargs):
		""""""		
		#set logger
		self.stream = LogStream()
		handler = logging.StreamHandler(self.stream)
		handler.setLevel(logging.INFO)
		handler.setFormatter(logging.Formatter('%(levelname)-7s %(message)s'))
		logging.getLogger("").addHandler(handler)
				
		NoUi.__init__(self, *kwargs)
		self.quit_question = False
		self.win_height = 0
		self.win_chars = 0
		self.last_length = 0
		self.total_speed = 0

	def run(self, screen):
		""""""
		self.screen = screen
		self.screen.nodelay(1)
		try:
			curses.curs_set(0)
		except:
			logger.warning("Could not hide the cursor")

		#set default screen
		self.status_pad = curses.newpad(STATUS_LINES, WIDTH)
		self.main_pad = curses.newpad(DOWNLOAD_LINES, WIDTH)
		self.log_pad = curses.newpad(LOG_LINES, WIDTH)

		#load links file
		th = threading.Thread(group=None, target=self.load_file, name=None)
		th.start()
		
		while True:
			self.win_height, self.win_chars = self.screen.getmaxyx()
			self.parse_input()
			try:
				log_len = self.update_main()
				self.update_log(log_len)
			except curses.error, e:
				logger.warning(e)
			else:
				curses.doupdate()
			time.sleep(0.5)
		
	def parse_input(self):
		""""""
		try:
			input = self.screen.getkey()
		except curses.error:
			if not self.quit_question:
				self.update_status()
		else:
			if self.quit_question:
				if input.lower() == "y":
					self.quit()
				else:
					self.quit_question = False
					self.update_status()
			else:
				if input.lower() == "q":
					self.quit_question = True
					self.question()
				else:
					self.update_status()
					
	def update_main(self):
		""""""
		if self.win_height > 5:
			cont = 0
			self.main_pad.erase()
			self.total_speed = 0
			for download in self.download_manager.complete_downloads + self.download_manager.active_downloads:
				service = "[]"
				for link in download.links:
					if link.active:
						service = "[%s %s]" %(link.plugin_type, link.service)
				self.total_speed += download.speed
				percent = "%i%s" % (int(download.progress), "%")
				speed = "%s KB/s" % download.speed
				size = "%i%s / %i%s" % (download.actual_size, download.actual_size_unit, download.total_size, download.total_size_unit)
				time = str(self.calculate_time(download.time))
				self.main_pad.addnstr(cont, 1, download.name, WIDTH)
				self.main_pad.addnstr(cont+1, 5, "%s %s \t%s \t%s \t%s" % (percent, service, size, speed, time), WIDTH)
				cont +=3
			self.download_manager.update()
			#2 primeras lineas en blanco
			cont +=2
			remain = self.win_height-cont
			start = 0
			while remain <= 5:
					remain += 3
					start += 3
			self.main_pad.noutrefresh(start, 0, 2, 0, cont-start, self.win_chars-1)
			return remain

	def update_log(self, length):
		""""""
		if length:
			lines = self.stream.readnlines(length)
			if lines:
				self.last_length = length
				self.log_pad.erase()
				for i in range(len(lines)):
					self.log_pad.addnstr(i, 0, lines[i], WIDTH, curses.A_DIM)
				self.log_pad.noutrefresh(0, 0, self.win_height-length, 0, self.win_height-1, self.win_chars-1)

	def update_status(self):
		""""""
		active = len(self.download_manager.active_downloads)
		complete = len(self.download_manager.complete_downloads)
		total = len(self.download_manager.pending_downloads + self.download_manager.active_downloads + self.download_manager.complete_downloads)
		self.status_pad.erase()
		self.status_pad.addnstr(0, 0, "Downstream: %s KB/s \tTotal %s \tActive %s \tComplete %s" % (self.total_speed, total, active, complete), WIDTH, curses.A_BOLD)
		self.status_pad.noutrefresh(0, 0, 0, 0, 0, self.win_chars-1)

	def question(self):
		""""""
		self.status_pad.erase()
		self.status_pad.addnstr(0, 0, "Are you sure you want to quit? [y/N]", WIDTH, curses.A_STANDOUT)
		self.status_pad.noutrefresh(0, 0, 0, 0, 0, self.win_chars-1)
		
	def calculate_time(self, time):
		""""""
		result = None
		hours = 0
		minutes = 0
		while time >= cons.HOUR:
			time = time - cons.HOUR
			hours += 1
		while time >= cons.MINUTE:
			time = time - cons.MINUTE
			minutes += 1
		seconds = time
		if hours > 0:
			result = str(hours) + "h" + str(minutes) + "m" + str(seconds) + "s"
		elif minutes > 0:
			result =  str(minutes) + "m" + str(seconds) + "s"
		elif seconds > 0:
			result = str(seconds) + "s"
		return result
