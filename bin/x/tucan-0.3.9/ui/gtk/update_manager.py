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

import pygtk
pygtk.require('2.0')
import gtk
import gobject

from message import Message
from core.service_update import ServiceUpdate

import media
import core.cons as cons

class UpdateManager(gtk.Dialog, ServiceUpdate):
	""""""
	def __init__(self, parent, config, info=None):
		""""""
		gtk.Dialog.__init__(self)
		ServiceUpdate.__init__(self, config)
		self.set_transient_for(parent)
		self.parent_widget = parent
		
		self.installing = False
		self.remote_info = info

		self.set_icon_from_file(media.ICON_UPDATE)
		self.set_title(("Update Manager"))
		self.set_size_request(400,300)

		# treeview
		frame = gtk.Frame()
		self.vbox.pack_start(frame)
		frame.set_size_request(200, -1)
		frame.set_border_width(10)
		label = gtk.Label()
		label.set_markup("<b>%s</b>" % ("Update Services"))
		frame.set_label_widget(label)
		scroll = gtk.ScrolledWindow()
		frame.add(scroll)
		scroll.set_policy(gtk.POLICY_AUTOMATIC, gtk.POLICY_AUTOMATIC)
		self.treeview = gtk.TreeView(gtk.ListStore(gtk.gdk.Pixbuf, str, bool, str, gobject.TYPE_PYOBJECT))
		scroll.add(self.treeview)

		self.treeview.set_rules_hint(True)
		self.treeview.set_headers_visible(False)

		tree_icon = gtk.TreeViewColumn('Icon') 
		icon_cell = gtk.CellRendererPixbuf()
		tree_icon.pack_start(icon_cell, True)
		tree_icon.add_attribute(icon_cell, 'pixbuf', 0)
		tree_icon.set_property('min-width', 100)
		self.treeview.append_column(tree_icon)

		tree_name = gtk.TreeViewColumn('Name') 
		name_cell = gtk.CellRendererText()
		tree_name.pack_start(name_cell, True)
		tree_name.add_attribute(name_cell, 'text', 1)
		tree_name.set_property('min-width', 200)
		self.treeview.append_column(tree_name)

		tree_add = gtk.TreeViewColumn('Add')
		add_cell = gtk.CellRendererToggle()
		add_cell.connect("toggled", self.toggled)
		tree_add.pack_start(add_cell, True)
		tree_add.add_attribute(add_cell, 'active', 2)
		self.treeview.append_column(tree_add)

		#status
		hbox = gtk.HBox()
		self.vbox.pack_start(hbox, False, False, 5)

		self.status_icon = gtk.image_new_from_stock(gtk.STOCK_REFRESH, gtk.ICON_SIZE_MENU)
		hbox.pack_start(self.status_icon, False, False, 10)
		self.status_label = gtk.Label("Checking for updates.")
		hbox.pack_start(self.status_label, False, False, 5)
		self.progress = gtk.ProgressBar()
		hbox.pack_start(self.progress, True, True, 20)

		#action area
		cancel_button = gtk.Button(None, gtk.STOCK_CANCEL)
		add_button = gtk.Button(None, gtk.STOCK_ADD)
		self.action_area.pack_start(cancel_button)
		self.action_area.pack_start(add_button)
		cancel_button.connect("clicked", self.close)
		add_button.connect("clicked", self.install)

		self.connect("response", self.close)
		self.show_all()

		self.progress.hide()
		
		gobject.timeout_add(200, self.check_version)

		self.run()
		
	def check_version(self):
		""""""
		self.get_updates()
		if self.remote_version == None:
			message = "Update Manager can't connect to server.\nTry again later."
			Message(self, cons.SEVERITY_ERROR, "Tucan Manager - Not available!", message)
			gobject.idle_add(self.close)
		elif self.remote_version.split(" ")[0] <= cons.TUCAN_VERSION.split(" ")[0]:
			self.check_updates()
		else:
			message = "Version %s released!\nPlease update and enjoy new services." % self.server_version
			Message(self, cons.SEVERITY_ERROR, "Tucan Manager - Outdated!", message)
			gobject.idle_add(self.close)

	def toggled(self, button, path):
		""""""
		model = self.treeview.get_model()
		active = True
		if button.get_active():
			active = False
		button.set_active(active)
		model.set_value(model.get_iter(path), 2, active)

	def check_updates(self):
		""""""
		model = self.treeview.get_model()
		default_icon = gtk.gdk.pixbuf_new_from_file_at_size(media.ICON_UPDATE, 32, 32)

		updated = 0
		new = 0
		for service, options in self.updates.items():
			if options[2]:
				icon = gtk.gdk.pixbuf_new_from_file_at_size(options[2], 32, 32)
				updated += 1
			else:
				icon = default_icon
				new += 1
			if model:
				model.append([icon, service, False, options[0], options[1]])

		self.status_icon.set_from_stock(gtk.STOCK_DIALOG_WARNING, gtk.ICON_SIZE_BUTTON)
		self.status_label.set_label("%i New and %i Updated." % (new, updated))
		if updated == 0 and new == 0:
			gobject.timeout_add(5000, self.close)

	def install(self, button):
		""""""
		self.progress.show()
		self.status_icon.set_from_stock(gtk.STOCK_GO_DOWN, gtk.ICON_SIZE_MENU)
		self.status_label.set_label("Installing")
		self.action_area.set_sensitive(False)
		th = threading.Thread(group=None, target=self.install_all, name=None)
		th.start()
		
	def install_all(self):
		""""""
		self.installing = True
		model = self.treeview.get_model()

		install_targets = []
		update_iter = model.get_iter_root()
		while update_iter:
			if model.get_value(update_iter, 2):
				install_targets.append(model.get(update_iter, 1, 3, 4))
			update_iter = model.iter_next(update_iter)
		if len(install_targets) > 0:
			cont = 0
			self.progress.set_text("%i of %i" % (cont, len(install_targets)))
			for service_name, service_dir, archive in install_targets:
				if self.install_service(service_name, service_dir, archive):
					cont += 1
					self.progress.set_fraction(float(cont)/len(install_targets))
					self.progress.set_text("%i of %i" % (cont, len(install_targets)))
			if cont != len(install_targets):
				message = "Problem updating some services \nTry again later."
			else:
				message = "Save your configuration and restart Tucan \nto apply service changes."
			gobject.idle_add(self.restart, message)
			self.installing = False
			gobject.idle_add(self.close)
		else:
			self.installing = False
			gobject.idle_add(self.close)
			
	def restart(self, message):
		""""""
		Message(self.parent_widget, cons.SEVERITY_WARNING, "Tucan Manager - Restart Needed.", message)

	def close(self, widget=None, other=None):
		""""""
		if not self.installing:
			self.destroy()

if __name__ == "__main__":
	from config import Config
	x = UpdateManager(None, Config(), None)
