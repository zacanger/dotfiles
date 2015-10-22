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

import getpass
import logging
logger = logging.getLogger(__name__)

from core.service_update import ServiceUpdate
from core.service_config import SECTION_PREMIUM_DOWNLOAD

import core.misc
import core.cons as cons

class Wizard:
	""""""		
	def __init__(self):
		""""""
		core.misc.main_info()

	def account_setup(self, config):
		""""""
		logger.info("Setup accounts.")
		quit = False
		services = [service for service in config.get_services() if service[4].premium_cookie()[1] or service[4].user_cookie()[1]]
		while not quit:
			try:
				cont = 0
				for service in services:
					print " [%s]\t%s \t%i accounts." % (cont, service[2], len(service[4].get_accounts(SECTION_PREMIUM_DOWNLOAD)))
					cont +=1
				input = raw_input("Choose [N] service or (Q)uit: ").strip()
				if input.lower() == "q":
					quit = True
				elif int(input) in range(cont):
					service = services[int(input)]
					#module, class_name = service_config.user_cookie()
					module, class_name = service[4].premium_cookie()
					module = __import__("%s.%s" % (service[0], module), None, None, [''])
					self.account_setup2(service, eval("module" + "." + class_name + "()").get_cookie)
			except ValueError:
				pass
			except Exception, e:
				logger.error("Error. %s" % e)
		logger.info("DONE")
		
	def account_setup2(self, service, get_cookie):
		""""""
		end = False
		accounts = service[4].get_accounts(SECTION_PREMIUM_DOWNLOAD)
		while not end:
			try:
				logger.info("Premium accounts for '%s'" % service[2])
				cont = 0
				for name, settings in accounts.items():
					print " [%s]\t'%s' %s and %s" % (cont, name, self.get_active(settings[2]), self.get_status(settings[1]))
					cont += 1
				input = raw_input("Modify [N] account, (A)dd or (R)eturn: ").strip()
				if input.lower() == "r":
					service[4].set_accounts(SECTION_PREMIUM_DOWNLOAD, accounts)
					end = True
				elif input.lower() == "a":
					user = self.get_user()
					if user:
						password = self.get_password()
						if self.check_account(user, password, get_cookie):
							accounts[user] = (password, True, True)
						else:
							accounts[user] = (password, False, False)
				elif int(input) in range(cont):
					name, settings = accounts.items()[int(input)]
					input2 = raw_input("Set (U)ser, (P)assword, (E)nabled or (D)elete: ").strip()
					if input2.lower() == "d":
						del accounts[name]
						logger.warning("'%s': DELETED!" % name)
					elif input2.lower() == "u":
						user = self.get_user()
						if user:
							logger.info("Changed '%s' to '%s'." % (name, user))
							del accounts[name]
							if self.check_account(user, settings[0], get_cookie):
								accounts[user] = (settings[0], True, True)
							else:
								accounts[user] = (settings[0], False, False)
					elif input2.lower() == "p":
						password = self.get_password()
						if password:
							if self.check_account(name, settings[0], get_cookie):
								accounts[name] = (password, True, True)
							else:
								accounts[name] = (password, False, False)
					elif input2.lower() == "e":
						enabled = settings[1]
						if enabled:
							enabled = not enabled
						else:
							if self.check_account(name, settings[0], get_cookie):
								enabled = not enabled
						accounts[name] = (settings[0], enabled, settings[2])
						logger.info("'%s': %s" % (name, self.get_status(enabled)))
			except ValueError:
				pass
			except Exception, e:
				logger.error("Error. %s" % e)
				
	def check_account(self, user, password, get_cookie):
		""""""
		logger.info("Checking account '%s'..." % user)
		try:
			if get_cookie(user, password):
				logger.info("'%s': SUCCESS!" % user)
				return True
			else:
				logger.warning("'%s': INVALID ACCOUNT." % user)
		except Exception, e:
			logger.error("Error. %s" % e)

	def get_user(self):
		""""""
		user = raw_input("User: ").strip()
		if user:
			return user
		else:
			logger.error("No user name.")
		
	def get_password(self):
		""""""
		while True:
			pass1 = getpass.getpass("Password: ")
			if pass1:
				pass2 = getpass.getpass("Retype Password: ")
				if pass1 == pass2:
					return pass1
				else:
					logger.error("Passwords do not match.")
			else:
				logger.error("No password supplied.")


	def get_active(self, status):
		""""""
		if status:
			return "ACTIVE"
		else:
			return "INACTIVE"

	def get_status(self, status):
		""""""
		if status:
			return "ENABLED"
		else:
			return "DISABLED"

	def list_enabled(self, services):
		""""""
		cont = 0
		for service in services:
			print " [%s]\t%s \t%s" % (cont, self.get_status(service[3]), service[2])
			cont +=1
		return cont

	def service_setup(self, config):
		""""""
		logger.info("Enable services.")
		quit = False
		services = config.get_services()
		cont = self.list_enabled(services)
		while not quit:
			try:
				input = raw_input("Choose [N] service, (L)ist or (Q)uit: ").strip()
				if input.lower() == "q":
					quit = True
				elif input.lower() == "l":
					self.list_enabled(services)
				elif int(input) in range(cont):
					service = services[int(input)]
					status = not service[3]
					if status:
						logger.info("You should read '%s' terms of service." % service[2])
					logger.info("'%s' %s" % (service[2], self.get_status(status)))
					service[4].enable(status)
					services = config.get_services()
			except ValueError:
				pass
			except Exception, e:
				logger.error("Invalid argument!")
		logger.info("DONE")

	def update_setup(self, config):
		""""""
		try:
			s = ServiceUpdate(config)
			logger.info("Checking updates...")
			s.get_updates()
			new = 0
			updates = 0
			for key, value in s.updates.items():
				if value[2]:
					updates +=1
				else:
					new += 1
			logger.info("%i New and %i Updates" % (new, updates))
			for key, value in s.updates.items():
				s.install_service(key, value[0], value[1])
		except Exception, e:
			logger.error("Error updating. %s" % e)
		else:
			config.save()
			logger.info("DONE")			
