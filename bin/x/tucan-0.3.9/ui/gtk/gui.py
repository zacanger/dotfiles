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
import sys
import time
import threading
import webbrowser
import __builtin__
import gettext
import logging
logger = logging.getLogger(__name__)

import pygtk
pygtk.require('2.0')
import gtk
import gobject

import tray_icon
import menu_bar
import toolbar

from about import About
from message import Message
from preferences import Preferences
from log_view import LogView
from shutdown import Shutdown
from tree import Tree
from input_links import InputLinks
from file_chooser import FileChooser

from core.core import Core
from core.sessions import Sessions
from core.log_stream import LogStream
from core.service_update import ServiceUpdate

import media
import core.cons as cons
import core.config as config

class Gui(gtk.Window, Core):
	""""""
	def __init__(self, conf):
		""""""
		#i18n
		gettext.bindtextdomain(cons.NAME_LOCALES, cons.PATH_LOCALES)
		gettext.textdomain(cons.NAME_LOCALES)
		__builtin__._ = gettext.gettext

		#configuration
		self.configuration = conf
		
		#set logger
		log_stream = LogStream()
		handler = logging.StreamHandler(log_stream)
		handler.setLevel(logging.DEBUG)
		handler.setFormatter(logging.Formatter(cons.LOG_FORMAT))
		logging.getLogger("").addHandler(handler)		

		#show preferences if not configured
		if not self.configuration.configured:
			Preferences(self, self.configuration, True)
		self.preferences_shown =  False

		#l10n
		lang = gettext.translation(cons.NAME_LOCALES, cons.PATH_LOCALES, languages=[self.configuration.get(config.SECTION_MAIN, config.OPTION_LANGUAGE)])
		lang.install()

		Core.__init__(self, self.configuration)
		gtk.Window.__init__(self, gtk.WINDOW_TOPLEVEL)

		self.set_icon_from_file(media.ICON_TUCAN)
		self.set_title("%s - Version: %s" % (cons.TUCAN_NAME, cons.TUCAN_VERSION))
		self.set_position(gtk.WIN_POS_CENTER)
		self.set_size_request(900, 500)
		self.vbox = gtk.VBox()
		self.add(self.vbox)

		#menu items
		menu_load_session = _("Load Session"), lambda x: FileChooser(self, self.load_session, cons.CONFIG_PATH, True)
		menu_save_session = _("Save Session"), lambda x: FileChooser(self, self.save_session, cons.CONFIG_PATH, save=True)
		menu_quit = gtk.STOCK_QUIT, self.quit
		menu_help = gtk.STOCK_HELP, self.help
		menu_about = gtk.STOCK_ABOUT, lambda x: About(self)
		menu_preferences = gtk.STOCK_PREFERENCES, self.preferences
		menu_log = _("Show Logs"), lambda x: LogView(self, log_stream)
		show_uploads = gtk.CheckMenuItem(_("Show Uploads")), self.resize_pane, self.configuration.getboolean(config.SECTION_ADVANCED, config.OPTION_SHOW_UPLOADS)
		shutdown = gtk.CheckMenuItem(_("Shutdown Computer")), self.shutdown, False
		
		m_file = _("File")
		m_view = _("View")
		m_help = _("Help")
		m_addons = _("Addons")
		
		#integration menubar
		integration = None
		if cons.OS_OSX:
			try:				
				about_menu = _("About TucanManager"), lambda x: About(self)
				preferences_menu = _("Preferences"), self.preferences
				file_menu = m_file, [menu_load_session, menu_save_session]
				view_menu = m_view, [show_uploads, None, menu_log]
				addons_menu = m_addons, [shutdown]
				help_menu = m_help, [menu_help]
				quit_menu = _("Quit"), self.quit
				integration = gtk.Window(gtk.WINDOW_POPUP)
				vbox = gtk.VBox()
				integration.add(vbox)
				vbox.pack_start(menu_bar.OSXMenuBar([file_menu, view_menu, addons_menu, help_menu], about_menu, preferences_menu, quit_menu))
				
			except Exception, e:
				integration = None
				logger.critical("No OSX menu integration support.")

		#normal menubar
		if not integration:
			file_menu = m_file, [menu_load_session, menu_save_session, None, menu_quit]
			view_menu = m_view, [show_uploads, menu_log, None, menu_preferences]
			addons_menu = m_addons, [shutdown]
			help_menu = m_help, [menu_help, menu_about]
			self.vbox.pack_start(menu_bar.MenuBar([file_menu, view_menu, addons_menu, help_menu]), False)

		#toolbar
		download = _("Add Downloads"), gtk.image_new_from_file(media.ICON_DOWNLOAD), self.add_links
		upload = _("Add Uploads"), gtk.image_new_from_file(media.ICON_UPLOAD), self.not_implemented #self.quit
		clear = _("Clear Complete"), gtk.image_new_from_file(media.ICON_CLEAR), self.clear_complete
		up = _("Move Up"), gtk.image_new_from_file(media.ICON_UP), self.move_up
		down = _("Move Down"), gtk.image_new_from_file(media.ICON_DOWN), self.move_down
		start = _("Start Selected"), gtk.image_new_from_file(media.ICON_START), self.start
		stop = _("Stop Selected"), gtk.image_new_from_file(media.ICON_STOP), self.stop
		self.vbox.pack_start(toolbar.Toolbar([download, upload, None, clear, None, up, down, None, start, stop]), False)

		copy = gtk.STOCK_COPY, self.copy_clipboard
		delete = gtk.STOCK_REMOVE, self.delete
		start = gtk.STOCK_MEDIA_PLAY, self.start
		stop = gtk.STOCK_MEDIA_STOP, self.stop

		#trees
		self.downloads = Tree([copy, None, delete], self.download_manager)
		#self.uploads = Tree()
		self.uploads = gtk.VBox()
		
		#tray icon
		if cons.OS_OSX:
			try:
				#dock integration
				self.tray_icon = tray_icon.OSXDock(self.show, self.quit)
				self.connect("hide", self.tray_icon.activate, True)
			except Exception, e:
				logger.critical("No OSX dock integration support.")
				self.tray_icon = None
		else:
			#trayicon
			tray_menu = [menu_preferences, menu_about, None, menu_quit]
			self.tray_icon = tray_icon.TrayIcon(self.show, self.hide, tray_menu)
			self.connect("hide", self.tray_icon.activate)
			self.downloads.status_bar.connect("text-pushed", self.tray_icon.change_tooltip)		

		#sessions
		self.session = Sessions()
		if self.configuration.getboolean(config.SECTION_ADVANCED, config.OPTION_SAVE_SESSION):
			self.load_default_session()
		else:
			if os.path.exists(cons.SESSION_FILE):
				title = _("Tucan Manager - Restore previous session.")
				message = _("Your last session closed unexpectedly.\nTucan will try to restore it now.")
				m = Message(None, cons.SEVERITY_WARNING, title, message, both=True)
				if m.accepted:
					self.load_default_session()

		#pane
		self.pane = gtk.VPaned()
		self.vbox.pack_start(self.pane)
		self.pane.pack1(self.downloads, True)
		self.pane.pack2(self.uploads, True)
		self.pane.set_position(self.get_size()[1])

		self.connect("key-press-event", self.delete_key)

		if self.configuration.getboolean(config.SECTION_ADVANCED, config.OPTION_TRAY_CLOSE):
			self.connect("delete_event", self.hide_on_delete)
		else:
			self.connect("delete_event", self.quit)

		self.show_all()

		#Autocheck services
		if self.configuration.getboolean(config.SECTION_ADVANCED, config.OPTION_AUTO_UPDATE):
			th = threading.Thread(group=None, target=self.check_updates, name=None)
			th.start()

		#ugly polling
		gobject.timeout_add(120000, self.save_default_session)

	def check_updates(self):
		""""""
		s = ServiceUpdate(self.configuration)
		if s.get_updates():
			gobject.idle_add(self.update_manager, s.remote_info)

	def update_manager(self, info):
		""""""
		if not self.preferences_shown:
			self.preferences_shown = True
			Preferences(self, self.configuration, True, info)
			self.preferences_shown =  False
		return False

	def delete_key(self, window, event):
		"""pressed del key"""
		if event.keyval == 65535:
			self.delete()

	def preferences(self, button=None):
		""""""
		if not self.preferences_shown:
			self.preferences_shown = True
			Preferences(self, self.configuration)
			self.downloads.status_bar.synchronize()
			self.preferences_shown =  False

	def not_implemented(self, widget):
		""""""
		w = Message(self, cons.SEVERITY_WARNING, "Not Implemented!", "The functionality you are trying to use is not implemented yet.")

	def resize_pane(self, checkbox):
		""""""
		if checkbox.get_active():
			self.pane.set_position(-1)
		else:
			self.pane.set_position(self.get_size()[1])

	def shutdown(self, checkbox):
		""""""
		if checkbox.get_active():
			self.shutdown_id = events.connect(cons.EVENT_ALL_COMPLETE, Shutdown, self, self.quit)
		else:
			events.disconnect(cons.EVENT_ALL_COMPLETE, self.shutdown_id)

	def help(self, widget):
		""""""
		webbrowser.open(cons.DOC)

	def add_links(self, button):
		""""""
		default_path = self.configuration.get_downloads_folder()
		show_advanced_packages = self.configuration.getboolean(config.SECTION_ADVANCED, config.OPTION_ADVANCED_PACKAGES)
		InputLinks(self, default_path, self.filter_service, self.get_check_links, self.create_packages, self.manage_packages, show_advanced_packages)

	def copy_clipboard(self, button):
		""""""
		model, iter = self.downloads.treeview.get_selection().get_selected()
		if iter:
			link_list = self.downloads.get_links(iter)
			clipboard = gtk.Clipboard()
			clipboard.clear()
			clipboard.set_text("\n".join(link_list))

	def load_session(self, path):
		""""""
		try:
			packages, info = self.session.load_session(path)
			if packages != None:
				self.manage_packages(packages, info)
				logger.debug("Session loaded: %s" % info)
		except Exception, e:
			logger.exception("Session not loaded: %s" % e)
			gobject.idle_add(self.session_error)

	def session_error(self):
		""""""
		title = _("Tucan Manager - Session Error.")
		message = _("There was a problem loading the last session. Links are unrecoverable.")
		Message(self, cons.SEVERITY_ERROR, title, message)

	def save_session(self, path):
		""""""
		packages, info = self.downloads.get_packages()
		self.session.save_session(path, packages, info)
		logger.debug("Session saved: %s" % info)

	def load_default_session(self):
		""""""
		self.load_session(cons.SESSION_FILE)

	def save_default_session(self):
		""""""
		self.save_session(cons.SESSION_FILE)
		return True

	def manage_packages(self, packages, packages_info):
		""""""
		tmp_packages = []
		if not len(packages_info) > 0:
			default_path = self.configuration.get_downloads_folder()
			packages_info = [(default_path, name, None) for name, package_files in packages]
		#create directories and password files
		for info in packages_info:
			package_path = os.path.join(info[0].decode("utf-8"), info[1].replace(" ", "_"), "")
			if not os.path.exists(package_path):
				os.makedirs(package_path)
			if info[2]:
				f = open(package_path + "password.txt", "w")
				f.write(info[2] + "\n")
				f.close()
		#add packages to gui and manager
		for package_name, package_downloads in packages:
			info = packages_info[packages.index((package_name, package_downloads))]
			package_name = info[1].replace(" ", "_")
			package_path = os.path.join(info[0].decode("utf-8"), package_name, "")
			self.downloads.add_package(package_name, package_path, package_downloads, info[2])
			for download in package_downloads:
				tmp = []
				for service in download[2]:
					plugin, plugin_type = self.get_download_plugin(service)
					tmp.append((download[0][download[2].index(service)], plugin, plugin_type, service))
				self.download_manager.add(package_path, download[1], tmp, download[3], download[4])

	def start(self, button):
		"""Implementado solo para descargas"""
		model, paths = self.downloads.treeview.get_selection().get_selected_rows()
		if len(paths) > 0:
			if len(paths[0]) > 1:
				logger.info("Start file: %s" % self.download_manager.start(model.get_value(model.get_iter(paths[0]), 3)))
			else:
				logger.info("Start package.")
				for item in self.downloads.package_files(model.get_iter(paths[0])):
					self.download_manager.start(item)

	def stop(self, button):
		"""Implementado solo para descargas"""
		model, paths = self.downloads.treeview.get_selection().get_selected_rows()
		if len(paths) > 0:
			if len(paths[0]) > 1:
				logger.info("Stop file: %s" % self.download_manager.stop(model.get_value(model.get_iter(paths[0]), 3)))
			else:
				logger.info("Stop package.")
				for item in self.downloads.package_files(model.get_iter(paths[0])):
					self.download_manager.stop(item)

	def clear_complete(self, button):
		"""Implementado solo para descargas"""
		files = self.downloads.clear()
		logger.info("Cleared: %s" % files)
		if len(files) > 0:
			self.download_manager.clear(files)

	def move_up(self, button):
		"""Implementado solo para descargas"""
		model, paths = self.downloads.treeview.get_selection().get_selected_rows()
		if len(paths) > 0:
			if not len(paths[0]) > 1:
				logger.info("Move up: %s" % self.downloads.move_up(model.get_iter(paths[0])))

	def move_down(self, button):
		"""Implementado solo para descargas"""
		model, paths = self.downloads.treeview.get_selection().get_selected_rows()
		if len(paths) > 0:
			if not len(paths[0]) > 1:
				logger.info("Move down: %s" % self.downloads.move_down(model.get_iter(paths[0])))

	def delete(self, button=None):
		"""Implementado solo para descargas"""
		model, paths = self.downloads.treeview.get_selection().get_selected_rows()
		status = [cons.STATUS_STOP, cons.STATUS_PEND, cons.STATUS_ERROR]
		if len(paths) > 0:
			if len(paths[0]) > 2:
				name, link = self.downloads.delete_link(status, model.get_iter(paths[0]))
				if link:
					logger.warning("Remove %s: %s" % (link, self.download_manager.delete_link(name, link)))
			elif len(paths[0]) > 1:
				name = self.downloads.delete_file(status, model.get_iter(paths[0]))
				if name:
					logger.warning("Remove %s: %s" % (name, self.download_manager.clear([name])))
			else:
				files = self.downloads.delete_package(status, model.get_iter(paths[0]))
				if len(files) > 0:
					logger.warning("Remove package: %s" % self.download_manager.clear(files))

	def quit(self, dialog=None, response=None):
		""""""
		if len(self.download_manager.active_downloads) > 0:
			message = "Tucan still has active downloads.\n Are you sure you want to quit?"
			m = Message(self, cons.SEVERITY_WARNING, "Tucan Manager - Active Downloads.", message, True, True)
			if m.accepted:
				self.close()
			else:
				#This way GTK won't destroy the window.
				return True
		else:
			self.close()

	def close(self):
		""""""
		self.hide()
		if self.tray_icon:
			self.tray_icon.close()
		gtk.main_quit()

		if self.configuration.getboolean(config.SECTION_ADVANCED, config.OPTION_SAVE_SESSION):
			self.save_default_session()
		else:
			try:
				os.remove(cons.SESSION_FILE)
			except Exception, e:
				logger.info(e)
		self.stop_all()
		tucan_exit(0)
