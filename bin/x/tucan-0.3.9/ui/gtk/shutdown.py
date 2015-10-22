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
import logging
import subprocess
logger = logging.getLogger(__name__)

import pygtk
pygtk.require('2.0')
import gtk
import gobject

from message import Message

import core.cons as cons

class Shutdown:
	""""""
	def __init__(self, parent, quit):
		""""""
		self.time = 60
		title = "Tucan Manager - Shutting down!"
		self.message = "The system is going to shut down in"
		self.dialog = Message(parent, cons.SEVERITY_WARNING, title, "%s 1 minute." % self.message, True, True, False)
		gobject.timeout_add(1000, self.counter)
		self.dialog.run()
		if self.dialog.accepted:
			try:
				if cons.OS_WINDOWS:
					if subprocess.call(["shutdown.exe", "-f", "-s"], stdout=subprocess.PIPE, stderr=subprocess.PIPE, creationflags=134217728) == 0:
						quit()
				elif cons.OS_OSX:
					if subprocess.call(["osascript", "-e", "tell application \"Finder\" to shut down"], stdout=subprocess.PIPE, stderr=subprocess.PIPE) == 0:
						quit()
				else:
					if subprocess.call(["sudo", "-n", "shutdown", "h", "now"], stdout=subprocess.PIPE, stderr=subprocess.PIPE) == 0:
						quit()
				Message(parent, cons.SEVERITY_ERROR, title, "Could not shut down the computer.")
			except Exception, e:
				logger.exception(e)
				
	def counter(self):
		""""""
		if self.time > 0:
			self.time -= 1
			self.dialog.label.set_text("%s %i seconds." % (self.message, self.time))
			return True
		else:
			self.dialog.accepted = True
			self.dialog.close()

if __name__ == "__main__":
	Shutdown(None, None)
	