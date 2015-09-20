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
from PyQt4 import QtCore, QtGui

class Ui_MainWindow(object):
    
    def setupUi(self, MainWindow):
        
        MainWindow.setObjectName("MainWindow")
        MainWindow.resize(QtCore.QSize(QtCore.QRect(0,0,480,640).size()).expandedTo(MainWindow.minimumSizeHint()))

        self.centralWidget = QtGui.QWidget(MainWindow)
        self.centralWidget.setObjectName("centralWidget")

        self.hboxlayout = QtGui.QHBoxLayout(self.centralWidget)
        self.hboxlayout.setMargin(1)
        self.hboxlayout.setSpacing(1)
        self.hboxlayout.setObjectName("hboxlayout")

        self.Frame3 = QtGui.QFrame(self.centralWidget)
        self.Frame3.setFrameShape(QtGui.QFrame.StyledPanel)
        self.Frame3.setFrameShadow(QtGui.QFrame.Plain)
        self.Frame3.setObjectName("Frame3")

        self.vboxlayout = QtGui.QVBoxLayout(self.Frame3)
        self.vboxlayout.setMargin(1)
        self.vboxlayout.setSpacing(0)
        self.vboxlayout.setObjectName("vboxlayout")

        self.WebBrowser = QtWebKit.QWebView(self.Frame3)
        self.WebBrowser.setObjectName("WebBrowser")
        self.vboxlayout.addWidget(self.WebBrowser)
        self.hboxlayout.addWidget(self.Frame3)
        MainWindow.setCentralWidget(self.centralWidget)

        self.tbNavigate = QtGui.QToolBar(MainWindow)
        self.tbNavigate.setOrientation(QtCore.Qt.Horizontal)
        self.tbNavigate.setObjectName("tbNavigate")
        MainWindow.addToolBar(self.tbNavigate)

        self.tbAddress = QtGui.QToolBar(MainWindow)
        self.tbAddress.setOrientation(QtCore.Qt.Horizontal)
        self.tbAddress.setObjectName("tbAddress")
        MainWindow.addToolBar(self.tbAddress)
        
        self.actionGo = QtGui.QAction(MainWindow)
        self.actionGo.setIcon(QtGui.QIcon(":icons/image0.xpm"))
        self.actionGo.setObjectName("actionGo")

        self.actionBack = QtGui.QAction(MainWindow)
        self.actionBack.setIcon(QtGui.QIcon(":icons/image1.xpm"))
        self.actionBack.setObjectName("actionBack")

        self.actionForward = QtGui.QAction(MainWindow)
        self.actionForward.setIcon(QtGui.QIcon(":icons/image2.xpm"))
        self.actionForward.setObjectName("actionForward")

        self.actionStop = QtGui.QAction(MainWindow)
        self.actionStop.setIcon(QtGui.QIcon(":icons/image3.xpm"))
        self.actionStop.setObjectName("actionStop")

        self.actionRefresh = QtGui.QAction(MainWindow)
        self.actionRefresh.setIcon(QtGui.QIcon(":icons/image4.xpm"))
        self.actionRefresh.setObjectName("actionRefresh")

        self.actionHome = QtGui.QAction(MainWindow)
        self.actionHome.setIcon(QtGui.QIcon(":icons/image5.xpm"))
        self.actionHome.setObjectName("actionHome")

        self.tbNavigate.addAction(self.actionBack)
        self.tbNavigate.addAction(self.actionForward)
        self.tbNavigate.addAction(self.actionStop)
        self.tbNavigate.addAction(self.actionRefresh)
        self.tbNavigate.addAction(self.actionHome)
        
        self.tbAddress.addAction(self.actionGo)

        self.retranslateUi(MainWindow)
        QtCore.QMetaObject.connectSlotsByName(MainWindow)



    def retranslateUi(self, MainWindow):
        MainWindow.setWindowTitle(QtGui.QApplication.translate("MainWindow", "Qt WebBrowser", None, QtGui.QApplication.UnicodeUTF8))
        self.tbNavigate.setWindowTitle(QtGui.QApplication.translate("MainWindow", "Navigation", None, QtGui.QApplication.UnicodeUTF8))
        self.tbAddress.setWindowTitle(QtGui.QApplication.translate("MainWindow", "Address", None, QtGui.QApplication.UnicodeUTF8))
        self.actionGo.setIconText(QtGui.QApplication.translate("MainWindow", "Go", None, QtGui.QApplication.UnicodeUTF8))
        self.actionBack.setIconText(QtGui.QApplication.translate("MainWindow", "Back", None, QtGui.QApplication.UnicodeUTF8))
        self.actionBack.setShortcut(QtGui.QApplication.translate("MainWindow", "Backspace", None, QtGui.QApplication.UnicodeUTF8))
        self.actionForward.setIconText(QtGui.QApplication.translate("MainWindow", "Forward", None, QtGui.QApplication.UnicodeUTF8))
        self.actionStop.setIconText(QtGui.QApplication.translate("MainWindow", "Stop", None, QtGui.QApplication.UnicodeUTF8))
        self.actionRefresh.setIconText(QtGui.QApplication.translate("MainWindow", "Refresh", None, QtGui.QApplication.UnicodeUTF8))
        self.actionHome.setIconText(QtGui.QApplication.translate("MainWindow", "Home", None, QtGui.QApplication.UnicodeUTF8))

from PyQt4 import QtWebKit
import mainwindow_rc
