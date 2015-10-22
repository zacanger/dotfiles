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

import __builtin__
import logging
logger = logging.getLogger(__name__)

import pygtk
pygtk.require('2.0')
import gtk
import gobject
import pango

from service_preferences import ServicePreferences
from message import Message
from file_chooser import FileChooser
from update_manager import UpdateManager

import core.config as config
import core.url_open as url_open
import core.service_config as service_config

import media
import core.cons as cons

LANGUAGES = [	("Czech", "cs"),
		("English", "en"),
		("French", "fr"),
		("German", "de"),
		("Greek","gr"),
		("Italian", "it"),
		("Polish", "pl"),
		("Portuguese", "pt"),
		("Russian", "ru"),
		("Slovak", "sk"),
		("Spanish", "es"),
		("Swedish","se")]

class Preferences(gtk.Dialog):
	""""""
	def __init__(self, parent, configuration, show_services=False, remote_info=None):
		""""""
		gtk.Dialog.__init__(self)
		self.set_transient_for(parent)
		self.set_icon_from_file(media.ICON_PREFERENCES)
		self.set_title("%s - Preferences" % cons.TUCAN_NAME)
		self.set_position(gtk.WIN_POS_CENTER)
		self.set_size_request(500,500)

		self.config = configuration

		self.notebook = gtk.Notebook()
		self.notebook.set_property("homogeneous", True)
		self.vbox.pack_start(self.notebook)
		self.new_page(_("General Configuration"), media.ICON_PREFERENCES_MAIN, self.init_main())
		self.new_page(_("Service Configuration"), media.ICON_PREFERENCES_SERVICES, self.init_services())
		self.new_page(_("Advanced Configuration"), media.ICON_PREFERENCES_ADVANCED, self.init_advanced())

		#action area
		cancel_button = gtk.Button(None, gtk.STOCK_CANCEL)
		save_button = gtk.Button(None, gtk.STOCK_SAVE)
		self.action_area.pack_start(cancel_button)
		self.action_area.pack_start(save_button)
		cancel_button.connect("clicked", self.close)
		save_button.connect("clicked", self.save)

		self.connect("response", self.close)
		self.show_all()

		if show_services:
			self.notebook.set_current_page(1)
		if remote_info:
			gobject.idle_add(self.update_manager, None, remote_info)
		self.run()

	def save(self, button):
		""""""
		self.config.set(config.SECTION_MAIN, config.OPTION_LANGUAGE, [lang[1] for lang in LANGUAGES][self.language.get_active()])

		#live changes
		self.config.set(config.SECTION_MAIN, config.OPTION_MAX_DOWNLOADS, str(self.max_downloads.get_value_as_int()))
		__builtin__.max_downloads = self.max_downloads.get_value_as_int()
		self.config.set(config.SECTION_MAIN, config.OPTION_MAX_DOWNLOAD_SPEED, str(self.max_download_speed.get_value_as_int()))
		__builtin__.max_download_speed = self.max_download_speed.get_value_as_int()

		#self.config.set(config.SECTION_MAIN, config.OPTION_MAX_UPLOADS, str(self.max_uploads.get_value_as_int()))
		self.config.set_downloads_folder(self.downloads_folder.get_label())

		model = self.treeview.get_model()
		iter = model.get_iter_root()
		while iter:
			configuration = model.get_value(iter, 3)
			configuration.enable(model.get_value(iter, 2))
			if not self.config.has_option(config.SECTION_SERVICES, model.get_value(iter,1)):
				self.config.set(config.SECTION_SERVICES, model.get_value(iter,1), configuration.path)
			iter = model.iter_next(iter)

		self.config.set(config.SECTION_ADVANCED, config.OPTION_TRAY_CLOSE, str(self.tray_close.get_active()))
		self.config.set(config.SECTION_ADVANCED, config.OPTION_ADVANCED_PACKAGES, str(self.advanced_packages.get_active()))
		self.config.set(config.SECTION_ADVANCED, config.OPTION_SAVE_SESSION, str(self.save_session.get_active()))
		self.config.set(config.SECTION_ADVANCED, config.OPTION_AUTO_UPDATE, str(self.auto_update.get_active()))
		self.config.set(config.SECTION_ADVANCED, config.OPTION_SHOW_UPLOADS, str(self.show_uploads.get_active()))
		self.config.set(config.SECTION_ADVANCED, config.OPTION_ENABLE_PROXY, str(self.enable_proxy.get_active()))
		self.config.set(config.SECTION_ADVANCED, config.OPTION_PROXY_URL, self.proxy_url.get_text())
		self.config.set(config.SECTION_ADVANCED, config.OPTION_PROXY_PORT, str(self.proxy_port.get_value_as_int()))

		#change proxy settings
		if self.enable_proxy.get_active():
			proxy_url, proxy_port = self.config.get_proxy()
			url_open.set_proxy(proxy_url, proxy_port)
		else:
			url_open.set_proxy(None)

		self.config.save()
		self.close()

	def new_page(self, tab_name, tab_image, page):
		""""""
		vbox = gtk.VBox()
		vbox.pack_start(gtk.image_new_from_file(tab_image))
		vbox.pack_start(gtk.Label(tab_name))
		vbox.show_all()
		self.notebook.append_page(page, vbox)
		self.notebook.set_tab_label_packing(page, True, True, gtk.PACK_START)

	def init_main(self):
		""""""
		vbox = gtk.VBox()

		frame = gtk.Frame()
		frame.set_label_widget(gtk.image_new_from_file(media.ICON_LANGUAGE))
		frame.set_border_width(5)
		vbox.pack_start(frame, False, False)
		hbox = gtk.HBox()
		vbox1 = gtk.VBox()
		frame.add(vbox1)
		hbox = gtk.HBox()
		vbox1.pack_start(hbox, False, False, 5)
		label = gtk.Label(_("Choose language: "))
		hbox.pack_start(label, False, False, 10)
		aspect = gtk.AspectFrame()
		aspect.set_shadow_type(gtk.SHADOW_NONE)
		hbox.pack_start(aspect)
		self.language = gtk.combo_box_new_text()
		for lang in [lang[0] for lang in LANGUAGES]:
			self.language.append_text(lang)
		self.language.set_active([lang[1] for lang in LANGUAGES].index(self.config.get(config.SECTION_MAIN, config.OPTION_LANGUAGE)))
		hbox.pack_start(self.language, False, False, 10)

		frame = gtk.Frame()
		frame.set_label_widget(gtk.image_new_from_file(media.ICON_NETWORK))
		frame.set_border_width(5)
		vbox.pack_start(frame, False, False)
		vbox1 = gtk.VBox()
		frame.add(vbox1)
		hbox = gtk.HBox()
		label = gtk.Label(_("Max simultaneous downloads: "))
		hbox.pack_start(label, False, False, 10)
		aspect = gtk.AspectFrame()
		aspect.set_shadow_type(gtk.SHADOW_NONE)
		hbox.pack_start(aspect)
		self.max_downloads = gtk.SpinButton(None, 1, 0)
		self.max_downloads.set_range(1,20)
		self.max_downloads.set_increments(1,0)
		self.max_downloads.set_numeric(True)
		self.max_downloads.set_value(self.config.getint(config.SECTION_MAIN, config.OPTION_MAX_DOWNLOADS))
		hbox.pack_start(self.max_downloads, False, False, 10)
		vbox1.pack_start(hbox, False, False, 2)
		hbox = gtk.HBox()
		label = gtk.Label(_("Max download speed: "))
		hbox.pack_start(label, False, False, 10)
		aspect = gtk.AspectFrame()
		aspect.set_shadow_type(gtk.SHADOW_NONE)
		hbox.pack_start(aspect)
		self.max_download_speed = gtk.SpinButton(None, 4, 0)
		self.max_download_speed.set_range(0,5000)
		self.max_download_speed.set_increments(4,0)
		self.max_download_speed.set_numeric(True)
		self.max_download_speed.set_value(self.config.getint(config.SECTION_MAIN, config.OPTION_MAX_DOWNLOAD_SPEED))
		hbox.pack_start(self.max_download_speed, False, False, 10)
		vbox1.pack_start(hbox, False, False, 2)
		#hbox = gtk.HBox()
		#label = gtk.Label(_("Max simultaneous uploads: "))
		#hbox.pack_start(label, False, False, 10)
		#aspect = gtk.AspectFrame()
		#aspect.set_shadow_type(gtk.SHADOW_NONE)
		#hbox.pack_start(aspect)
		#self.max_uploads = gtk.SpinButton(None, 1, 0)
		#self.max_uploads.set_range(1,10)
		#self.max_uploads.set_increments(1,0)
		#self.max_uploads.set_numeric(True)
		#self.max_uploads.set_value(self.config.getint(config.SECTION_MAIN, config.OPTION_MAX_UPLOADS))
		#hbox.pack_start(self.max_uploads, False, False, 10)
		#vbox1.pack_start(hbox, False, False, 2)

		frame = gtk.Frame()
		frame.set_label_widget(gtk.image_new_from_file(media.ICON_FOLDER))
		frame.set_border_width(5)
		vbox.pack_start(frame, False, False)
		vbox1 = gtk.VBox()
		frame.add(vbox1)
		hbox = gtk.HBox()
		vbox1.pack_start(hbox, False, False, 5)

		label = gtk.Label(_("Downloads Folder: "))
		hbox.pack_start(label, False, False, 10)
		path = self.config.get_downloads_folder()
		self.downloads_folder = gtk.Label(path)
		self.downloads_folder.set_width_chars(30)
		self.downloads_folder.set_alignment(0, 0.5)
		self.downloads_folder.set_ellipsize(pango.ELLIPSIZE_START)
		hbox.pack_start(self.downloads_folder, False, False, 10)
		bbox = gtk.HButtonBox()
		bbox.set_layout(gtk.BUTTONBOX_END)
		hbox.pack_start(bbox, True, True, 10)
		button = gtk.Button(None, gtk.STOCK_OPEN)
		button.connect("clicked", self.choose_path)
		bbox.pack_start(button)

		vbox.show_all()
		return vbox

	def choose_path(self, button):
		""""""
		FileChooser(self, self.downloads_folder.set_label, self.downloads_folder.get_label())

	def init_services(self):
		""""""
		vbox = gtk.VBox()

		frame = gtk.Frame()
		frame.set_size_request(-1, 300)
		vbox.pack_start(frame)
		frame.set_border_width(10)
		scroll = gtk.ScrolledWindow()
		frame.add(scroll)
		scroll.set_policy(gtk.POLICY_AUTOMATIC, gtk.POLICY_AUTOMATIC)
		store = gtk.ListStore(gtk.gdk.Pixbuf, str, bool, gobject.TYPE_PYOBJECT)
		self.treeview = gtk.TreeView(store)
		scroll.add(self.treeview)
		self.treeview.connect("row-activated", self.service_preferences)

		self.treeview.set_rules_hint(True)
		#self.treeview.set_headers_visible(False)

		tree_icon = gtk.TreeViewColumn('Icon') 
		icon_cell = gtk.CellRendererPixbuf()
		icon_cell.set_property("width", 50)
		tree_icon.pack_start(icon_cell, False)
		tree_icon.add_attribute(icon_cell, 'pixbuf', 0)
		self.treeview.append_column(tree_icon)

		tree_name = gtk.TreeViewColumn('Name')
		name_cell = gtk.CellRendererText()
		name_cell.set_property("width", 300)
		name_cell.set_property("xalign", 0.1)
		tree_name.pack_start(name_cell, True)
		tree_name.add_attribute(name_cell, 'text', 1)
		self.treeview.append_column(tree_name)

		tree_enable = gtk.TreeViewColumn('Enabled')
		enable_cell = gtk.CellRendererToggle()
		enable_cell.connect("toggled", self.toggled)
		tree_enable.pack_start(enable_cell, True)
		tree_enable.add_attribute(enable_cell, 'active', 2)
		self.treeview.append_column(tree_enable)

		#fill store
		for path, icon_path, name, enabled, configuration in self.config.get_services():
			self.add_service(path, icon_path, name, enabled, configuration)

		frame = gtk.Frame()
		frame.set_border_width(10)
		frame.set_shadow_type(gtk.SHADOW_NONE)
		vbox.pack_start(frame, False, False)
		bbox = gtk.HButtonBox()
		bbox.set_layout(gtk.BUTTONBOX_EDGE)
		frame.add(bbox)
		button = gtk.Button(None, gtk.STOCK_FIND)
		button.connect("clicked", self.update_manager)
		bbox.pack_start(button)
		button = gtk.Button(None, gtk.STOCK_REMOVE)
		button.connect("clicked", self.delete_service)
		bbox.pack_start(button)
		aspect = gtk.AspectFrame()
		aspect.set_shadow_type(gtk.SHADOW_NONE)
		bbox.pack_start(aspect)
		button = gtk.Button(None, gtk.STOCK_INFO)
		button.connect("clicked", self.service_info)
		bbox.pack_start(button)

		hbox = gtk.HBox()
		vbox.pack_start(hbox, False, False, 5)
		label = gtk.Label()
		hbox.pack_start(label, False, False, 10)
		label.set_markup("<i>* " + _("Restart Tucan to apply service changes.") + "</i>")

		return vbox

	def service_info(self, button):
		""""""
		model, iter = self.treeview.get_selection().get_selected()
		if iter:
			self.service_preferences(None, model.get_path(iter))

	def add_service(self, path, icon_path, name, enabled, configuration):
		""""""
		if configuration:
			try:
				icon = gtk.gdk.pixbuf_new_from_file_at_size(icon_path, 32, 32)
			except Exception:
				icon = gtk.gdk.pixbuf_new_from_file_at_size(media.ICON_MISSING, 32, 32)
				logger.info("Could not load: %s" % icon_path)
			self.treeview.get_model().append((icon, name, enabled, configuration))
		else:
			Message(self, cons.SEVERITY_ERROR, path , _("Service not configured."))

	def update_manager(self, button=None, remote_info=None):
		""""""
		UpdateManager(self, self.config, remote_info)
		self.treeview.get_model().clear()
		for path, icon_path, name, enabled, configuration in self.config.get_services():
			self.add_service(path, icon_path, name, enabled, configuration)

	def delete_service(self, button):
		""""""
		model, iter = self.treeview.get_selection().get_selected()
		if iter:
			next_iter = model.iter_next(iter)
			self.config.remove_option(config.SECTION_SERVICES, model.get_value(iter, 1))
			model.remove(iter)
			if next_iter:
				self.treeview.set_cursor_on_cell(model.get_path(next_iter))

	def toggled(self, button, path):
		""""""
		model = self.treeview.get_model()
		if button.get_active():
			active = False
		else:
			tos = _("Before using this service, you must accept it's terms of service at ") + model.get_value(model.get_iter(path), 1)
			m = Message(self, cons.SEVERITY_INFO, _("Tucan Manager - Terms of service"), tos, True)
			active = m.accepted
		button.set_active(active)
		model.set_value(model.get_iter(path), 2, active)

	def service_preferences(self, treeview, path, view_column=None):
		""""""
		model = self.treeview.get_model()
		icon = model.get_value(model.get_iter(path), 0)
		name = model.get_value(model.get_iter(path), 1)
		config = model.get_value(model.get_iter(path), 3)
		ServicePreferences(self, name, icon, config)

	def init_advanced(self):
		""""""
		frame = gtk.Frame()
		frame.set_label_widget(gtk.image_new_from_file(media.ICON_ADVANCED))
		frame.set_border_width(10)
		hbox = gtk.HBox()
		frame.add(hbox)
		vbox = gtk.VBox()
		hbox.pack_start(vbox, True, True, 10)

		self.tray_close = gtk.CheckButton(_("Close to tray."))
		vbox.pack_start(self.tray_close, False, False, 5)
		self.tray_close.set_active(self.config.getboolean(config.SECTION_ADVANCED, config.OPTION_TRAY_CLOSE))

		self.save_session = gtk.CheckButton(_("Save session on close."))
		vbox.pack_start(self.save_session, False, False, 5)
		self.save_session.set_active(self.config.getboolean(config.SECTION_ADVANCED, config.OPTION_SAVE_SESSION))

		self.advanced_packages = gtk.CheckButton(_("Default advanced packages."))
		vbox.pack_start(self.advanced_packages, False, False, 5)
		self.advanced_packages.set_active(self.config.getboolean(config.SECTION_ADVANCED, config.OPTION_ADVANCED_PACKAGES))

		self.auto_update = gtk.CheckButton(_("Automatic check for updates."))
		vbox.pack_start(self.auto_update, False, False, 5)
		self.auto_update.set_active(self.config.getboolean(config.SECTION_ADVANCED, config.OPTION_AUTO_UPDATE))

		self.show_uploads = gtk.CheckButton(_("Show uploads."))
		vbox.pack_start(self.show_uploads, False, False, 5)
		self.show_uploads.set_active(self.config.getboolean(config.SECTION_ADVANCED, config.OPTION_SHOW_UPLOADS))

		self.enable_proxy = gtk.CheckButton(_("Enable proxy:"))
		vbox.pack_start(self.enable_proxy, False, False, 5)
		self.enable_proxy.set_active(self.config.getboolean(config.SECTION_ADVANCED, config.OPTION_ENABLE_PROXY))
		self.enable_proxy.connect("toggled", self.change_state)

		self.proxy_box = gtk.HBox()
		vbox.pack_start(self.proxy_box, False, False, 5)
		self.proxy_box.pack_start(gtk.Label("HTTP Proxy:"), False, False, 5)
		self.proxy_url = gtk.Entry()
		self.proxy_box.pack_start(self.proxy_url, True, True, 5)
		self.proxy_url.set_text(self.config.get(config.SECTION_ADVANCED, config.OPTION_PROXY_URL))

		self.proxy_box.pack_start(gtk.Label("Port:"), False, False, 5)
		self.proxy_port = gtk.SpinButton(None, 1, 0)
		self.proxy_box.pack_start(self.proxy_port, False, False, 5)
		self.proxy_port.set_range(0,65535)
		self.proxy_port.set_increments(1,0)
		self.proxy_port.set_numeric(True)
		self.proxy_port.set_value(self.config.getint(config.SECTION_ADVANCED, config.OPTION_PROXY_PORT))

		self.change_state()

		return frame

	def change_state(self, button=None):
		""""""
		self.proxy_box.set_sensitive(self.enable_proxy.get_active())

	def close(self, widget=None, other=None):
		""""""
		enabled_services = 0
		model = self.treeview.get_model()
		iter = model.get_iter_root()
		while iter:
			if model.get_value(iter, 3).getboolean(service_config.SECTION_MAIN, service_config.OPTION_ENABLED):
				enabled_services += 1
			iter = model.iter_next(iter)
		if enabled_services > 0:
			self.destroy()
		else:
			Message(self, cons.SEVERITY_WARNING, _("Tucan Manager - No services enabled!") , _("Enable some services and restart Tucan."))
			self.run()
