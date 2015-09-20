#!/usr/bin/env python

#############################################################################
## Authored by Akos Polster
## http://code.google.com/p/flickcharm-python/
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

import copy
from PyQt4.QtCore import *
from PyQt4.QtGui import *
from PyQt4.QtWebKit import *
import sys

class FlickData:
    
    Steady = 0
    Pressed = 1
    ManualScroll = 2
    AutoScroll = 3
    Stop = 4
    
    def __init__(self):
        self.state = FlickData.Steady
        self.widget = None
        self.pressPos = QPoint(0, 0)
        self.offset = QPoint(0, 0)
        self.dragPos = QPoint(0, 0)
        self.speed = QPoint(0, 0)
        self.ignored = []


class FlickCharmPrivate:
    
    def __init__(self):
        self.flickData = {}
        self.ticker = QBasicTimer()


class FlickCharm(QObject):
    
    def __init__(self, parent = None):
        QObject.__init__(self, parent)
        self.d = FlickCharmPrivate()
        
    
    def activateOn(self, widget):
        if isinstance(widget, QWebView):
            frame = widget.page().mainFrame()
            frame.setScrollBarPolicy(Qt.Vertical, Qt.ScrollBarAlwaysOff)
            frame.setScrollBarPolicy(Qt.Horizontal, Qt.ScrollBarAlwaysOff)
            widget.installEventFilter(self)
            self.d.flickData[widget] = FlickData()
            self.d.flickData[widget].widget = widget
            self.d.flickData[widget].state = FlickData.Steady
        else:
            widget.setHorizontalScrollBarPolicy(Qt.ScrollBarAlwaysOff)
            widget.setVerticalScrollBarPolicy(Qt.ScrollBarAlwaysOff)
            viewport = widget.viewport()
            viewport.installEventFilter(self)
            widget.installEventFilter(self)
            self.d.flickData[viewport] = FlickData()
            self.d.flickData[viewport].widget = widget
            self.d.flickData[viewport].state = FlickData.Steady

    
    def deactivateFrom(self, widget):
        if isinstance(widget, QWebView):
            widget.removeEventFilter(self)
            del(self.d.flickData[widget])
        else:
            viewport = widget.viewport()
            viewport.removeEventFilter(self)
            widget.removeEventFilter(self)
            del(self.d.flickData[viewport])

    
    def eventFilter(self, object, event):
        
        if not object.isWidgetType():
            return False;
    
        eventType = event.type()
        if eventType != QEvent.MouseButtonPress and \
           eventType != QEvent.MouseButtonRelease and \
           eventType != QEvent.MouseMove:
            return False
    
        if event.modifiers() != Qt.NoModifier:
            return False
    
        if not self.d.flickData.has_key(object):
            return False
        
        data = self.d.flickData[object]
        found, newIgnored = removeAll(data.ignored, event)
        if found:
            data.ignored = newIgnored
            return False
    
        consumed = False
        
        if data.state == FlickData.Steady:
            if eventType == QEvent.MouseButtonPress:
                if event.buttons() == Qt.LeftButton:
                    consumed = True
                    data.state = FlickData.Pressed
                    data.pressPos = copy.copy(event.pos())
                    data.offset = scrollOffset(data.widget)
        
        elif data.state == FlickData.Pressed:
            if eventType == QEvent.MouseButtonRelease:
                consumed = True
                data.state = FlickData.Steady
                event1 = QMouseEvent(QEvent.MouseButtonPress,
                                     data.pressPos, Qt.LeftButton,
                                     Qt.LeftButton, Qt.NoModifier)
                event2 = QMouseEvent(event)
                data.ignored.append(event1)
                data.ignored.append(event2)
                QApplication.postEvent(object, event1)
                QApplication.postEvent(object, event2)
            elif eventType == QEvent.MouseMove: 
                consumed = True
                data.state = FlickData.ManualScroll
                data.dragPos = QCursor.pos()
                if not self.d.ticker.isActive():
                    self.d.ticker.start(20, self)
    
        elif data.state == FlickData.ManualScroll:
            if eventType == QEvent.MouseMove:
                consumed = True
                pos = event.pos()
                delta = pos - data.pressPos
                setScrollOffset(data.widget, data.offset - delta)
            elif eventType == QEvent.MouseButtonRelease: 
                consumed = True
                data.state = FlickData.AutoScroll
    
        elif data.state == FlickData.AutoScroll:
            if eventType == QEvent.MouseButtonPress:
                consumed = True
                data.state = FlickData.Stop
                data.speed = QPoint(0, 0)
            elif eventType == QEvent.MouseButtonRelease:
                consumed = True
                data.state = FlickData.Steady
                data.speed = QPoint(0, 0)
    
        elif data.state == FlickData.Stop:
            if eventType == QEvent.MouseButtonRelease:
                consumed = True
                data.state = FlickData.Steady
            elif eventType == QEvent.MouseMove:
                consumed = True
                data.state = FlickData.ManualScroll
                data.dragPos = QCursor.pos()
                if not self.d.ticker.isActive():
                    self.d.ticker.start(20, self)
    
        return consumed

    
    def timerEvent(self, event):
        count = 0
        for data in self.d.flickData.values():
            if data.state == FlickData.ManualScroll:
                count += 1
                cursorPos = QCursor.pos()
                data.speed = cursorPos - data.dragPos
                data.dragPos = cursorPos    
            elif data.state == FlickData.AutoScroll:
                count += 1
                data.speed = deaccelerate(data.speed)
                p = scrollOffset(data.widget)
                setScrollOffset(data.widget, p - data.speed)
                if data.speed == QPoint(0, 0):
                    data.state = FlickData.Steady
    
        if count == 0:
            self.d.ticker.stop()
    
        QObject.timerEvent(self, event);
    
    
def scrollOffset(widget):
    if isinstance(widget, QWebView):
        frame = widget.page().mainFrame()
        x = frame.evaluateJavaScript("window.scrollX").toInt()[0]
        y = frame.evaluateJavaScript("window.scrollY").toInt()[0]
    else:
        x = widget.horizontalScrollBar().value()
        y = widget.verticalScrollBar().value()
    return QPoint(x, y)
        
        
def setScrollOffset(widget, p):
    if isinstance(widget, QWebView):
        frame = widget.page().mainFrame()
        frame.evaluateJavaScript("window.scrollTo(%d,%d);" % (p.x(), p.y()))
    else:
        widget.horizontalScrollBar().setValue(p.x())
        widget.verticalScrollBar().setValue(p.y())
      

def deaccelerate(speed, a=1, maxVal=64):
    x = qBound(-maxVal, speed.x(), maxVal)
    y = qBound(-maxVal, speed.y(), maxVal)
    if x > 0:
        x = max(0, x - a)
    elif x < 0:
        x = min(0, x + a)
    if y > 0:
        y = max(0, y - a)
    elif y < 0:
        y = min(0, y + a)
    return QPoint(x, y)


def qBound(minVal, current, maxVal):
    return max(min(current, maxVal), minVal)
    

def removeAll(list, val):
    found = False
    ret = []
    for element in list:
        if element == val:
            found = True
        else:
            ret.append(element)
    return (found, ret)
