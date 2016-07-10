#!/usr/bin/env python2.7

#############################################################################
## Copyright 2009 0xLab  
## Authored by Erin Yueh <erinyueh@gmail.com>
##
## Copyright (C) 1992-2009 Trolltech ASA. All rights reserved.
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
from ui_mainwindow import Ui_MainWindow
from flickcharm import *
import bookmark 
from ui_bookmark import *

ITEM_WIDTH = 300
ITEM_HEIGHT = 30


class GraphicsView(QtGui.QGraphicsView):
    def __init__(self,mainwindow):
        QtGui.QGraphicsView.__init__(self)
        self.mainwindow = mainwindow
        self.reloadTimer = QtCore.QTimer(self)
        self.connect(self.reloadTimer, QtCore.SIGNAL("timeout()"),
                     self.redisplayWindow)
        self.reloadTimer.setSingleShot(True)
        
    def mouseReleaseEvent(self, event):
        #print 'mouse Release event'
        QtGui.QGraphicsView.mouseReleaseEvent(self, event) 
    
    def redisplayWindow(self):
        #print 'reload URL'
        self.mainwindow.WebBrowser.load(QtCore.QUrl(self.reloadbookmark[1]))
        
    def mousePressEvent(self, event):
        #print 'mouse Press event'
        item = self.itemAt(event.pos())
        #print 'bookmark: ',self.mainwindow.booklist[int(item.zValue())]
        bookmark = self.mainwindow.booklist[int(item.zValue())]
        self.reloadTimer.start(300)    
        self.reloadbookmark = bookmark
        QtGui.QGraphicsView.mousePressEvent(self, event) 
        
    def mouseDoubleClickEvent(self, event):
        #print 'mouseDoubleClick event'
        if self.reloadTimer and self.reloadTimer.isActive():
            #print 'kill event'
            self.reloadTimer.stop()
        item = self.itemAt(event.pos())
        #print 'bookmark: ',self.mainwindow.booklist[int(item.zValue())]
        data = self.mainwindow.booklist[int(item.zValue())]
        # delete a bookmark
        del self.mainwindow.booklist[int(item.zValue())]
        bookmark.delete(self.mainwindow.db,{'title':data[0],'url':data[1]})
        for item in self.scene().items():
            self.scene().removeItem(item)
        i = 0
        for c in self.mainwindow.booklist:
            item = TextItem(c)
            self.scene().addItem(item)
            item.setPos(0, i * ITEM_HEIGHT)
            item.setZValue(i)
            item.setFlag(QtGui.QGraphicsItem.ItemIsSelectable, True)
            i += 1
        
                   
class MainWindow(QtGui.QMainWindow, Ui_MainWindow):
    # Maintain the list of browser windows so that they do not get garbage
    # collected.
    _window_list = []

    def __init__(self):
        QtGui.QMainWindow.__init__(self)

        MainWindow._window_list.append(self)
        # finger scrolling effect
        self.charm = FlickCharm()
        
        # create bookmark window
        self.db = bookmark.connect()
        if self.db:
            self.booklist = bookmark.read(self.db)

        self.bookview = GraphicsView(self)
        self.scene = QtGui.QGraphicsScene()
        self.scene.setItemIndexMethod(QtGui.QGraphicsScene.NoIndex)
        i = 0
        for c in self.booklist:
            item = TextItem(c)
            self.scene.addItem(item)
            item.setPos(0, i * ITEM_HEIGHT)
            item.setZValue(i)
            item.setFlag(QtGui.QGraphicsItem.ItemIsSelectable, True)
            i += 1
        
        self.scene.setItemIndexMethod(QtGui.QGraphicsScene.BspTreeIndex)
        self.bookview.setScene(self.scene)
        self.bookview.setRenderHints(QtGui.QPainter.TextAntialiasing)
        self.bookview.setFrameShape(QtGui.QFrame.NoFrame)
        self.bookview.setWindowTitle("Bookmark List")
        self.charm.activateOn(self.bookview)
        
        # create web window
        self.setupUi(self)
        self.charm.activateOn(self.WebBrowser)
        
        self.lblAddress = QtGui.QLabel("", self.tbAddress)
        self.tbAddress.insertWidget(self.actionGo, self.lblAddress)
        self.addressEdit = QtGui.QLineEdit(self.tbAddress)
        self.tbAddress.insertWidget(self.actionGo, self.addressEdit)
        
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
    def on_actionZoomIn_triggered(self):
        #print "on_actionZoomIn_triggered"
        current = self.WebBrowser.textSizeMultiplier()
        self.WebBrowser.setTextSizeMultiplier(current+0.1)
        
    @QtCore.pyqtSignature("")
    def on_actionZoomOut_triggered(self):
        #print "on_actionZoomOut_triggered"
        current = self.WebBrowser.textSizeMultiplier()
        self.WebBrowser.setTextSizeMultiplier(current-0.1)

        
    @QtCore.pyqtSignature("")
    def on_actionZoomNormal_triggered(self):
        #print "on_actionZoomNormal_triggered"
        self.WebBrowser.setTextSizeMultiplier(1.0)

    @QtCore.pyqtSignature("")
    def on_actionShowBookmark_triggered(self):
        #print "on_actionShowBookmark_triggered"
        self.bookview.show()
        temp = bookmark.refresh(self.db)
        
    @QtCore.pyqtSignature("")
    def on_actionAddBookmark_triggered(self):
        #print "on_actionAddBookmark_triggered"
        url = self.WebBrowser.url().toString()
        title = self.WebBrowser.title()
        data = (unicode(title),unicode(url))
        bookmark.add(self.db,data)
        item = TextItem(data)
        item.setPos(0, len(self.booklist) * ITEM_HEIGHT)
        item.setZValue(len(self.booklist))
        item.setFlag(QtGui.QGraphicsItem.ItemIsSelectable, True)
        self.booklist.append(data)
        self.scene.addItem(item)    
        self.scene.update()
       
    @QtCore.pyqtSignature("")
    def on_actionHome_triggered(self):
        #print "on_actionHome_triggered"
        self.WebBrowser.load(QtCore.QUrl("http://www.google.com"))
        self.addressEdit.setText("http://www.google.com")


if __name__ == "__main__":

    app = QtGui.QApplication(sys.argv)
    mainWindow = MainWindow()
    mainWindow.show()
    sys.exit(app.exec_())
