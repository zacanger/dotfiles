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

import core.service_config as service_config
import core.cons as cons
import media


class InfoPreferences(gtk.VBox):
	""""""
	def __init__(self, section, name, config, accounts=False):
		""""""	
		gtk.VBox.__init__(self)
		vbox = gtk.VBox()

		frame = gtk.Frame()
		label = gtk.Label()
		label.set_markup("<big><b>" + name + "</b></big>")
		frame.set_label_widget(label)
		frame.set_border_width(10)
		self.pack_start(frame)
		frame.add(vbox)

		hbox = gtk.HBox()
		label = gtk.Label()
		label.set_markup("<b>" + _("Author") + ":</b>")
		hbox.pack_start(label, False, False, 10)
		label = gtk.Label(config.get(section, service_config.OPTION_AUTHOR))
		hbox.pack_start(label, False)
		aspect = gtk.AspectFrame()
		aspect.set_shadow_type(gtk.SHADOW_NONE)
		hbox.pack_start(aspect)
		label = gtk.Label()
		label.set_markup("<b>" + _("Version") + ":</b>")
		hbox.pack_start(label, False)
		label = gtk.Label(config.get(section, service_config.OPTION_VERSION))
		hbox.pack_start(label, False, False, 10)
		vbox.pack_start(hbox, False, False, 5)

		if not accounts:
			hbox = gtk.HBox()
			label = gtk.Label()
			label.set_markup("<b>" + _("Slots") + ":</b>")
			hbox.pack_start(label, False, False, 10)
			label = gtk.Label(config.get(section, service_config.OPTION_SLOTS))
			hbox.pack_start(label, False)
			vbox.pack_start(hbox, False, False, 5)
			hbox = gtk.HBox()
			label = gtk.Label()
			label.set_markup("<b>" + _("Captcha") + ":</b>")
			hbox.pack_start(label, False, False, 10)
			label = gtk.Label(config.get(section, service_config.OPTION_CAPTCHA))
			hbox.pack_start(label, False)
			vbox.pack_start(hbox, False, False, 5)

class AccountPreferences(InfoPreferences):
	""""""
	def __init__(self, section, name, config, get_cookie):
		""""""
		InfoPreferences.__init__(self, section, name, config, True)

		self.get_cookie = get_cookie

		frame = gtk.Frame()
		frame.set_label_widget(gtk.image_new_from_file(media.ICON_ACCOUNT))
		frame.set_border_width(10)
		self.pack_start(frame, False, False, 1)
		scroll = gtk.ScrolledWindow()
		scroll.set_size_request(-1, 110)
		scroll.set_policy(gtk.POLICY_AUTOMATIC, gtk.POLICY_AUTOMATIC)
		frame.add(scroll)
		store = gtk.ListStore(gtk.gdk.Pixbuf, str, str, bool, bool, str)
		self.treeview = gtk.TreeView(store)
		scroll.add(self.treeview)

		self.treeview.set_rules_hint(True)
		#self.treeview.set_headers_visible(False)

		tree_icon = gtk.TreeViewColumn('Active') 
		icon_cell = gtk.CellRendererPixbuf()
		icon_cell.set_property("width", 50)
		tree_icon.pack_start(icon_cell, True)
		tree_icon.add_attribute(icon_cell, 'pixbuf', 0)
		self.treeview.append_column(tree_icon)

		tree_name = gtk.TreeViewColumn('User Name') 
		name_cell = gtk.CellRendererText()
		name_cell.set_property("width", 120)
		name_cell.set_property("editable", True)
		name_cell.connect("edited", self.change, 1)
		tree_name.pack_start(name_cell, True)
		tree_name.add_attribute(name_cell, 'text', 1)
		self.treeview.append_column(tree_name)

		tree_pass = gtk.TreeViewColumn('Password') 
		pass_cell = gtk.CellRendererText()
		pass_cell.set_property("width", 120)
		pass_cell.set_property("editable", True)
		pass_cell.connect("edited", self.change, 2)
		pass_cell.connect("editing-started", self.show_password)
		tree_pass.pack_start(pass_cell, True)
		tree_pass.add_attribute(pass_cell, 'text', 5)
		self.treeview.append_column(tree_pass)

		tree_enable = gtk.TreeViewColumn('Enable')
		enable_cell = gtk.CellRendererToggle()
		enable_cell.connect("toggled", self.toggled)
		tree_enable.pack_start(enable_cell, False)
		tree_enable.add_attribute(enable_cell, 'visible', 4)
		tree_enable.add_attribute(enable_cell, 'active', 3)
		self.treeview.append_column(tree_enable)

		self.active_service_icon = self.treeview.render_icon(gtk.STOCK_YES, gtk.ICON_SIZE_LARGE_TOOLBAR)
		self.unactive_service_icon = self.treeview.render_icon(gtk.STOCK_NO, gtk.ICON_SIZE_LARGE_TOOLBAR)

		accounts = config.get_accounts(section)
		for name in accounts.keys():
			password, enabled, active = accounts[name]
			if active:
				icon = self.active_service_icon
			else:
				icon = self.unactive_service_icon
			store.append([icon, name, password, enabled, active, "".join(["*" for i in range(len(password))])])

		frame = gtk.Frame()
		frame.set_border_width(10)
		frame.set_shadow_type(gtk.SHADOW_NONE)
		self.pack_start(frame, False, False)
		bbox = gtk.HButtonBox()
		bbox.set_layout(gtk.BUTTONBOX_EDGE)
		frame.add(bbox)
		button = gtk.Button(None, gtk.STOCK_ADD)
		button.connect("clicked", self.add)
		bbox.pack_start(button)
		button = gtk.Button(None, gtk.STOCK_REMOVE)
		button.connect("clicked", self.remove)
		bbox.pack_start(button)
		aspect = gtk.AspectFrame()
		aspect.set_shadow_type(gtk.SHADOW_NONE)
		bbox.pack_start(aspect)
		button = gtk.Button(None, gtk.STOCK_CONNECT)
		button.connect("clicked", self.check)
		bbox.pack_start(button)

	def show_password(self, cellrenderertext, editable, path):
		""""""
		model = self.treeview.get_model()
		editable.props.text = model.get_value(model.get_iter(path), 2)

	def change(self, cellrenderertext, path, new_text, column):
		""""""
		model = self.treeview.get_model()
		model.set_value(model.get_iter(path), column, new_text)
		if column == 2:
			model.set_value(model.get_iter(path), 5, "".join(["*" for i in range(len(new_text))]))		

	def add(self, button):
		""""""
		model = self.treeview.get_model()
		iter = model.append([self.unactive_service_icon, "", "", False, False, ""])
		self.treeview.set_cursor(model.get_path(iter), self.treeview.get_column(1), True)

	def remove(self, button):
		""""""
		model, iter = self.treeview.get_selection().get_selected()
		if iter:
			next_iter = model.iter_next(iter)
			model.remove(iter)
			if next_iter:
				self.treeview.set_cursor_on_cell(model.get_path(next_iter))

	def check(self, button):
		""""""
		model, iter = self.treeview.get_selection().get_selected()
		if iter:
			cookie = self.get_cookie(model.get_value(iter, 1), model.get_value(iter, 2))
			if cookie:
				icon = self.active_service_icon
				active = True
			else:
				icon = self.unactive_service_icon
				active = False
			model.set_value(iter, 0, icon)
			model.set_value(iter, 3, active)
			model.set_value(iter, 4, active)

	def toggled(self, button, path):
		""""""
		model = self.treeview.get_model()
		if button.get_active():
			active = False
		else:
			active = True
		button.set_active(active)
		model.set_value(model.get_iter(path), 3, active)

	def get_accounts(self):
		""""""
		model = self.treeview.get_model()
		iter = model.get_iter_root()
		accounts = {}
		while iter:
			accounts[model.get_value(iter, 1)] = (model.get_value(iter, 2), model.get_value(iter, 3), model.get_value(iter, 4))
			iter = model.iter_next(iter)
		return accounts

class ServicePreferences(gtk.Dialog):
	""""""
	def __init__(self, parent, service, icon, config):
		""""""
		gtk.Dialog.__init__(self)
		self.set_icon(icon)
		self.set_title(service)
		self.set_transient_for(parent)
		self.set_size_request(600, 400)

		self.config = config

		hbox = gtk.HBox()
		self.vbox.pack_start(hbox, True, True, 5)
		frame = gtk.Frame()
		hbox.pack_start(frame, False, False, 10)

		store = gtk.TreeStore(str, str, int)
		self.treeview = gtk.TreeView(store)
		self.treeview.get_selection().connect("changed", self.select)
		frame.add(self.treeview)

		self.treeview.set_headers_visible(False)

		tree_name = gtk.TreeViewColumn('Name')
		name_cell = gtk.CellRendererText()
		name_cell.set_property("width", 100)
		tree_name.pack_start(name_cell, True)
		tree_name.add_attribute(name_cell, 'text', 1)
		self.treeview.append_column(tree_name)

		self.notebook = gtk.Notebook()
		hbox.pack_start(self.notebook, True, True, 10)
		self.notebook.set_show_tabs(False)

		cont = 0
		plugin_list = []
		plugins = self.config.get_download_plugins()
		if plugins:
			plugin_list.append(("Download", plugins))
		plugins = self.config.get_upload_plugins()
		if plugins:
			plugin_list.append(("Upload", plugins))
		for item, plugins in plugin_list:
			iter = store.append(None, [None, item, -1])
			for section, section_name, section_type in plugins:
				page = gtk.VBox()
				if section_type == cons.TYPE_ANONYMOUS:
					page = InfoPreferences(section, section_name, self.config)
				else:
					if section_type == cons.TYPE_USER:
						module, name = config.user_cookie()
					elif section_type == cons.TYPE_PREMIUM:
						module, name = config.premium_cookie()
					if name:
						module = __import__(service.split(".")[0] + "." + module, None, None, [''])
						get_cookie = eval("module" + "." + name + "()").get_cookie
					page = AccountPreferences(section, section_name, self.config, get_cookie)
				self.notebook.append_page(page, None)
				subiter = store.append(iter, [section, section_type, cont])
				self.treeview.expand_to_path(store.get_path(subiter))
				if cont == 0:
					self.treeview.set_cursor_on_cell(store.get_path(subiter))
				cont += 1
		#action area
		cancel_button = gtk.Button(None, gtk.STOCK_CANCEL)
		save_button = gtk.Button(None, gtk.STOCK_SAVE)
		self.action_area.pack_start(cancel_button)
		self.action_area.pack_start(save_button)
		cancel_button.connect("clicked", self.close)
		save_button.connect("clicked", self.save)

		self.connect("response", self.close)
		self.show_all()
		self.run()

	def select(self, selection):
		""""""
		model, iter = selection.get_selected()
		if iter:
			child_iter = model.iter_children(iter)
			if child_iter:
				selection.select_iter(child_iter)
			else:
				self.notebook.set_current_page(model.get_value(iter, 2))

	def save(self, button):
		""""""
		model = self.treeview.get_model()
		iter = model.get_iter_root()
		while iter:
			child_iter = model.iter_children(iter)
			while child_iter:
				page = self.notebook.get_nth_page((model.get_value(iter, 2)))
				if ((page) and (model.get_value(child_iter, 1) != cons.TYPE_ANONYMOUS)):
					self.config.set_accounts(model.get_value(child_iter, 0), page.get_accounts())
				child_iter = model.iter_next(child_iter)
			iter = model.iter_next(iter)
		self.close()

	def close(self, widget=None, other=None):
		""""""
		self.destroy()

if __name__ == "__main__":
	x = ServicePreferences("rapidshare.com", gtk.gdk.pixbuf_new_from_file(media.ICON_MISSING), service_config.ServiceConfig("/home/crak/.tucan/plugins/megaupload/"))
