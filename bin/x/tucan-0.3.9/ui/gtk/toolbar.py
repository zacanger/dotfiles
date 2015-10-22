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

import pygtk
pygtk.require('2.0')
import gtk

class Toolbar(gtk.Toolbar):
	""""""
	def __init__(self, list):
		"""list = [(tool_name, image, callback),]"""
		gtk.Toolbar.__init__(self)
		self.set_style(gtk.TOOLBAR_BOTH)
		for button in list:
			if button == None:
				item = gtk.SeparatorToolItem()
			else:
				item = gtk.ToolButton(button[1], button[0])
				item.connect("clicked", button[2])
			self.insert(item, -1)