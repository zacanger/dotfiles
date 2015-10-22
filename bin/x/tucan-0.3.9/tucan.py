#! /usr/bin/env python
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
import os
import sys
import logging
import optparse

import core.misc as misc
import core.url_open as url_open
import core.config as config
import core.cons as cons

class Tucan:
	""""""
	def __init__(self):
		""""""
		#exception hook
		sys.excepthook = self.exception_hook
		
		#parse options
		parser = optparse.OptionParser()
		parser.add_option("-w", "--wizard", dest="wizard", help="setup: accounts, services, updates", metavar="TYPE")
		parser.add_option("-d", "--daemon", action="store_true", dest="daemon", default=False, help="no interaction interface")
		parser.add_option("-c", "--cli", action="store_true", dest="cli", default=False, help="command line interface")
		parser.add_option("-i", "--input-links", dest="links_file", help="import links from FILE", metavar="FILE")
		parser.add_option("-v", "--verbose", action="store_true", dest="verbose", default=False, help="print log to stdout")
		parser.add_option("-V", "--version", action="store_true", dest="version", default=False, help="print version and exit")
		options, args = parser.parse_args()
	
		if options.version:
			print "%s %s" % (cons.TUCAN_NAME, cons.TUCAN_VERSION)
			sys.exit()

		#configuration
		__builtin__.configuration = config.Config()
		sys.path.append(cons.PLUGIN_PATH)

		#logging
		if os.path.exists(cons.LOG_FILE):
			if os.path.exists("%s.old" % cons.LOG_FILE):
				os.remove("%s.old" % cons.LOG_FILE)
			os.rename(cons.LOG_FILE, "%s.old" % cons.LOG_FILE)
		logging.basicConfig(level=logging.DEBUG, format=cons.LOG_FORMAT, filename=cons.LOG_FILE, filemode='w')
		self.logger = logging.getLogger(self.__class__.__name__)
		
		#start user interface
		try:
			self.set_globals(options)
			if options.wizard:
				self.set_verbose()
				self.start_wizard(options.wizard)
			elif options.daemon:
				self.set_verbose()
				self.start_daemon(options.links_file)
			elif options.cli:
				self.start_cli(options.links_file)
			else:
				if options.verbose:
					self.set_verbose()
				self.start_gui()
		except KeyboardInterrupt:
			self.exit("KeyboardInterrupt")
		except Exception, e:
			self.logger.exception(e)
			print e
			print "Reporting error, please wait..."
			#print "REPORT ID: %s" % misc.report_log("Automatic", str(e))
			print "Unhandled Error! Check the log file for details."
			self.exit(-1)
			
	def set_verbose(self, severity=logging.INFO):
		""""""
		console = logging.StreamHandler(sys.stdout)
		console.setLevel(severity)
		console.setFormatter(logging.Formatter('%(levelname)-7s %(name)s: %(message)s'))
		logging.getLogger("").addHandler(console)
		
	def start_wizard(self, wizard_type):
		""""""
		from ui.console.wizard import Wizard
		
		w = Wizard()
		if wizard_type == "accounts":
			w.account_setup(configuration)
		elif wizard_type == "services":
			w.service_setup(configuration)
		elif wizard_type == "updates":
			w.update_setup(configuration)
		else:
			print "TYPE should be one of: accounts, services or updates"
		
	def start_daemon(self, file):
		""""""
		from ui.console.no_ui import NoUi
		
		d = NoUi(configuration, file)
		d.run()

	def start_cli(self, file):
		""""""
		if cons.OS_WINDOWS:
			print "No curses support."
			self.exit()
		else:
			from curses.wrapper import wrapper
			from ui.console.cli import Cli
			
			c = Cli(configuration, file)
			wrapper(c.run)

	def start_gui(self):
		""""""
		import pygtk
		pygtk.require('2.0')
		import gtk
		import gobject
		
		from ui.gtk.gui import Gui
		
		try:
			gtk.init_check()
		except:
			print "Could not connect to X server. Use 'tucan --cli' for curses interface."
		else:
			gobject.threads_init()
			Gui(configuration)
			gtk.main()

	def set_globals(self, options):
		""""""		
		#custom exit
		__builtin__.tucan_exit = self.exit

		#proxy settings
		__builtin__.PROXY = None
		proxy_url, proxy_port = configuration.get_proxy()
		url_open.set_proxy(proxy_url, proxy_port)
		
		__builtin__.max_downloads = configuration.getint(config.SECTION_MAIN, config.OPTION_MAX_DOWNLOADS)
		__builtin__.max_download_speed = configuration.getint(config.SECTION_MAIN, config.OPTION_MAX_DOWNLOAD_SPEED)

	def exception_hook(self, type, value, trace):
		""""""
		file_name = trace.tb_frame.f_code.co_filename
		line_no = trace.tb_lineno
		exception = type.__name__
		try:
			self.logger.critical("File %s line %i - %s: %s" % (file_name, line_no, exception, value))
		except:
			pass
		sys.__excepthook__(type, value, trace)
		self.exit(-1)

	def exit(self, arg=0):
		""""""
		self.logger.debug("Exit: %s" % arg)
		sys.exit(arg)

if __name__ == "__main__":
	t = Tucan()
	