#!/usr/bin/env python

#############################################################################
## Copyright 2009 0xLab  
## Authored by Erin Yueh <erinyueh@gmail.com>
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; if not, write to the Free Software
## Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
##
#############################################################################

import sys
from PyQt4 import QtCore, QtGui, QtWebKit

ITEM_WIDTH = 300
ITEM_HEIGHT = 30

class TextItem(QtGui.QGraphicsItem):
    def __init__(self, str):
        QtGui.QGraphicsItem.__init__(self)
        #print 'str',str
        self.str1 = str[0]
        self.str2 = str[1]
        self.font1 = QtGui.QFont("Lucida Grande")
        self.font2 = QtGui.QFont("Lucida Grande")
        self.font1.setBold(True)
        self.font1.setPixelSize(ITEM_HEIGHT / 2)
        self.font2.setPixelSize(ITEM_HEIGHT / 2)
        self.offset = QtGui.QFontMetrics(self.font1).width(self.str1) + 15    
        
    def boundingRect(self):
        return QtCore.QRectF(0, 0, ITEM_WIDTH, ITEM_HEIGHT)
    
    def paint(self, painter, option, widget):
        if option.state & QtGui.QStyle.State_Selected: 
            painter.fillRect(self.boundingRect(), QtGui.QColor(0, 128, 240))
            painter.setPen(QtCore.Qt.white)
        else:
            painter.setPen(QtCore.Qt.lightGray)
            painter.drawRect(self.boundingRect())
            painter.setPen(QtCore.Qt.black)
        painter.setFont(self.font1)
        painter.drawText(QtCore.QRect(10, 0, self.offset, ITEM_HEIGHT), 
                         QtCore.Qt.AlignVCenter, self.str1)
        painter.setFont(self.font2)
        painter.drawText(QtCore.QRect(self.offset, 0, ITEM_WIDTH, ITEM_HEIGHT), 
                         QtCore.Qt.AlignVCenter, self.str2)        
                         

