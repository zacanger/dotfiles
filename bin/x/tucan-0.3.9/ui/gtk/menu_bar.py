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

import logging
logger = logging.getLogger(__name__)

import pygtk
pygtk.require('2.0')
import gtk

import core.cons as cons

class MenuBar(gtk.MenuBar):
	""""""
	def __init__(self, list):
		"""list = [(menu_name=str, [(item_image=stock_item, callback), None=separator])]"""
		gtk.MenuBar.__init__(self)
		for menu in list:
			item = gtk.MenuItem(menu[0])
			self.append(item)
			submenu = gtk.Menu()
			for sub in menu[1]:
				if sub == None:
					subitem = gtk.SeparatorMenuItem()
				elif isinstance(sub[0], gtk.CheckMenuItem):
					subitem = sub[0]
					subitem.set_active(sub[2])
					subitem.connect("toggled", sub[1])
				else:
					subitem = gtk.ImageMenuItem(sub[0])
					subitem.connect("activate", sub[1])
				submenu.append(subitem)
			item.set_submenu(submenu)

if cons.OS_OSX:
	try:
		from igemacintegration import *

	except Exception:
		pass
	else:
		class OSXMenuBar(MenuBar):
			""""""
			def __init__(self, menu, menu_about, menu_preferences, menu_quit):
				""""""
				MenuBar.__init__(self, menu)
				self.show_all()

				macmenu = MacMenu()
				macmenu.set_menu_bar(self)
		
				quit_item = gtk.MenuItem(menu_quit[0])
				quit_item.connect("activate", menu_quit[1])
				macmenu.set_quit_menu_item(quit_item)

				group = macmenu.add_app_menu_group()
				item = gtk.MenuItem(menu_about[0])
				item.connect("activate", menu_about[1])
				group.add_app_menu_item(item, None)
		
				group = macmenu.add_app_menu_group()
				item = gtk.MenuItem(menu_preferences[0])
				item.connect("activate", menu_preferences[1])
				group.add_app_menu_item(item, None)
