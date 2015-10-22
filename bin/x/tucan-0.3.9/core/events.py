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

import cons

class Events:
	""""""
	def __init__(self):
		""""""
		self.registered = {}
		
	def connect(self, event, callback, *kargs):
		""""""
		if event in self.registered:
			result = len(self.registered[event])
			self.registered[event].append((callback, kargs))
			return result
		else:
			self.registered[event] = [(callback, kargs)]
			return 0

	def disconnect(self, event, id):
		""""""
		try:
			if event in self.registered:
				del self.registered[event][id]
		except Exception, e:
			logger.Error("Could not disconnect: %s %i" % (event, id))

	def trigger(self, event, *kargs):
		""""""
		if event in self.registered:
			for callback, kargs2 in self.registered[event]:
				try:
					callback(*(kargs+kargs2))
				except Exception, e:
					logger.exception(e)

	def trigger_limit_off(self, module):
		""""""
		logger.debug("triggered: %s from %s" % (cons.EVENT_LIMIT_OFF, module))
		self.trigger(cons.EVENT_LIMIT_OFF, module)
	
	def trigger_limit_on(self, module):
		""""""
		logger.debug("triggered: %s from %s" % (cons.EVENT_LIMIT_ON, module))
		self.trigger(cons.EVENT_LIMIT_ON, module)

	def trigger_limit_cancel(self, module):
		""""""
		logger.debug("triggered: %s from %s" % (cons.EVENT_LIMIT_CANCEL, module))
		self.trigger(cons.EVENT_LIMIT_CANCEL, module)
	
	def trigger_all_complete(self):
		""""""
		logger.debug("triggered: %s" % cons.EVENT_ALL_COMPLETE)
		self.trigger(cons.EVENT_ALL_COMPLETE)
