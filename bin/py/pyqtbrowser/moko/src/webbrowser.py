#!/usr/bin/env python

#############################################################################
## Copyright 2007-2008 Openmoko, Inc.
## Authored by Erin Yueh <erin_yueh@openmoko.com>
##
## Copyright (C) 1992-2006 Trolltech ASA. All rights reserved.
## This file is part of the example classes of the Qt Toolkit.
##
## Licensees holding a valid Qt License Agreement may use this file in
## accordance with the rights, responsibilities and obligations
## contained therein.  Please consult your licensing agreement or
## contact sales@trolltech.com if any conditions of this licensing
## agreement are not clear to you.
##
## Further information about Qt licensing is available at:
## http://www.trolltech.com/products/qt/licensing.html or by
## contacting info@trolltech.com.
##
## This file is provided AS IS with NO WARRANTY OF ANY KIND, INCLUDING THE
## WARRANTY OF DESIGN, MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.
##
#############################################################################

import sys
from PyQt4 import QtCore, QtGui, QtWebKit
from browser import browser_misc, ui_mainwindow

class QLineEdit2(QtGui.QLineEdit):

    def __init__(self, parent=None):
        QtGui.QLineEdit.__init__(self, parent)

    def focusOutEvent(self, event):
        #print 'focusOutEvent', event
        self.emit(QtCore.SIGNAL("lostFocus"), self)
        QtGui.QLineEdit.focusOutEvent(self, event)
        
    def focusInEvent(self, event):
        #print 'focusInEvent', event
        self.emit(QtCore.SIGNAL("gotFocus"), self)
        QtGui.QLineEdit.focusInEvent(self, event)

class MainWindow(QtGui.QMainWindow, ui_mainwindow.Ui_MainWindow):
    # Maintain the list of browser windows so that they do not get garbage
    # collected.
    _window_list = []

    def __init__(self):
        QtGui.QMainWindow.__init__(self)

        MainWindow._window_list.append(self)

        self.setupUi(self)
        self.misc = browser_misc.misc()
        
        self.lblAddress = QtGui.QLabel("", self.tbAddress)
        self.tbAddress.insertWidget(self.actionGo, self.lblAddress)
        self.addressEdit = QLineEdit2(self.tbAddress)
        self.tbAddress.insertWidget(self.actionGo, self.addressEdit)
        
        self.connect(self.addressEdit, QtCore.SIGNAL("gotFocus"),
                     self.enable_keyboard)
                     
        self.connect(self.addressEdit, QtCore.SIGNAL("lostFocus"),
                     self.disable_keyboard)

        self.addressEdit.setFocusPolicy(QtCore.Qt.StrongFocus)
        
        self.connect(self.addressEdit, QtCore.SIGNAL("returnPressed()"),
                     self.actionGo, QtCore.SLOT("trigger()"))
                     
        self.connect(self.actionBack, QtCore.SIGNAL("triggered()"),
                     self.WebBrowser, QtCore.SLOT("back()"))
        
        self.connect(self.actionForward, QtCore.SIGNAL("triggered()"),
                     self.WebBrowser, QtCore.SLOT("forward()"))
        
        self.connect(self.actionStop, QtCore.SIGNAL("triggered()"),
                     self.WebBrowser, QtCore.SLOT("stop()"))
        
        self.connect(self.actionRefresh, QtCore.SIGNAL("triggered()"),
                     self.WebBrowser, QtCore.SLOT("reload()"))

        self.pb = QtGui.QProgressBar(self.statusBar())
        self.pb.setTextVisible(False)
        self.pb.hide()
        self.statusBar().addPermanentWidget(self.pb)
        self.WebBrowser.load(QtCore.QUrl("http://www.google.com"))


    def enable_keyboard(self):
        print 'enable keyboard'
        self.misc.keyboard_show()
        
    def disable_keyboard(self):
        print 'disable keyboard'
        self.misc.keyboard_hide()
        
    @QtCore.pyqtSignature("")
    def on_actionHome_triggered(self):
        self.WebBrowser.load(QtCore.QUrl("http://www.google.com"))

    def on_WebBrowser_urlChanged(self, url):
        self.addressEdit.setText(url.toString())
        
    def on_WebBrowser_titleChanged(self, title):
        #print 'titleChanged',title.toUtf8()
        self.setWindowTitle(title)

    def on_WebBrowser_loadStarted(self):
        #print 'loadStarted'
        #self.misc.keyboard_show()
        
        self.pb.show()
        self.pb.setRange(0, 100)
        self.pb.setValue(1)

    def on_WebBrowser_loadFinished(self, flag):
        #print 'loadFinished'
        if flag is True:
            self.pb.hide()
            self.statusBar().removeWidget(self.pb)
            
    def on_WebBrowser_loadProgress(self, status):
        self.pb.show()
        self.pb.setRange(0, 100)
        self.pb.setValue(status)

    @QtCore.pyqtSignature("")
    def on_actionGo_triggered(self):
        #print "on_actionGo_triggered"
        
        self.WebBrowser.load(QtCore.QUrl(self.addressEdit.text()))
        self.addressEdit.setText(self.addressEdit.text())

    @QtCore.pyqtSignature("")
    def on_actionHome_triggered(self):
        #print "on_actionHome_triggered"
        self.WebBrowser.load(QtCore.QUrl("http://www.google.com"))
        self.addressEdit.setText("http://www.google.com")


if __name__ == "__main__":
    a = QtGui.QApplication(sys.argv)
    w = MainWindow()

    w.show()
    sys.exit(a.exec_())
