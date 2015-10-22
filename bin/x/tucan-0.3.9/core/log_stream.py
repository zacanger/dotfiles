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

class LogStream:
	""""""
	def __init__(self):
		""""""
		self.new_buffer = []
		self.old_buffer = []

	def write(self, message):
		""""""
		self.new_buffer.append(str(message))
		
	def flush(self):
		""""""
		pass
		
	def read(self):
		""""""
		tmp = self.new_buffer
		self.new_buffer = []
		self.old_buffer += tmp
		return "\n".join(self.old_buffer)
		
	def readlines(self):
		""""""
		if len(self.new_buffer) > 0:
			tmp = self.new_buffer
			self.new_buffer = []
			self.old_buffer += tmp
			return tmp

	def readnlines(self, length=0):
		""""""
		if len(self.new_buffer) > 0:
			if length > 0:
				cont = 1
				for line in self.new_buffer:
					tmp = self.new_buffer[0]
					del self.new_buffer[0]
					self.old_buffer.append(tmp)
					if cont >= length:
						break
		return self.old_buffer[-length:]
