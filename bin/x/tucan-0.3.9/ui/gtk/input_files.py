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

from file_chooser import FileChooser

import media
import core.cons as cons

SERVICES = [("Megaupload", 100, cons.UNIT_MB, ["Anonymous", "Premium"]), ("Rapidshare", 200, cons.UNIT_MB, ["Collector", "Premium"]), ("Gigasize", 100, cons.UNIT_MB, ["Anonymous"])]

class InputFiles(gtk.Dialog):
	""""""
	def __init__(self, parent, upload_services):
		""""""
		gtk.Dialog.__init__(self)
		self.set_transient_for(parent)
		self.set_icon_from_file(media.ICON_UPLOAD)
		self.set_title(("Input Files"))
		self.set_position(gtk.WIN_POS_CENTER)
		self.set_size_request(600,500)

		self.history_path = cons.DEFAULT_PATH

		main_hbox = gtk.HBox()
		self.vbox.pack_start(main_hbox)

		self.file_icon = self.render_icon(gtk.STOCK_FILE, gtk.ICON_SIZE_BUTTON)
		self.correct_icon = self.render_icon(gtk.STOCK_APPLY, gtk.ICON_SIZE_MENU)
		self.incorrect_icon = self.render_icon(gtk.STOCK_CANCEL, gtk.ICON_SIZE_MENU)

		#package treeview
		frame = gtk.Frame()
		main_hbox.pack_start(frame, True)
		frame.set_border_width(5)
		scroll = gtk.ScrolledWindow()
		frame.add(scroll)
		scroll.set_policy(gtk.POLICY_AUTOMATIC, gtk.POLICY_AUTOMATIC)
		self.package_treeview = gtk.TreeView(gtk.TreeStore(gtk.gdk.Pixbuf, str, str, str, bool))
		scroll.add(self.package_treeview)

		self.package_treeview.set_rules_hint(True)
		self.package_treeview.set_headers_visible(False)

		tree_icon = gtk.TreeViewColumn('Icon') 
		icon_cell = gtk.CellRendererPixbuf()
		tree_icon.pack_start(icon_cell, True)
		tree_icon.add_attribute(icon_cell, 'pixbuf', 0)
		self.package_treeview.append_column(tree_icon)

		tree_name = gtk.TreeViewColumn('Name') 
		name_cell = gtk.CellRendererText()
		tree_name.pack_start(name_cell, True)
		tree_name.add_attribute(name_cell, 'text', 1)
		self.package_treeview.append_column(tree_name)

		tree_size = gtk.TreeViewColumn('Size') 
		size_cell = gtk.CellRendererText()
		tree_size.pack_start(size_cell, False)
		tree_size.add_attribute(size_cell, 'text', 2)
		self.package_treeview.append_column(tree_size)

		service_vbox = gtk.VBox()
		main_hbox.pack_start(service_vbox, False, False)

		# services treeview
		frame = gtk.Frame()
		service_vbox.pack_start(frame)
		frame.set_size_request(200, -1)
		frame.set_border_width(5)
		frame.set_label_widget(gtk.image_new_from_file(media.ICON_PREFERENCES_SERVICES))
		scroll = gtk.ScrolledWindow()
		frame.add(scroll)
		scroll.set_policy(gtk.POLICY_AUTOMATIC, gtk.POLICY_AUTOMATIC)
		services = gtk.ListStore(gtk.gdk.Pixbuf, str, int, str, bool, gobject.TYPE_PYOBJECT)
		self.services_treeview = gtk.TreeView(services)
		self.services_treeview.get_selection().connect("changed", self.select)
		scroll.add(self.services_treeview)

		self.services_treeview.set_rules_hint(True)
		self.services_treeview.set_headers_visible(False)

		tree_icon = gtk.TreeViewColumn('Icon') 
		icon_cell = gtk.CellRendererPixbuf()
		tree_icon.pack_start(icon_cell, True)
		tree_icon.add_attribute(icon_cell, 'pixbuf', 0)
		self.services_treeview.append_column(tree_icon)

		tree_name = gtk.TreeViewColumn('Name') 
		name_cell = gtk.CellRendererText()
		tree_name.pack_start(name_cell, True)
		tree_name.add_attribute(name_cell, 'text', 1)
		self.services_treeview.append_column(tree_name)

		tree_add = gtk.TreeViewColumn('Add')
		add_cell = gtk.CellRendererToggle()
		add_cell.connect("toggled", self.toggled)
		tree_add.pack_start(add_cell, True)
		tree_add.add_attribute(add_cell, 'active', 4)
		self.services_treeview.append_column(tree_add)

		#plugins
		self.plugins_frame = gtk.Frame()
		service_vbox.pack_start(self.plugins_frame, False, False)
		self.plugins_frame.set_size_request(200, 100)
		self.plugins_frame.set_border_width(5)

		for service, size, unit, plugins in upload_services:
			vbox = gtk.VBox()
			first = None
			for plugin in plugins:
				first = gtk.RadioButton(first, plugin)
				vbox.pack_start(first, False, False, 1)
			services.append([self.correct_icon, service, size, unit, False, vbox])

		#choose path
		hbox = gtk.HBox()
		self.vbox.pack_start(hbox, False, False, 5)
		path_button = gtk.Button(None, gtk.STOCK_OPEN)
		path_button.set_size_request(90,40)
		hbox.pack_start(path_button, False, False, 5)
		path_button.connect("clicked", self.choose_files)
		path_label = gtk.Label(("Choose files to upload."))
		hbox.pack_start(path_label, False, False, 5)
		aspect = gtk.AspectFrame()
		hbox.pack_start(aspect, True, True)
		aspect.set_shadow_type(gtk.SHADOW_NONE)
		clear_button = gtk.Button(None, gtk.STOCK_CLEAR)
		clear_button.set_size_request(190,40)
		hbox.pack_start(clear_button, False, False, 5)
		clear_button.connect("clicked", self.clear)

		#action area
		cancel_button = gtk.Button(None, gtk.STOCK_CANCEL)
		add_button = gtk.Button(None, gtk.STOCK_ADD)
		self.action_area.pack_start(cancel_button)
		self.action_area.pack_start(add_button)
		cancel_button.connect("clicked", self.close)
		add_button.connect("clicked", self.add_files)

		self.connect("response", self.close)
		self.show_all()
		self.set_focus(path_button)
		self.run()

	def clear(self, button):
		""""""
		self.package_treeview.get_model().clear()

	def select(self, selection):
		""""""
		model, service_iter = selection.get_selected()
		if iter:
			if self.plugins_frame.get_child():
				self.plugins_frame.remove(self.plugins_frame.get_child())
			vbox = model.get_value(service_iter, 5)
			self.plugins_frame.add(vbox)
			vbox.show_all()

	def add_files(self, button):
		""""""
		result = []
		package_model = self.package_treeview.get_model()
		services_model = self.services_treeview.get_model()

		file_iter = package_model.get_iter_root()
		while file_iter:
			services = []
			service_iter = package_model.iter_children(file_iter)
			while service_iter:
				service_name = package_model.get_value(service_iter, 1)
				if package_model.get_value(service_iter, 4):
					for service in services_model:
						if service[1] == service_name:
							for button in service[5].get_children():
								if button.get_active():
									services.append((service_name, button.get_label()))
				service_iter = package_model.iter_next(service_iter)
			if len(services) > 0:
				tmp = package_model.get_value(file_iter, 2).split(" ")
				size, unit = self.split_size(self.join_size(int(tmp[0]), tmp[1]))
				result.append((package_model.get_value(file_iter, 3), int(size), unit, services))
			file_iter = package_model.iter_next(file_iter)
		self.close()
		print result

	def toggled(self, button, path):
		""""""
		active = True
		if button.get_active():
			active = False
		button.set_active(active)

		services_model = self.services_treeview.get_model()
		package_model = self.package_treeview.get_model()

		services_model.set_value(services_model.get_iter(path), 4, active)

		file_iter = package_model.get_iter_root()
		while file_iter:
			service_iter = package_model.iter_children(file_iter)
			found = False
			while service_iter:
				if services_model.get_value(services_model.get_iter(path), 1) == package_model.get_value(service_iter, 1):
					found = True
					break
				service_iter = package_model.iter_next(service_iter)
			if active:
				if not found:
					tmp = package_model.get_value(file_iter, 2).split(" ")
					max_size = self.join_size(services_model.get_value(services_model.get_iter(path), 2), services_model.get_value(services_model.get_iter(path), 3))
					self.add_service(package_model, file_iter, services_model.get_value(services_model.get_iter(path), 1), self.join_size(int(tmp[0]), tmp[1]), max_size)
			else:
				if found:
					package_model.remove(service_iter)
			file_iter = package_model.iter_next(file_iter)

	def choose_files(self, button):
		""""""
		f = FileChooser(self, self.on_choose, self.history_path, True)
		self.history_path = f.history_path

	def on_choose(self, path):
		""""""
		package_model = self.package_treeview.get_model()
		services_model = self.services_treeview.get_model()
		if os.path.isfile(path):
			if path not in [row[1] for row in package_model]:
				file_size = int(os.stat(path).st_size/1024)
				size, unit = self.split_size(file_size)
				file_iter = package_model.append(None, [self.file_icon, os.path.basename(path), "%i %s" %(size, unit), path, None])	
				for row in services_model:
					if row[4]:
						self.add_service(package_model, file_iter, row[1], file_size, self.join_size(row[2], row[3]))

	def join_size(self, size, unit):
		""""""
		factor = 1
		if unit == cons.UNIT_KB:
			factor = 1
		elif unit == cons.UNIT_MB:
			factor = 1024
		elif unit == cons.UNIT_GB:
			factor = 1024*1024
		return size*factor

	def split_size(self, size):
		""""""
		if size > 0:
			tmp = size/1024
			if tmp > 0:
				tmp2 = tmp/1024
				if tmp2 > 0:
					return tmp2, cons.UNIT_GB
				else:
					return tmp, cons.UNIT_MB
			else:
				return size, cons.UNIT_KB
		else:
			return 1, cons.UNIT_KB	

	def add_service(self, package_model, file_iter, service, file_size, max_size):
		""""""
		if max_size > file_size:
			package_model.append(file_iter, [self.correct_icon, service, None, None, True])
		else:
			package_model.append(file_iter, [self.incorrect_icon, service, None, None, False])
		self.package_treeview.expand_row(package_model.get_path(file_iter), True)

	def close(self, widget=None, other=None):
		""""""
		self.destroy()

if __name__ == "__main__":
	x = InputFiles(None, SERVICES)
