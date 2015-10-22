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

import HTMLParser
import threading
import logging
logger = logging.getLogger(__name__)

import pygtk
pygtk.require('2.0')
import gtk
import gobject

from message import Wait, Message
from advanced_packages import AdvancedPackages

import media
import core.cons as cons

class ClipParser(HTMLParser.HTMLParser):
	""""""
	def __init__(self):
		""""""
		HTMLParser.HTMLParser.__init__(self)
		self.url = []

	def handle_starttag(self, tag, attrs):
		""""""
		if tag == "a":
			for ref, link in attrs:
				if ref == "href":
					self.url.append(link)

class InputLinks(gtk.Dialog):
	""""""
	def __init__(self, parent, path, sort, check, create, manage, show_advanced_packages):
		""""""
		gtk.Dialog.__init__(self)
		self.set_transient_for(parent)
		self.set_icon_from_file(media.ICON_DOWNLOAD)
		self.set_title("%s - %s" % (cons.TUCAN_NAME, _("Input Links")))
		self.set_position(gtk.WIN_POS_CENTER)
		self.set_size_request(600,500)

		self.cancel_check = False

		self.default_path = path
		self.sort_links = sort
		self.check_links = check
		self.create_packages = create
		self.packages = manage

		#textview
		frame = gtk.Frame(_("Paste links here:"))
		self.vbox.pack_start(frame)
		frame.set_border_width(10)
		hbox = gtk.HBox()
		frame.add(hbox)
		scroll = gtk.ScrolledWindow()
		hbox.pack_start(scroll, True, True, 10)
		scroll.set_policy(gtk.POLICY_NEVER, gtk.POLICY_AUTOMATIC)
		#auto scroll
		scroll.get_vadjustment().connect("changed", self.changed)
		scroll.get_vadjustment().connect("value-changed", self.value_changed)		
		buffer = gtk.TextBuffer()		
		self.textview = gtk.TextView(buffer)
		scroll.add(self.textview)
		self.textview.set_wrap_mode(gtk.WRAP_CHAR)

		self.clipboard = gtk.clipboard_get()
		self.clipboard.request_targets(self.get_clipboard)

		#check button
		button_box = gtk.HButtonBox()
		hbox.pack_start(button_box, False, False, 10)
		vbox = gtk.VBox()
		check_image = gtk.image_new_from_file(media.ICON_CHECK)
		vbox.pack_start(check_image)
		check_label = gtk.Label(_("Check Links"))
		vbox.pack_start(check_label)
		check_button = gtk.Button()
		check_button.add(vbox)
		button_box.pack_start(check_button)
		check_button.connect("clicked", self.check)

		#treeview
		frame = gtk.Frame()
		self.vbox.pack_start(frame)
		frame.set_border_width(10)
		scroll = gtk.ScrolledWindow()
		frame.add(scroll)
		scroll.set_policy(gtk.POLICY_AUTOMATIC, gtk.POLICY_AUTOMATIC)
		#auto scroll
		scroll.get_vadjustment().connect("changed", self.changed)
		scroll.get_vadjustment().connect("value-changed", self.value_changed)		

		self.treeview = gtk.TreeView(gtk.TreeStore(gtk.gdk.Pixbuf, str, str, int, str, str, bool, bool))
		scroll.add(self.treeview)

		self.treeview.set_rules_hint(True)
		self.treeview.set_headers_visible(False)

		tree_icon = gtk.TreeViewColumn('Icon') 
		icon_cell = gtk.CellRendererPixbuf()
		tree_icon.pack_start(icon_cell, True)
		tree_icon.add_attribute(icon_cell, 'pixbuf', 0)
		self.treeview.append_column(tree_icon)

		tree_name = gtk.TreeViewColumn('Name') 
		name_cell = gtk.CellRendererText()
		name_cell.connect("edited", self.change_name)
		tree_name.pack_start(name_cell, True)
		tree_name.add_attribute(name_cell, 'text', 2)
		tree_name.add_attribute(name_cell, 'editable', 7)
		self.treeview.append_column(tree_name)

		tree_add = gtk.TreeViewColumn('Add')
		add_cell = gtk.CellRendererToggle()
		add_cell.connect("toggled", self.toggled)
		tree_add.pack_start(add_cell, True)
		tree_add.add_attribute(add_cell, 'active', 6)
		tree_add.add_attribute(add_cell, 'visible', 7)
		self.treeview.append_column(tree_add)

		#advanced checkbutton
		hbox = gtk.HBox()
		self.vbox.pack_start(hbox, False)
		self.advanced_button = gtk.CheckButton(_("Show advanced Package configuration."))
		self.advanced_button.set_active(show_advanced_packages)
		hbox.pack_start(self.advanced_button, False, False, 8)

		#action area
		cancel_button = gtk.Button(None, gtk.STOCK_CANCEL)
		add_button = gtk.Button(None, gtk.STOCK_ADD)
		self.action_area.pack_start(cancel_button)
		self.action_area.pack_start(add_button)
		cancel_button.connect("clicked", self.close)
		add_button.connect("clicked", self.add_links)

		self.connect("response", self.close)
		self.show_all()
		self.run()

	def changed(self, vadjust):
		"""autoscroll"""
		if not hasattr(vadjust, "need_scroll") or vadjust.need_scroll:
			vadjust.set_value(vadjust.upper-vadjust.page_size)
			vadjust.need_scroll = True

	def value_changed (self, vadjust):
		"""autoscroll"""
		vadjust.need_scroll = abs(vadjust.value + vadjust.page_size - vadjust.upper) < vadjust.step_increment

	def change_name(self, cellrenderertext, path, new_text):
		""""""
		model = self.treeview.get_model()
		model.set_value(model.get_iter(path), 2, new_text)

	def get_clipboard(self, clipboard, selection_data, data):
		""""""
		urls = []
		if cons.OS_OSX:
			target_html = "public.rtf"
			if target_html  in list(selection_data):
				selection = self.clipboard.wait_for_contents(target_html)
				if selection:
					for line in str(selection.data.decode("utf8", "ignore")).split("\n"):
						if '{HYPERLINK "' in line:
							urls.append(line.split('{HYPERLINK "')[1].split('"}')[0])
		elif cons.OS_WINDOWS:
			target_html = "HTML Format"
			if target_html in list(selection_data):
				try:
					parser = ClipParser()
					parser.feed(self.clipboard.wait_for_contents(target_html).data.decode("utf8", "ignore"))
					parser.close()
					if len(parser.url) > 0:
						urls += parser.url
				except HTMLParser.HTMLParseError:
					pass
		else:
			target_html = "text/html"
			if target_html  in list(selection_data):
				for line in str(self.clipboard.wait_for_contents(target_html).data.decode("utf16", "ignore")).split("\n"):
					try:
						parser = ClipParser()
						parser.feed(line)
						parser.close()
						if len(parser.url) > 0:
							urls += parser.url
					except HTMLParser.HTMLParseError:
						pass
		if len(urls) > 0:
			self.textview.get_buffer().insert_at_cursor("\n".join(urls) + "\n")

	def toggled(self, button, path):
		""""""
		model = self.treeview.get_model()
		active = True
		if button.get_active():
			active = False
		button.set_active(active)
		model.set_value(model.get_iter(path), 6, active)

	def add_links(self, button):
		""""""
		tmp = {}
		store = self.treeview.get_model()
		for column in store:
			if column[2] != cons.TYPE_UNSUPPORTED:
				tmp[column[2]] = []
				for value in column.iterchildren():
					if value[1] != value[2]:
						if value[6]:
							logger.info("Added: %s %s %s %s %s" % (value[1], value[2], value[3], value[4], value[5]))
							tmp[column[2]].append((value[1], value[2], value[3], value[4], value[5]))
		if tmp != {}:
			packages = self.create_packages(tmp)
			packages_info = None
			if self.advanced_button.get_active():
				#self.hide()
				w = AdvancedPackages(self, self.default_path, packages)
				packages_info = w.packages_info
				if packages_info:
					self.packages(w.packages, packages_info)
					self.close()
				#else:
				#	self.show()
			else:
				self.packages(packages, [])
				self.close()
		else:		
			title = _("Input Links - Nothing to add.")
			message = _("There aren't links to add.\nPlease check the links before adding.")
			m = Message(self, cons.SEVERITY_INFO, title, message, both=True)
			if not m.accepted:
				self.close()

	def check(self, button):
		""""""
		buffer = self.textview.get_buffer()
		start, end = buffer.get_bounds()
		link_list = [link.lower() for link in buffer.get_text(start, end).split("\n") if link.strip()]
		if len(link_list) > 0:
			w = Wait(_("Checking links, please wait."), self)
			w.connect("key-press-event", self.cancel)
			th = threading.Thread(group=None, target=self.check_all, name=None, args=(link_list, w))
			th.start()

	def check_all(self, link_list, wait):
		""""""
		buffer = self.textview.get_buffer()
		store = self.treeview.get_model()
		store.clear()

		service_icon = self.treeview.render_icon(gtk.STOCK_INFO, gtk.ICON_SIZE_MENU)
		unsupported_icon = self.treeview.render_icon(gtk.STOCK_DIALOG_ERROR, gtk.ICON_SIZE_MENU)
		active_icon = self.treeview.render_icon(gtk.STOCK_APPLY, gtk.ICON_SIZE_MENU)
		unchecked_icon = self.treeview.render_icon(gtk.STOCK_DIALOG_WARNING, gtk.ICON_SIZE_MENU)
		unactive_icon = self.treeview.render_icon(gtk.STOCK_CANCEL, gtk.ICON_SIZE_MENU)
		try:
			for service, links in self.sort_links(link_list).items():
				if links != []:
					if service == cons.TYPE_UNSUPPORTED:
						service_iter = store.append(None, [unsupported_icon, service, service, 0, None, None, False, False])
						for link in links:
							store.append(service_iter, [unchecked_icon, link, link, 0, None, None, False, False])
					else:
						service_iter = store.append(None, [service_icon, service, service, 0, None, None, False, False])
						for link in links:
							if self.cancel_check:
								self.cancel_check = False
								raise Exception("Check Links cancelled")
							check, plugin_type = self.check_links(service) 
							file_name, size, size_unit = check(link)
							if file_name:
								if size > 0:
									icon = active_icon
									marked = True
								else:
									icon = unchecked_icon
									marked = False
							else:
								icon = unactive_icon
								marked = False
								file_name = link
							logger.info("Checked: %s %s %s" % (file_name, size, size_unit))
							store.append(service_iter, [icon, link, file_name, size, size_unit, plugin_type, marked, marked])
							self.treeview.expand_row(store.get_path(service_iter), True)
		except:
			gobject.idle_add(wait.destroy)
		else:
			buffer.set_text("")
			gobject.idle_add(wait.destroy)

	def cancel(self, window, event):
		"""Esc key"""
		if event.keyval == 65307:
			window.progress.set_text(_("Check Canceled!"))
			self.cancel_check = True

	def close(self, widget=None, other=None):
		""""""
		self.destroy()
