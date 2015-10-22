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
import pango

from statusbar import Statusbar

import core.cons as cons

class Tree(gtk.VBox):
	""""""
	def __init__(self, menu, manager):
		""""""
		gtk.VBox.__init__(self)
		scroll = gtk.ScrolledWindow()
		scroll.set_policy(gtk.POLICY_AUTOMATIC, gtk.POLICY_AUTOMATIC)
		self.treeview = gtk.TreeView(gtk.TreeStore(gtk.gdk.Pixbuf, str, str, str, int, bool, str, str, str, str, str))
		scroll.add(self.treeview)
		self.pack_start(scroll)

		self.menu = gtk.Menu()
		for item in menu:
			if item == None:
				subitem = gtk.SeparatorMenuItem()
			else:
				subitem = gtk.ImageMenuItem(item[0])
				subitem.connect("activate", item[1])
			self.menu.append(subitem)
		self.menu.show_all()
		self.treeview.connect("button-press-event", self.mouse_menu)

		self.get_files = manager.get_files

		self.treeview.set_rules_hint(True)
		self.treeview.set_headers_visible(False)

		#tree columns
		tree_icon = gtk.TreeViewColumn('Icon') 
		icon_cell = gtk.CellRendererPixbuf()
		tree_icon.pack_start(icon_cell, False)
		tree_icon.add_attribute(icon_cell, 'pixbuf', 0)
		self.treeview.append_column(tree_icon)

		tree_name = gtk.TreeViewColumn('Name')
		name_cell = gtk.CellRendererText()
		name_cell.set_property("width-chars", 60)
		name_cell.set_property("ellipsize", pango.ELLIPSIZE_MIDDLE)
		tree_name.pack_start(name_cell, True)
		tree_name.add_attribute(name_cell, 'text', 3)
		self.treeview.append_column(tree_name)

		tree_progress = gtk.TreeViewColumn('Progress')
		tree_progress.set_min_width(150)
		progress_cell = gtk.CellRendererProgress()
		tree_progress.pack_start(progress_cell, True)
		tree_progress.add_attribute(progress_cell, 'value', 4)
		tree_progress.add_attribute(progress_cell, 'visible', 5)
		self.treeview.append_column(tree_progress)

		tree_current_size = gtk.TreeViewColumn('Current Size')
		current_size_cell = gtk.CellRendererText()
		tree_current_size.pack_start(current_size_cell, False)
		tree_current_size.add_attribute(current_size_cell, 'text', 6)
		self.treeview.append_column(tree_current_size)

		tree_total_size = gtk.TreeViewColumn('Total Size')
		total_size_cell = gtk.CellRendererText()
		tree_total_size.pack_start(total_size_cell, False)
		tree_total_size.add_attribute(total_size_cell, 'text', 7)
		self.treeview.append_column(tree_total_size)

		tree_speed = gtk.TreeViewColumn('Speed')
		speed_cell = gtk.CellRendererText()
		tree_speed.pack_start(speed_cell, False)
		tree_speed.add_attribute(speed_cell, 'text', 8)
		self.treeview.append_column(tree_speed)

		tree_time = gtk.TreeViewColumn('Time Left')
		time_cell = gtk.CellRendererText()
		tree_time.pack_start(time_cell, False)
		tree_time.add_attribute(time_cell, 'text', 9)
		self.treeview.append_column(tree_time)

		tree_plugins = gtk.TreeViewColumn('Plugin')
		plugins_cell = gtk.CellRendererText()
		tree_plugins.pack_start(plugins_cell, False)
		tree_plugins.add_attribute(plugins_cell, 'text', 10)
		self.treeview.append_column(tree_plugins)

		#icons
		self.package_icon = self.treeview.render_icon(gtk.STOCK_OPEN, gtk.ICON_SIZE_MENU)
		self.active_service_icon = self.treeview.render_icon(gtk.STOCK_YES, gtk.ICON_SIZE_MENU)
		self.unactive_service_icon = self.treeview.render_icon(gtk.STOCK_NO, gtk.ICON_SIZE_MENU)
		self.correct_icon = self.treeview.render_icon(gtk.STOCK_APPLY, gtk.ICON_SIZE_MENU)
		self.failed_icon = self.treeview.render_icon(gtk.STOCK_CANCEL, gtk.ICON_SIZE_MENU)
		self.wait_icon = self.treeview.render_icon(gtk.STOCK_REFRESH, gtk.ICON_SIZE_MENU)
		self.active_icon = self.treeview.render_icon(gtk.STOCK_MEDIA_PLAY, gtk.ICON_SIZE_MENU)
		self.pending_icon = self.treeview.render_icon(gtk.STOCK_MEDIA_PAUSE, gtk.ICON_SIZE_MENU)
		self.stoped_icon = self.treeview.render_icon(gtk.STOCK_MEDIA_STOP, gtk.ICON_SIZE_MENU)
		self.icons = {cons.STATUS_CORRECT: self.correct_icon, cons.STATUS_ERROR: self.failed_icon, cons.STATUS_WAIT: self.wait_icon, cons.STATUS_ACTIVE: self.active_icon, cons.STATUS_PEND: self.pending_icon, cons.STATUS_STOP: self.stoped_icon}

		self.status_bar = Statusbar()
		self.pack_start(self.status_bar, False)
		self.status_bar.push(self.status_bar.get_context_id("Downloads"), " No Downloads Active.")
		self.updating = False

	def mouse_menu(self, widget, event):
		"""right button"""
		if event.button == 3:
			model, paths = self.treeview.get_selection().get_selected_rows()
			if len(paths) > 0:
				self.menu.popup(None, None, None, event.button, event.time)

	def add_package(self, package_name, package_path, package, password):
		"""
		TreeStore(icon, status, password, name, progress, progress_visible, current_size, total_size, speed, time, services)
		"""
		tmp_size = []
		model = self.treeview.get_model()
		package_iter = model.append(None, [self.package_icon, cons.STATUS_PEND, password, package_name, 0, True, None, None, None, None, package_path])
		for item in package:
			tmp_size.append((item[3], item[4]))
			item_iter = model.append(package_iter, [self.pending_icon, cons.STATUS_PEND, None, item[1], 0, True, None, str(item[3])+item[4], None, None, str(item[2])])
			self.treeview.expand_to_path(model.get_path(item_iter))
			for link in item[0]:
				link_iter = model.append(item_iter, [self.unactive_service_icon, cons.STATUS_PEND, None, link, 0, False, None, None, None, None, item[5][item[0].index(link)]])
		package_size, package_unit = self.normalize(tmp_size)
		model.set_value(package_iter, 7, str(package_size)+package_unit)
		if not self.updating:
			self.updating = True
			gobject.timeout_add(1000, self.update)
		return package_iter

	def update(self):
		"""(icon, status, None, name, progress, progress_visible, current_size, total_size, speed, time, services)"""
		files = self.get_files()
		if len(files) > 0:
			model = self.treeview.get_model()
			package_iter = model.get_iter_root()
			active_downloads = 0
			complete_downloads = 0
			total_downloads = 0
			total_speed = 0
			while package_iter:
				file_iter = model.iter_children(package_iter)
				#package_status = model.set_value(package_iter, 0)
				package_progress = 0
				package_speed = 0
				tmp_actual_size = []
				tmp_total_size = []
				while file_iter:
					total_downloads += 1
					name = model.get_value(file_iter, 3)
					for file in files:
						if file.name == name:
							model.set_value(file_iter, 0, self.icons[file.status])
							model.set_value(file_iter, 1, file.status)
							if file.status in [cons.STATUS_ACTIVE, cons.STATUS_WAIT]:
								active_downloads += 1
							elif file.status == cons.STATUS_CORRECT:
								complete_downloads += 1
							model.set_value(file_iter, 4, file.progress)
							package_progress += file.progress
							if file.actual_size > 0:
								model.set_value(file_iter, 6, str(file.actual_size)+file.actual_size_unit)
								tmp_actual_size.append((file.actual_size, file.actual_size_unit))
							tmp_total_size.append((file.total_size, file.total_size_unit))
							if file.speed > 1:
								model.set_value(file_iter, 8, str(file.speed)+cons.UNIT_SPEED)
								package_speed += file.speed
							elif file.speed == 0:
								model.set_value(file_iter, 8, None)
							if file.status == cons.STATUS_CORRECT:
								if not file.time > 0:
									file.time = 1
								file.actual_size = file.total_size
								file.actual_size_unit = file.total_size_unit
							model.set_value(file_iter, 9, self.calculate_time(file.time))
							link_iter = model.iter_children(file_iter)
							while link_iter:
								for tmp_link in file.links:
									if tmp_link.url == model.get_value(link_iter, 3):
										service_icon = self.unactive_service_icon
										link_status = cons.STATUS_STOP
										if tmp_link.active:
											service_icon = self.active_service_icon
											link_status = cons.STATUS_ACTIVE
										model.set_value(link_iter, 0, service_icon)
										model.set_value(link_iter, 1, link_status)
								link_iter = model.iter_next(link_iter)
					file_iter = model.iter_next(file_iter)
				package_actual_size, package_actual_unit = self.normalize(tmp_actual_size)
				package_total_size, package_total_unit = self.normalize(tmp_total_size)
				if package_actual_size > 0:
					if int(package_progress/model.iter_n_children(package_iter)) == 100:
						model.set_value(package_iter, 4, 100)
					else:
						model.set_value(package_iter, 4, int((float(self.get_size(package_actual_size, package_actual_unit))/float(self.get_size(package_total_size, package_total_unit)))*100))
					model.set_value(package_iter, 6, str(package_actual_size)+package_actual_unit)
				if package_speed > 0:
					model.set_value(package_iter, 8, str(package_speed)+cons.UNIT_SPEED)
				else:
					model.set_value(package_iter, 8, None)
				total_speed += package_speed
				package_iter = model.iter_next(package_iter)
			self.status_bar.pop(self.status_bar.get_context_id("Downloads"))
			self.status_bar.push(self.status_bar.get_context_id("Downloads"), " Downstream %dKB/s \tTotal %d \t Complete %d \t Active %d" %	(total_speed, total_downloads, complete_downloads, active_downloads))
		return True

	def normalize(self, sizes):
		""""""
		total = 0
		total_unit = cons.UNIT_KB
		for size, unit in sizes:
			total += self.get_size(size, unit)
		tmp = int(total/1024)
		if  tmp > 0:
			total = tmp
			total_unit = cons.UNIT_MB
			tmp = int(tmp/1024)
		#	if tmp > 0:
		#		total = tmp
		#		total_unit = cons.UNIT_GB
		return total, total_unit

	def get_size(self, size, unit):
		""""""
		if unit == cons.UNIT_KB:
			return size
		elif unit == cons.UNIT_MB:
			return size*1024
		#elif unit == cons.UNIT_GB:
		#	return size*1024*1024

	def get_packages(self):
		""""""
		model = self.treeview.get_model()
		package_iter = model.get_iter_root()
		packages = []
		info = []
		while package_iter:
			files = []
			file_iter = model.iter_children(package_iter)
			while file_iter:
				if model.get_value(file_iter, 1) != cons.STATUS_CORRECT:
					links = []
					plugins = []
					link_iter = model.iter_children(file_iter)
					while link_iter:
						links.append(model.get_value(link_iter, 3))
						plugins.append(model.get_value(link_iter, 10))
						link_iter = model.iter_next(link_iter)
					name = model.get_value(file_iter, 3)
					tmp = model.get_value(file_iter, 7)
					for unit in [cons.UNIT_KB, cons.UNIT_MB]:
						tmp_size = tmp.split(unit)
						if len(tmp_size) > 1:
							size_unit = unit
							size = int(tmp_size[0])
							break
					tmp = model.get_value(file_iter, 10)
					tmp = tmp.split(",")
					service_list = []
					for service in tmp:
						service_list.append(service.split("\'")[1])
					files.append((links, name, service_list, size, size_unit, plugins))
				file_iter = model.iter_next(file_iter)
			if len(files) > 0:
				name = model.get_value(package_iter, 3)
				packages.append((name, files))
				path = model.get_value(package_iter, 10).split(name)[0]
				info.append((path, name, model.get_value(package_iter, 2)))
			package_iter = model.iter_next(package_iter) 
		return packages, info

	def get_links(self, iter):
		""""""
		links = []
		model = self.treeview.get_model()
		file_iter = model.iter_children(iter)
		if not file_iter:
			links.append(model.get_value(iter, 3))
		while file_iter:
			link_iter = model.iter_children(file_iter)
			if not link_iter:
				links.append(model.get_value(file_iter, 3))
			while link_iter:
				links.append(model.get_value(link_iter, 3))
				link_iter = model.iter_next(link_iter)
			file_iter = model.iter_next(file_iter)
		return links

	def package_files(self, package_iter):
		""""""
		files = []
		model = self.treeview.get_model()
		file_iter = model.iter_children(package_iter)
		while file_iter:
			if model.get_value(file_iter, 1) not in [cons.STATUS_ACTIVE, cons.STATUS_WAIT, cons.STATUS_CORRECT]:
				files.append(model.get_value(file_iter, 3))
			file_iter = model.iter_next(file_iter)
		return files

	def clear(self):
		""""""
		files = []
		model = self.treeview.get_model()
		package_iter = model.get_iter_root()
		while package_iter:
			tmp_iter = package_iter
			package_iter = model.iter_next(package_iter)
			files += self.delete_package([cons.STATUS_CORRECT], tmp_iter)
		return files

	def delete_package(self, status, package_iter):
		""""""
		tmp = []
		model = self.treeview.get_model()
		file_iter = model.iter_children(package_iter)
		while file_iter:
			if model.get_value(file_iter, 1) in status:
				tmp.append(model.get_value(file_iter, 3))
			file_iter = model.iter_next(file_iter)
		if len(tmp) == model.iter_n_children(package_iter):
			model.remove(package_iter)
		else:
			tmp = []
		return tmp

	def delete_file(self, status, iter):
		""""""
		model = self.treeview.get_model()
		if model.get_value(iter, 1) in status:
			if model.iter_n_children(model.iter_parent(iter)) > 1:
				result = model.get_value(iter, 3)
				model.remove(iter)
				return result

	def delete_link(self, status, iter):
		""""""
		result = None, None
		model = self.treeview.get_model()
		file_iter = model.iter_parent(iter)
		if model.iter_n_children(file_iter) > 1:
			if model.get_value(iter, 1) == cons.STATUS_STOP:
				result = model.get_value(file_iter, 3), model.get_value(iter, 3)
				model.remove(iter)
		return result

	def move_up(self, iter):
		""""""
		model = self.treeview.get_model()
		package_iter = model.iter_parent(iter)
		file_iter = model.iter_children(package_iter)
		prev_iter = None
		while ((file_iter) and (model.get_path(file_iter) != model.get_path(iter))):
			prev_iter = file_iter
			file_iter = model.iter_next(file_iter)
		if prev_iter:
			model.move_before(iter, prev_iter)
			return True

	def move_down(self, iter):
		""""""
		model = self.treeview.get_model()
		next_iter = model.iter_next(iter)
		if next_iter:
			model.move_after(iter, next_iter)
			return True

	def calculate_time(self, time):
		""""""
		result = None
		hours = 0
		minutes = 0
		while time >= cons.HOUR:
			time = time - cons.HOUR
			hours += 1
		while time >= cons.MINUTE:
			time = time - cons.MINUTE
			minutes += 1
		seconds = time
		if hours > 0:
			result = str(hours) + "h" + str(minutes) + "m" + str(seconds) + "s"
		elif minutes > 0:
			result =  str(minutes) + "m" + str(seconds) + "s"
		elif seconds > 0:
			result = str(seconds) + "s"
		return result
