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
import gobject

import core.cons as cons

class Wait(gtk.Window):
	""""""
	def __init__(self, message, parent):
		""""""
		gtk.Window.__init__(self, gtk.WINDOW_TOPLEVEL)
		self.set_transient_for(parent)
		self.set_modal(True)
		self.set_position(gtk.WIN_POS_CENTER)
		self.set_property("skip-pager-hint", True)
		self.set_property("skip-taskbar-hint", True)
		self.set_resizable(False)
		self.set_decorated(False)
		self.set_size_request(300,100)

		self.progress = gtk.ProgressBar()
		self.add(self.progress)
		self.progress.set_text(message)

		self.show_all()

		gobject.timeout_add(100, self.pulse)

	def pulse(self):
		""""""
		self.progress.pulse()
		return True

class Message(gtk.Dialog):
	""""""
	def __init__(self, parent, severity, title, message, accept=False, both=False, run=True):
		""""""
		gtk.Dialog.__init__(self)
		self.set_title(title)
		self.set_position(gtk.WIN_POS_CENTER)
		self.set_resizable(False)
		self.set_transient_for(parent)

		self.accepted = False

		hbox = gtk.HBox()
		self.vbox.pack_start(hbox, True, True, 10)
		icon = gtk.STOCK_DIALOG_INFO
		if severity == cons.SEVERITY_WARNING:
			icon = gtk.STOCK_DIALOG_WARNING
		elif severity == cons.SEVERITY_ERROR:
			icon = gtk.STOCK_DIALOG_ERROR
		hbox.pack_start(gtk.image_new_from_stock(icon, gtk.ICON_SIZE_DIALOG), True, False, 10)
		self.set_icon(self.render_icon(icon, gtk.ICON_SIZE_MENU))

		self.label = gtk.Label(message)
		hbox.pack_start(self.label, True, False, 5)
		self.label.set_width_chars(35)
		self.label.set_line_wrap(True)

		#action area
		if both:
			close_button = gtk.Button(None, gtk.STOCK_CANCEL)
			self.action_area.pack_start(close_button)
			close_button.connect("clicked", self.close)
			ok_button = gtk.Button(None, gtk.STOCK_OK)
			self.action_area.pack_start(ok_button)
			ok_button.connect("clicked", self.accept)
		elif accept:
			ok_button = gtk.Button(None, gtk.STOCK_OK)
			self.action_area.pack_start(ok_button)
			ok_button.connect("clicked", self.accept)
		else:
			close_button = gtk.Button(None, gtk.STOCK_CLOSE)
			self.action_area.pack_start(close_button)
			close_button.connect("clicked", self.close)

		self.connect("response", self.close)
		self.show_all()
		if run:
			self.run()

	def accept(self, button):
		""""""
		self.accepted = True
		self.close()

	def close(self, widget=None, other=None):
		""""""
		self.destroy()

if __name__ == "__main__":
	m = Message(None, cons.SEVERITY_WARNING, "Tucan Manager - Restore previous session.", "Your last session closed unexpectedly.\nTucan will try to restore it now.", both=True)
