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
import pickle
import logging
logger = logging.getLogger(__name__)

from ConfigParser import SafeConfigParser

import cons

LAST_SESSION = "last.session"

SECTION_DOWNLOADS = "downloads"
OPTION_PACKAGES = "packages"
OPTION_PACKAGES_INFO = "packages_info"

PACKAGES = [('D.S03E01.PREAiR.DVDSCR.NOTYOU.cHoPPaHoLiK.part', [(['http://www.megaupload.com/?d=GW1WB3IV', 'http://rapidshare.com/files/143483416/D.S03E01.PREAiR.DVDSCR.NOTYOU.cHoPPaHoLiK.part1.rar'], 'D.S03E01.PREAiR.DVDSCR.NOTYOU.cHoPPaHoLiK.part1.rar', ['megaupload.com', 'rapidshare.com'], 200, 'MB', ['AnonymousMegaupload', 'AnonymousRapidshare']), (['http://www.megaupload.com/?d=TITR6R0P', 'http://rapidshare.com/files/143483557/D.S03E01.PREAiR.DVDSCR.NOTYOU.cHoPPaHoLiK.part2.rar'], 'D.S03E01.PREAiR.DVDSCR.NOTYOU.cHoPPaHoLiK.part2.rar', ['megaupload.com', 'rapidshare.com'], 200, 'MB', ['AnonymousMegaupload', 'AnonymousRapidshare']), (['http://www.megaupload.com/?d=DCJX0RKQ', 'http://rapidshare.com/files/143483236/D.S03E01.PREAiR.DVDSCR.NOTYOU.cHoPPaHoLiK.part3.rar'], 'D.S03E01.PREAiR.DVDSCR.NOTYOU.cHoPPaHoLiK.part3.rar', ['megaupload.com', 'rapidshare.com'], 135, 'MB', ['AnonymousMegaupload', 'AnonymousRapidshare'])]), ('Californication.2x01.samuelro.part', [(['http://rapidshare.com/files/149540090/Californication.2x01.samuelro.part1.rar'], 'Californication.2x01.samuelro.part1.rar', ['rapidshare.com'], 200, 'MB', ['AnonymousRapidshare']), (['http://rapidshare.com/files/149537924/Californication.2x01.samuelro.part2.rar'], 'Californication.2x01.samuelro.part2.rar', ['rapidshare.com'], 41, 'MB', ['AnonymousRapidshare'])]), ('Californication.2x02.samuelro.part', [(['http://rapidshare.com/files/151602033/Californication.2x02.samuelro.part1.rar'], 'Californication.2x02.samuelro.part1.rar', ['rapidshare.com'], 195, 'MB', ['AnonymousRapidshare']), (['http://rapidshare.com/files/151408776/Californication.2x02.samuelro.part2.rar'], 'Californication.2x02.samuelro.part2.rar', ['rapidshare.com'], 45, 'MB', ['AnonymousRapidshare'])])] 

PACKAGES_INFO = [('/home/crak/', 'D.S03E01.PREAiR.DVDSCR.NOTYOU.cHoPPaHoLiK.part', None), ('/home/crak/downloads/', 'Californication.2x01.samuelro.part', 'mierda'), ('/home/crak/downloads/', 'Californication.2x02.samuelro.part', 'cojones')]

class Sessions(SafeConfigParser):
	""""""
	def load_session(self, path):
		""""""
		result = None, None
		if os.path.exists(path):
			self.read(path)
			if self.has_section(SECTION_DOWNLOADS):
				if ((self.has_option(SECTION_DOWNLOADS, OPTION_PACKAGES)) and (self.has_option(SECTION_DOWNLOADS, OPTION_PACKAGES_INFO))): 
					result = pickle.loads(self.get(SECTION_DOWNLOADS, OPTION_PACKAGES)), pickle.loads(self.get(SECTION_DOWNLOADS, OPTION_PACKAGES_INFO))
		return result

	def save_session(self, path, session_packages, session_info):
		""""""
		if not self.has_section(SECTION_DOWNLOADS):
			self.add_section(SECTION_DOWNLOADS)
		self.set(SECTION_DOWNLOADS, OPTION_PACKAGES, pickle.dumps(session_packages))
		self.set(SECTION_DOWNLOADS, OPTION_PACKAGES_INFO, pickle.dumps(session_info))
		self.save(path)

	def save(self, path):
		""""""
		try:
			f = open("%s.tmp" % path, "w")
			self.write(f)
			f.flush()
			os.fsync(f.fileno())
			f.close()
			if os.path.exists(path):
				os.remove(path)
			os.rename("%s.tmp" % path, path)
		except Exception, e:
			if os.path.exists("%s.tmp" % path):
				os.remove("%s.tmp" % path)
			logger.exception(e)

if __name__ == "__main__":
	s = Sessions()
	s.save_default_session(PACKAGES, PACKAGES_INFO)
	print s.load_default_session()
