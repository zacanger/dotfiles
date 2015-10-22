#!/usr/bin/env python

#############################################################################
## Copyright 2009 0xLab  
## Authored by Erin Yueh <erinyueh@gmail.com>
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
import mainwindow_rc
        
class Ui_MainWindow(object):
    
    def setupUi(self, MainWindow):
        
        MainWindow.setObjectName("MainWindow")
        MainWindow.resize(QtCore.QSize(QtCore.QRect(0,0,640,480).size()).expandedTo(MainWindow.minimumSizeHint()))
        MainWindow.setWindowTitle(QtGui.QApplication.translate("MainWindow", "Qt WebBrowser", None, QtGui.QApplication.UnicodeUTF8))
        
        self.createActions(MainWindow)
        self.createToolbars(MainWindow)
        
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
        self.WebBrowser.settings().setAttribute(QtWebKit.QWebSettings.PluginsEnabled,True)
        self.WebBrowser.setObjectName("WebBrowser")
        self.vboxlayout.addWidget(self.WebBrowser)
        self.hboxlayout.addWidget(self.Frame3)
        MainWindow.setCentralWidget(self.centralWidget)
        QtCore.QMetaObject.connectSlotsByName(MainWindow)

    def createToolbars(self,MainWindow):
        self.tbNavigate = QtGui.QToolBar(MainWindow)
        self.tbNavigate.setOrientation(QtCore.Qt.Horizontal)
        self.tbNavigate.setObjectName("tbNavigate")
        MainWindow.addToolBar(self.tbNavigate)

        self.tbAddress = QtGui.QToolBar(MainWindow)
        self.tbAddress.setOrientation(QtCore.Qt.Horizontal)
        self.tbAddress.setObjectName("tbAddress")
        MainWindow.addToolBar(self.tbAddress)
                       
        self.tbNavigate.addAction(self.actionBack)
        self.tbNavigate.addAction(self.actionForward)
        self.tbNavigate.addAction(self.actionStop)
        self.tbNavigate.addAction(self.actionRefresh)
        self.tbNavigate.addAction(self.actionHome)
        self.tbNavigate.addAction(self.actionShowBookmark)
        self.tbNavigate.addAction(self.actionAddBookmark)        
        self.tbNavigate.addAction(self.actionZoomIn)
        self.tbNavigate.addAction(self.actionZoomOut)
        self.tbNavigate.addAction(self.actionZoomNormal)
                        
        self.tbAddress.addAction(self.actionGo)
        self.tbNavigate.setWindowTitle(QtGui.QApplication.translate("MainWindow", "Navigation", None, QtGui.QApplication.UnicodeUTF8))
        self.tbAddress.setWindowTitle(QtGui.QApplication.translate("MainWindow", "Address", None, QtGui.QApplication.UnicodeUTF8))

    def createActions(self,MainWindow):
        
        self.actionGo = QtGui.QAction(MainWindow)
        self.actionGo.setIcon(QtGui.QIcon(":icons/image0.xpm"))
        self.actionGo.setObjectName("actionGo")
        self.actionGo.setIconText(QtGui.QApplication.translate("MainWindow", "Go", None, QtGui.QApplication.UnicodeUTF8))
        
        self.actionBack = QtGui.QAction(MainWindow)
        self.actionBack.setIcon(QtGui.QIcon(":icons/go-previous.png"))
        self.actionBack.setObjectName("actionBack")
        self.actionBack.setIconText(QtGui.QApplication.translate("MainWindow", "Back", None, QtGui.QApplication.UnicodeUTF8))
        self.actionBack.setShortcut(QtGui.QApplication.translate("MainWindow", "Alt+Left", None, QtGui.QApplication.UnicodeUTF8))
        
        self.actionForward = QtGui.QAction(MainWindow)
        self.actionForward.setIcon(QtGui.QIcon(":icons/go-next.png"))
        self.actionForward.setObjectName("actionForward")
        self.actionForward.setIconText(QtGui.QApplication.translate("MainWindow", "Forward", None, QtGui.QApplication.UnicodeUTF8))
        self.actionForward.setShortcut(QtGui.QApplication.translate("MainWindow", "Alt+Right", None, QtGui.QApplication.UnicodeUTF8))
        
        self.actionStop = QtGui.QAction(MainWindow)
        self.actionStop.setIcon(QtGui.QIcon(":icons/gtk-cancel.png"))
        self.actionStop.setObjectName("actionStop")
        self.actionStop.setIconText(QtGui.QApplication.translate("MainWindow", "Stop", None, QtGui.QApplication.UnicodeUTF8))
        self.actionStop.setShortcut(QtGui.QApplication.translate("MainWindow", "Esc", None, QtGui.QApplication.UnicodeUTF8))        

        self.actionRefresh = QtGui.QAction(MainWindow)
        self.actionRefresh.setIcon(QtGui.QIcon(":icons/gtk-refresh.png"))
        self.actionRefresh.setObjectName("actionRefresh")
        self.actionRefresh.setIconText(QtGui.QApplication.translate("MainWindow", "Refresh", None, QtGui.QApplication.UnicodeUTF8))
        self.actionRefresh.setShortcut(QtGui.QApplication.translate("MainWindow", "Ctrl+R", None, QtGui.QApplication.UnicodeUTF8))        

        self.actionHome = QtGui.QAction(MainWindow)
        self.actionHome.setIcon(QtGui.QIcon(":icons/go-home.png"))
        self.actionHome.setObjectName("actionHome")
        self.actionHome.setIconText(QtGui.QApplication.translate("MainWindow", "Home", None, QtGui.QApplication.UnicodeUTF8))
        self.actionHome.setShortcut(QtGui.QApplication.translate("MainWindow", "Alt+Home", None, QtGui.QApplication.UnicodeUTF8))
        
        self.actionShowBookmark = QtGui.QAction(MainWindow)
        self.actionShowBookmark.setIcon(QtGui.QIcon(":icons/show_all_bookmark.png"))
        self.actionShowBookmark.setObjectName("actionShowBookmark")
        self.actionShowBookmark.setIconText(QtGui.QApplication.translate("MainWindow", "Show all bookmarks", None, QtGui.QApplication.UnicodeUTF8))
        
        self.actionAddBookmark = QtGui.QAction(MainWindow)
        self.actionAddBookmark.setIcon(QtGui.QIcon(":icons/bookmark-new.png"))
        self.actionAddBookmark.setObjectName("actionAddBookmark")
        self.actionAddBookmark.setIconText(QtGui.QApplication.translate("MainWindow", "Add a bookmark", None, QtGui.QApplication.UnicodeUTF8))
         
        self.actionZoomIn = QtGui.QAction(MainWindow)
        self.actionZoomIn.setIcon(QtGui.QIcon(":icons/stock_zoom-in.png"))
        self.actionZoomIn.setObjectName("actionZoomIn")
        self.actionZoomIn.setIconText(QtGui.QApplication.translate("MainWindow", "Zoom In", None, QtGui.QApplication.UnicodeUTF8))
        self.actionZoomIn.setShortcut(QtGui.QApplication.translate("MainWindow", "Ctrl++", None, QtGui.QApplication.UnicodeUTF8))        
       
        self.actionZoomNormal = QtGui.QAction(MainWindow)
        self.actionZoomNormal.setIcon(QtGui.QIcon(":icons/stock_zoom-1.png"))
        self.actionZoomNormal.setObjectName("actionZoomNormal")        
        self.actionZoomNormal.setIconText(QtGui.QApplication.translate("MainWindow", "Fit-in Page", None, QtGui.QApplication.UnicodeUTF8))
        self.actionZoomNormal.setShortcut(QtGui.QApplication.translate("MainWindow", "Ctrl+0", None, QtGui.QApplication.UnicodeUTF8))        
       
        self.actionZoomOut = QtGui.QAction(MainWindow)
        self.actionZoomOut.setIcon(QtGui.QIcon(":icons/stock_zoom-out.png"))
        self.actionZoomOut.setObjectName("actionZoomOut")
        self.actionZoomOut.setIconText(QtGui.QApplication.translate("MainWindow", "Zoom Out", None, QtGui.QApplication.UnicodeUTF8))
        self.actionZoomOut.setShortcut(QtGui.QApplication.translate("MainWindow", "Ctrl+-", None, QtGui.QApplication.UnicodeUTF8))        

