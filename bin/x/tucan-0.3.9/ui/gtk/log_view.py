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

import pygtk
pygtk.require('2.0')
import gtk
import gobject

from report import Report

import media
import core.cons as cons

SEVERITY = ["DEBUG", "INFO", "WARNING", "ERROR", "CRITICAL"]
COLORS = {"DEBUG": "grey", "INFO": "green", "WARNING": "yellow", "ERROR": "red", "CRITICAL": "white"}

class LogView(gtk.Dialog):
	""""""
	def __init__(self, parent, stream):
		""""""
		gtk.Dialog.__init__(self)
		self.set_transient_for(parent)
		self.set_title("%s - Log View" % cons.TUCAN_NAME)
		self.set_position(gtk.WIN_POS_CENTER)
		self.set_size_request(700,500)
		self.set_icon(self.render_icon(gtk.STOCK_FILE, gtk.ICON_SIZE_MENU))

		self.stream = stream
		self.back_buffer = gtk.TextBuffer()
		self.back_buffer.set_text(self.stream.read())

		frame = gtk.Frame()
		self.vbox.pack_start(frame)
		frame.set_border_width(10)
		hbox = gtk.HBox()
		frame.add(hbox)

		#auto scroll 
		scroll = gtk.ScrolledWindow()
		hbox.pack_start(scroll)
		scroll.set_policy(gtk.POLICY_AUTOMATIC, gtk.POLICY_AUTOMATIC)
		scroll.get_vadjustment().connect("changed", self.changed)
		scroll.get_vadjustment().connect("value-changed", self.value_changed)		

		#textview
		buffer = gtk.TextBuffer()
		self.textview = gtk.TextView(buffer)
		scroll.add(self.textview)
		self.textview.set_wrap_mode(gtk.WRAP_NONE)
		self.textview.set_editable(False)
		self.textview.set_cursor_visible(False)
		self.textview.modify_base(gtk.STATE_NORMAL, gtk.gdk.color_parse("black"))

		table = buffer.get_tag_table()
		for name, color in COLORS.items():
			tag = gtk.TextTag(name)
			tag.set_property("foreground", color)
			tag.set_property("left_margin", 10)
			tag.set_property("right_margin", 10)
			table.add(tag)

		#combo
		hbox = gtk.HBox()
		self.vbox.pack_start(hbox, False, False, 10)
		buttonbox = gtk.HButtonBox()
		hbox.pack_start(buttonbox, False, False, 10)
		label = gtk.Label("Minimum severity shown.")
		hbox.pack_start(label, False, False, 10)
		aspect = gtk.AspectFrame()
		aspect.set_shadow_type(gtk.SHADOW_NONE)
		hbox.pack_start(aspect)
		
		self.combo = gtk.combo_box_new_text()
		buttonbox.pack_start(self.combo)
		self.combo.connect("changed", self.reload)

		for s in SEVERITY:
			self.combo.append_text(s)
		self.combo.set_active(2)

		#action area
		button = gtk.Button("Report ")
		self.action_area.pack_start(button)
		pixbuf = gtk.gdk.pixbuf_new_from_file_at_size(media.ICON_SEND, 24, 24)
		button.set_image(gtk.image_new_from_pixbuf(pixbuf))
		button.connect("clicked", self.report)
		button = gtk.Button(None, gtk.STOCK_CLOSE)
		self.action_area.pack_start(button)
		button.connect("clicked", self.close)

		self.connect("response", self.close)
		self.show_all()

		gobject.timeout_add(1000, self.update)
		self.run()
		
	def report(self, button=None):
		""""""
		Report(self)

	def insert_color(self, buffer, line):
		""""""
		for s in SEVERITY[self.combo.get_active():]:
			if s in line and buffer.get_tag_table().lookup(s):
				buffer.insert_with_tags(buffer.get_end_iter(), "%s\n" % line, buffer.get_tag_table().lookup(s))
				break

	def reload(self, textview):
		""""""
		buffer = self.textview.get_buffer()
		buffer.set_text("")
		ini, fin = self.back_buffer.get_bounds()
		for line in self.back_buffer.get_text(ini, fin).split("\n"):
			self.insert_color(buffer, line)

	def update(self):
		""""""
		try:
			lines = self.stream.readlines()
			if lines:
				buffer = self.textview.get_buffer()
				for line in lines:
					self.back_buffer.insert(self.back_buffer.get_end_iter(), line)
					self.insert_color(buffer, line.strip())
		except Exception, e:
			logger.exception(e)
		else:
			return True

	def changed(self, vadjust):
		"""autoscroll"""
		if not hasattr(vadjust, "need_scroll") or vadjust.need_scroll:
			vadjust.set_value(vadjust.upper-vadjust.page_size)
			vadjust.need_scroll = True

	def value_changed (self, vadjust):
		"""autoscroll"""
		vadjust.need_scroll = abs(vadjust.value + vadjust.page_size - vadjust.upper) < vadjust.step_increment

	def close(self, widget=None, other=None):
		""""""
		self.destroy()
