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
import logging
logger = logging.getLogger(__name__)

import pygtk
pygtk.require('2.0')
import gtk

from file_chooser import FileChooser

import media
import core.cons as cons

class AdvancedPackages(gtk.Dialog):
	""""""
	def __init__(self, parent, default_path, packages):
		""""""
		gtk.Dialog.__init__(self)
		self.set_icon_from_file(media.ICON_PACKAGE)
		self.set_transient_for(parent)
		self.set_title("%s - %s" % (cons.TUCAN_NAME, _("Advanced Packages")))
		self.set_position(gtk.WIN_POS_CENTER)
		self.set_size_request(600,400)
		
		self.packages = packages
		self.packages_info = []
		self.history_path = default_path
		
		#radio
		frame = gtk.Frame()
		self.vbox.pack_start(frame, False, False)
		frame.set_border_width(10)
		hbox = gtk.HBox()
		frame.add(hbox)
		multi = gtk.RadioButton(None, "Auto Package Mode")
		multi.connect("toggled", self.change_mode, True)
		hbox.pack_start(multi)
		single = gtk.RadioButton(multi, "Single Package Mode")
		single.connect("toggled", self.change_mode, False)
		hbox.pack_start(single)
		
		#treeview
		frame = gtk.Frame()
		self.vbox.pack_start(frame)
		frame.set_border_width(10)
		scroll = gtk.ScrolledWindow()
		frame.add(scroll)
		scroll.set_policy(gtk.POLICY_AUTOMATIC, gtk.POLICY_AUTOMATIC)
		self.multi_model = gtk.ListStore(gtk.gdk.Pixbuf, str, str, str, int)
		self.single_model = gtk.ListStore(gtk.gdk.Pixbuf, str, str, str, int)
		self.treeview = gtk.TreeView(self.multi_model)
		self.treeview.get_selection().connect("changed", self.select)
		scroll.add(self.treeview)

		self.treeview.set_rules_hint(True)
		#self.treeview.set_headers_visible(False)

		tree_icon = gtk.TreeViewColumn('Icon') 
		icon_cell = gtk.CellRendererPixbuf()
		tree_icon.pack_start(icon_cell, True)
		tree_icon.add_attribute(icon_cell, 'pixbuf', 0)
		self.treeview.append_column(tree_icon)

		tree_path = gtk.TreeViewColumn('Path') 
		path_cell = gtk.CellRendererText()
		tree_path.pack_start(path_cell, True)
		tree_path.add_attribute(path_cell, 'text', 1)
		self.treeview.append_column(tree_path)
		self.treeview.connect("row-activated", self.choose)

		tree_name = gtk.TreeViewColumn('Name') 
		name_cell = gtk.CellRendererText()
		name_cell.set_property("editable", True)
		name_cell.connect("edited", self.change, 2)
		tree_name.pack_start(name_cell, True)
		tree_name.add_attribute(name_cell, 'text', 2)
		self.treeview.append_column(tree_name)

		tree_pass = gtk.TreeViewColumn('Password') 
		pass_cell = gtk.CellRendererText()
		pass_cell.set_property("editable", True)
		pass_cell.connect("edited", self.change, 3)
		tree_pass.pack_start(pass_cell, True)
		tree_pass.add_attribute(pass_cell, 'text', 3)
		self.treeview.append_column(tree_pass)

		#fill treestore
		package_icon = gtk.gdk.pixbuf_new_from_file_at_size(media.ICON_PACKAGE, 32, 32)
		single_package_name = "package-%s" % time.strftime("%Y%m%d%H%M%S")
		single_package_links = []
		for package_name, package_links in self.packages:
			single_package_links += package_links
			self.multi_model.append((package_icon, default_path, package_name, None, len(package_links)))
		self.multi_packages = self.packages
		self.single_package = [(single_package_name, single_package_links)]
		self.single_model.append((package_icon, default_path, single_package_name, None, len(single_package_links)))

		#choose path
		hbox = gtk.HBox()
		self.vbox.pack_start(hbox, False, False, 5)
		path_button = gtk.Button(None, gtk.STOCK_OPEN)
		hbox.pack_start(path_button, False, False, 10)
		path_button.set_size_request(90,40)
		path_button.connect("clicked", self.choose_path)
		path_label = gtk.Label(_("Choose new path for selected Package."))
		hbox.pack_start(path_label, False, False, 10)
		aspect = gtk.AspectFrame()
		aspect.set_shadow_type(gtk.SHADOW_NONE)
		hbox.pack_start(aspect, True, True)
		
		#info
		frame = gtk.Frame()
		hbox.pack_start(frame)
		frame.set_border_width(10)
		self.info_name = gtk.Label()
		self.info_name.set_markup("<b>%s: </b>" % ("Packages"))
		frame.set_label_widget(self.info_name)
		vbox = gtk.VBox()
		frame.add(vbox)
		self.info_label = gtk.Label(len(packages))
		vbox.pack_start(self.info_label, False, False, 5)
		
		#action area
		cancel_button = gtk.Button(None, gtk.STOCK_CANCEL)
		self.action_area.pack_start(cancel_button)
		cancel_button.connect("clicked", self.close)
		ok_button = gtk.Button(None, gtk.STOCK_OK)
		self.action_area.pack_start(ok_button)
		ok_button.connect("clicked", self.configure_packages)

		self.connect("response", self.close)
		self.show_all()
		self.run()
		
	def change_mode(self, button, multi):
		""""""
		if multi:
			if button.get_active():
				logger.info("setting Auto Package Mode")
				self.treeview.set_model(self.multi_model)
				self.treeview.set_cursor_on_cell(0)
				self.packages = self.multi_packages
		else:
			if button.get_active():
				logger.info("setting Single Package Mode")
				self.treeview.set_model(self.single_model)
				self.treeview.set_cursor_on_cell(0)
				self.packages = self.single_package

	def set_info(self, num):
		""""""
		self.info_name.set_markup("<b>%s: </b>" % ("Files"))
		self.info_label.set_text(str(num))

	def select(self, selection):
		""""""
		model, iter = selection.get_selected()
		if iter:
			self.set_info(model.get_value(iter, 4))

	def configure_packages(self, button=None):
		""""""
		model = self.treeview.get_model()
		for package in model:
			self.packages_info.append((package[1], package[2], package[3]))
		self.close()

	def choose(self, treeview, path, view_column):
		""""""
		self.choose_path()

	def choose_path(self, button=None):
		""""""
		model, iter = self.treeview.get_selection().get_selected()
		if iter:
			f = FileChooser(self, self.on_choose, self.history_path)
			self.history_path = f.history_path

	def on_choose(self, folder_path):
		""""""
		model, iter = self.treeview.get_selection().get_selected()
		if iter:
			model.set_value(iter, 1, folder_path)

	def change(self, cellrenderertext, path, new_text, column):
		""""""
		model = self.treeview.get_model()
		model.set_value(model.get_iter(path), column, new_text)

	def close(self, widget=None, other=None):
		""""""
		self.destroy()
