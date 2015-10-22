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

import os

import pygtk
pygtk.require('2.0')
import gtk
import gobject

import core.cons as cons

class FileChooser(gtk.FileChooserDialog):
	""""""
	def __init__(self, parent, func, default_path=None, files=False, save=False):
		""""""
		gtk.FileChooserDialog.__init__(self, "%s - %s" % (cons.TUCAN_NAME,_("Select a Folder")), parent)	
		self.set_position(gtk.WIN_POS_CENTER)

		if default_path:
			self.set_current_folder(default_path)
		self.history_path = self.get_current_folder()

		if files:
			self.set_title("%s - %s" % (cons.TUCAN_NAME, _("Select Files")))
			self.set_action(gtk.FILE_CHOOSER_ACTION_OPEN)
			self.set_select_multiple(True)
		elif save:
			self.set_title("%s - %s" % (cons.TUCAN_NAME,_("Save As")))
			self.set_action(gtk.FILE_CHOOSER_ACTION_SAVE)
		else:
			self.set_action(gtk.FILE_CHOOSER_ACTION_SELECT_FOLDER)

		hidden_button = gtk.CheckButton(("Show hidden files."))
		hidden_button.set_active(self.get_show_hidden())
		self.vbox.pack_start(hidden_button, False, False, 5)
		hidden_button.connect("clicked", self.show_hidden)

		button = gtk.Button(None, gtk.STOCK_CANCEL)
		button.connect("clicked", self.close)
		self.action_area.pack_start(button)
		button = gtk.Button(None, gtk.STOCK_OK)
		button.connect("clicked", self.on_choose_folder, func)
		self.action_area.pack_start(button)
		self.set_position(gtk.WIN_POS_CENTER)

		self.connect("response", self.close)

		self.show_all()
		self.run()

	def show_hidden(self, button):
		""""""
		self.set_show_hidden(button.get_active())

	def on_choose_folder(self, button, func):
		""""""
		for file_name in self.get_filenames():
			func(os.path.join(file_name))
		self.close()

	def close(self, widget=None, response=None):
		""""""
		self.history_path = self.get_current_folder()
		self.set_show_hidden(False)
		self.destroy()

if __name__ == "__main__":
	def mierda(name):
		print name
	f = FileChooser(None, mierda, "/home/crak/")
