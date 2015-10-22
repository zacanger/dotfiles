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

DESTDIR		=	/usr/local
BINDIR		=	$(DESTDIR)/bin/
MAINDIR		=	$(DESTDIR)/share/tucan/
ICONDIR		=	$(DESTDIR)/share/pixmaps/
MANDIR		=	$(DESTDIR)/share/man/man1/
DESKTOPDIR	=	$(DESTDIR)/share/applications/

NAME		=	tucan
EXECFILE	=	tucan.py
ICONFILE	=	tucan.svg
MANPAGE		=	tucan.1.gz
DESKTOPFILE	=	tucan.desktop
COREDIR		=	core/
PLUGINDIR	=	default_plugins/
I18NDIR		=	i18n/
MEDIADIR	=	media/
UIDIR		=	ui/

basic-install:
	mkdir -p $(BINDIR) $(MAINDIR) $(ICONDIR) $(MANDIR) $(DESKTOPDIR)

	install -p -m 0644 *.py $(MAINDIR)
	chmod 0755 $(MAINDIR)$(EXECFILE)

	cp -pR $(COREDIR) $(MAINDIR)
	cp -pR $(PLUGINDIR) $(MAINDIR)
	cp -pR $(I18NDIR) $(MAINDIR)
	cp -pR $(MEDIADIR) $(MAINDIR)
	cp -pR $(UIDIR) $(MAINDIR)

	install -p -m 0644 $(MEDIADIR)$(ICONFILE) $(ICONDIR)

	install -p -m 0644 $(MANPAGE) $(MANDIR)

	install -p -m 0644 $(DESKTOPFILE) $(DESKTOPDIR)

install:
	make basic-install

	ln -sf $(MAINDIR)$(EXECFILE) $(BINDIR)$(NAME)

uninstall:
	rm -rf $(MAINDIR)
	rm -f $(BINDIR)$(NAME)
	rm -f $(ICONDIR)$(ICONFILE)
	rm -f $(MANDIR)$(MANPAGE)
	rm -f $(DESKTOPDIR)$(DESKTOPFILE)
