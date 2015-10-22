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
import __builtin__
import logging
logger = logging.getLogger(__name__)

import pygtk
pygtk.require('2.0')
import gtk
import gobject

import media
import core.cons as cons

class Statusbar(gtk.Statusbar):
	""""""
	def __init__(self):
		""""""
		gtk.Statusbar.__init__(self)
		self.set_has_resize_grip(False)
		
		self.services = configuration.get_services()
		self.blinks = 0
		
		#download speed limit
		frame = gtk.Frame()
		frame.set_shadow_type(gtk.SHADOW_IN)
		self.pack_start(frame, False, False)
		hbox = gtk.HBox()
		frame.add(hbox)
		label = gtk.Label(_("Max speed:"))
		hbox.pack_start(label, False, False, 2)
		self.max_speed = gtk.SpinButton(None, 4, 0)
		self.max_speed.set_property("shadow-type", gtk.SHADOW_NONE)
		self.max_speed.set_range(0,5000)
		self.max_speed.set_increments(4,0)
		self.max_speed.set_numeric(True)
		self.max_speed.set_value(__builtin__.max_download_speed)
		hbox.pack_start(self.max_speed, False, False, )

		self.max_speed.connect("value-changed", self.change_speed)

		self.menu = gtk.Menu()
		
		self.limits = {}
		events.connect(cons.EVENT_LIMIT_ON, self.add_limit)
		events.connect(cons.EVENT_LIMIT_OFF, self.remove_limit)
		
		frame = gtk.Frame()
		frame.set_shadow_type(gtk.SHADOW_IN)
		self.pack_start(frame, False, False)
		hbox = gtk.HBox()
		frame.add(hbox)
		label = gtk.Label("Limits:")
		hbox.pack_start(label, False, False, 2)
		self.button = gtk.Button()
		self.button.set_image(gtk.Arrow(gtk.ARROW_UP, gtk.SHADOW_NONE))
		hbox.pack_start(self.button, False, False, 2)
		self.button.modify_bg(gtk.STATE_NORMAL, gtk.gdk.color_parse("#fff"))

		self.button.connect("clicked", self.show_stack)
		self.show_all()

	def synchronize(self):
		""""""
		self.max_speed.set_value(__builtin__.max_download_speed)

	def change_speed(self, spinbutton):
		""""""
		__builtin__.max_download_speed = spinbutton.get_value_as_int()
		
	def blink(self):
		""""""
		if self.blinks < 10:
			self.blinks += 1
			if self.blinks % 2:
				self.button.modify_bg(gtk.STATE_NORMAL, gtk.gdk.color_parse("#f99"))
			else:
				self.button.modify_bg(gtk.STATE_NORMAL, gtk.gdk.color_parse("#fff"))
			return True
		else:
			self.blinks = 0
		
	def add_limit(self, module):
		""""""
		tmp = module.split(".")				
		callback = lambda x: events.trigger_limit_cancel(module)
		if not module in self.limits:
			for name, icon_path, url, enabled, config in self.services:
				if tmp[0] == name:
					self.limits[module] = self.new_item(url, tmp[1], icon_path, callback)
					gobject.timeout_add(500, self.blink)
					break

	def remove_limit(self, module):
		""""""
		if module in self.limits:
			del self.limits[module]

	def show_stack(self, widget):
		""""""
		for limit in self.menu:
			self.menu.remove(limit)
		if len(self.limits) == 0:
			self.menu.append(self.new_item("None", "", None, lambda x: x))
		else:
			for module, item in self.limits.items():
				self.menu.append(item)
				self.menu.append(gtk.SeparatorMenuItem())
		self.menu.show_all()
		self.menu.popup(None, None, self.menu_position, 1, 0, widget.get_allocation())

	def new_item(self, service, service_type, icon_path, callback):
		""""""
		limit = gtk.MenuItem()
		limit.connect("activate", callback)
		vbox = gtk.VBox()
		hbox = gtk.HBox()
		vbox.pack_start(hbox)
		if icon_path:
			icon = gtk.gdk.pixbuf_new_from_file_at_size(icon_path, 32, 32)
		else:
			icon = gtk.gdk.pixbuf_new_from_file_at_size(media.ICON_MISSING, 32, 32)
		hbox.pack_start(gtk.image_new_from_pixbuf(icon))
		hbox.pack_start(gtk.Label(service))
		vbox.pack_start(gtk.Label(service_type))
		limit.add(vbox)
		return limit

	def menu_position(self, menu, rect):
		""""""
		width, height = menu.size_request()
		window_x, window_y = self.parent.get_parent_window().get_position()
		return rect.x + window_x - (width - rect.width), rect.y + window_y - height, True
