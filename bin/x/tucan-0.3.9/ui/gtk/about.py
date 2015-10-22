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

import media
import core.cons as cons

NAME = "Tucan"
COPYRIGHT = "(C) 2008-2009 The Tucan Project"
LICENSE = """	
	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program.  If not, see <http://www.gnu.org/licenses/>.
	"""

class About(gtk.AboutDialog):
	""""""
	def __init__(self, parent=None):
		""""""
		gtk.AboutDialog.__init__(self)
		self.set_transient_for(parent)
		self.set_position(gtk.WIN_POS_CENTER)
		self.set_icon_from_file(media.ICON_TUCAN)
		self.set_logo(gtk.gdk.pixbuf_new_from_file(media.ICON_TUCAN))
		self.set_name(NAME)
		self.set_version(cons.TUCAN_VERSION)
		self.set_copyright(COPYRIGHT)
		self.set_license(LICENSE)
		self.set_website(cons.WEBPAGE)
		self.connect("response", self.close)
		self.show_all()
		self.run()

	def close(self, widget=None, other=None):
		""""""
		self.destroy()

if __name__ == "__main__":
	g = About()
	gtk.main()
