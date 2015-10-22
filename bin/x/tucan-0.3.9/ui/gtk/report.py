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
import logging
logger = logging.getLogger(__name__)

import pygtk
pygtk.require('2.0')
import gtk
import gobject

from message import Message

from core.misc import report_log
import core.cons as cons
import media

class Report(gtk.Dialog):
	""""""
	def __init__(self, parent):
		""""""
		gtk.Dialog.__init__(self)
		self.set_transient_for(parent)
		self.set_title("%s - Report problem" % cons.TUCAN_NAME)
		self.set_position(gtk.WIN_POS_CENTER)
		self.set_size_request(400, 300)
		self.set_icon_from_file(media.ICON_SEND)
		
		self.sending = False

		frame = gtk.Frame()
		label = gtk.Label()
		label.set_markup("<b>%s: </b>" % ("Email"))
		frame.set_label_widget(label)
		self.vbox.pack_start(frame, False)
		frame.set_border_width(10)
		self.email = gtk.Entry()
		frame.add(self.email)

		frame = gtk.Frame()
		label = gtk.Label()
		label.set_markup("<b>%s: </b>" % ("Comment"))
		frame.set_label_widget(label)
		self.vbox.pack_start(frame)
		frame.set_border_width(10)
		hbox = gtk.HBox()
		frame.add(hbox)
		scroll = gtk.ScrolledWindow()
		hbox.pack_start(scroll)
		scroll.set_policy(gtk.POLICY_AUTOMATIC, gtk.POLICY_AUTOMATIC)

		#textview
		buffer = gtk.TextBuffer()
		self.textview = gtk.TextView(buffer)
		scroll.add(self.textview)
		self.textview.set_wrap_mode(gtk.WRAP_WORD)

		#status
		self.status_hbox = gtk.HBox()
		self.vbox.pack_start(self.status_hbox, False, False, 5)
		self.label = gtk.Label("Sending report.")
		self.status_hbox.pack_start(self.label, False, False, 11)
		self.progress = gtk.ProgressBar()
		self.progress.pulse()
		self.status_hbox.pack_start(self.progress, True, True, 11)

		#action area
		cancel_button = gtk.Button(None, gtk.STOCK_CANCEL)
		ok_button = gtk.Button(None, gtk.STOCK_OK)
		self.action_area.pack_start(cancel_button)
		self.action_area.pack_start(ok_button)
		cancel_button.connect("clicked", self.close)
		ok_button.connect("clicked", self.send)

		self.connect("response", self.close)
		self.show_all()
		self.status_hbox.hide()
		self.run()

	def send(self, button):
		""""""
		self.status_hbox.show()
		self.email.set_sensitive(False)
		self.textview.set_editable(False)
		self.textview.set_cursor_visible(False)
		self.action_area.set_sensitive(False)
		th = threading.Thread(group=None, target=self.th_send, name=None)
		th.start()

	def th_send(self):
		""""""
		self.sending = True
		gobject.timeout_add(100, self.pulse)
		buffer = self.textview.get_buffer()
		start, end = buffer.get_bounds()
		comment = buffer.get_text(start, end).strip()
		id = report_log(self.email.get_text(), comment)
		self.sending = False
		gobject.idle_add(self.reported, id)
		
	def reported(self, id):
		""""""
		if id:
			label = "Report ID:"
			self.status_hbox.remove(self.status_hbox.get_children().pop())
			id = gtk.Label(id)
			id.set_selectable(True)
			self.status_hbox.pack_end(id, True, False, 10)
			id.show()
		else:
			label = "Report failed, try again later."
			self.progress.hide()
		self.label.set_text(label)

		close_button = gtk.Button(None, gtk.STOCK_CLOSE)
		close_button.connect("clicked", self.close)
		close_button.show()
		for child in self.action_area.get_children():
			self.action_area.remove(child)
		self.action_area.pack_start(close_button)
		self.action_area.set_sensitive(True)

	def pulse(self):
		""""""
		if self.sending:
			self.progress.pulse()
			return True

	def close(self, widget=None, other=None):
		""""""
		if not self.sending:
			self.destroy()
