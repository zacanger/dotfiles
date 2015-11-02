#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os,sys
import urllib
# PyQt specific
from PyQt4 import QtGui, QtCore
APPLIREP = os.getcwd()
IMAGES = os.path.join(APPLIREP,'Plugins/Browser/BrowserImages')

class browser(QtGui.QTextBrowser):
    """A QTextBrowser with local images support.
    """

    def __init__(self, filename=QtCore.QString(), parent=None):
        QtGui.QTextEdit.__init__(self, parent)
        self.parent = parent
        self.document().setDefaultStyleSheet(open(os.getcwd() + "/browser.css","r").read())

    def loadResource(self, type, name):
        url=unicode(name.toString())
        ret=QtCore.QVariant()
        if url.startswith('http://'):
            fname = url.split("/")[-1]
            dn=os.path.expanduser(IMAGES)
            if not os.path.isdir(dn):
                os.mkdir(dn)
            #fn = dn + "/" + fname
            fn=os.path.join(dn,fname)
            if not os.path.isfile(fn):
                urllib.urlretrieve(url, fn)
            ret=QtGui.QTextBrowser.loadResource(self, type, QtCore.QUrl.fromLocalFile(QtCore.QString(fn)))
        else:
            ret=QtGui.QTextBrowser.loadResource(self, type, name)
        return ret
