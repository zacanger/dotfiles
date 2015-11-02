#!/usr/bin/env python
# -*- coding: utf-8 -*-

# PyQt specific
import os
import string
from PyQt4 import QtGui, QtCore
#import generic_highlighter
from HL import genericHighlighter

APPLIREP = os.getcwd()
SYNTAXES = os.path.join(APPLIREP, 'Schemes/')

class Editor(QtGui.QTextEdit):

    ## CODECS
    _codecs = { "utf8"  : "UTF-8",
                "Latin1": "ISO 8859-1",
                "Latin2": "ISO 8859-2",
                "CP1252": "Windows-1252",
                    }

    _occurences = 0
    NextId = 1

    def __init__(self, filename=QtCore.QString(), parent=None):
        QtGui.QTextEdit.__init__(self, parent)
        self.parent = parent

        self.filename = filename
        if self.filename.isEmpty():
            self.filename = QtCore.QString("Unnamed-%d.txt" % Editor.NextId)
            Editor.NextId += 1

        self.setWindowTitle(QtCore.QFileInfo(self.filename).fileName())

        ## EXTENSION MANAGEMENT
        self.default_extension = '.py'
        self.setAcceptRichText(False)


        #self.doc = QtGui.QTextDocument(self)
        self.tab_long = 4
        self.setTabEditorWidth(self.tab_long)

        self.line_col = QtGui.QColor("#502F2F")
        self.limit_color = QtGui.QColor("#C0000F")

        ## context :
        self.context = None

        ## file management
        self.file = QtCore.QFile()
        #localCodec = QtCore.QTextCodec.codecForLocale()
        #self.codec = Editor._codecs["utf8"]
        def_encode = self.parent.def_encoding.toString()
        self.codec = Editor._codecs[unicode(def_encode)]
        #self.codec = localCodec
        self.bom = True

        ## highlighter
        self.highlighter = None
        self.findHighlighter()

        #self.setLineWrapMode(QtGui.QTextEdit.FixedColumnWidth)
        #self.setLineWrapColumnOrWidth(78)
        self.indent = 0

        ## Callbacks for paintEvent in plugins
        self.paint_callbacks=[]

        ## Customizations : show spaces, hilight current line, limit line
        self.showSpaces = False
        self.highlightCurrentLine = 0
        self.LimitLine = 79

        self.applyDefaultSettings()

        ## SIGNALS-SLOTS
        # for paintEvent
        self.connect( self.verticalScrollBar(),
                    QtCore.SIGNAL( "valueChanged(int)" ),
                    QtCore.SLOT("update()") )
        self.connect( self,
                    QtCore.SIGNAL( "textChanged()" ),
                    QtCore.SLOT("update()") )

        # for indent/unident


        #QtGui.QShortcut(QtGui.QKeySequence("Alt+P"), self, self.upCursors)

    ## =========================
    ## Encoding management
    ## =========================
    def set_Codec(self, codec):
        self.codec = codec

    def bomChanged(self):
        self.bom = not(self.bom)
    ## =========================
    ## Contexts management
    ## =========================
    def getContext(self):
        ext = self.get_fileExtension()
        return ext

    def closeEvent(self, event):
        if self.document().isModified() and \
           QtGui.QMessageBox.question(self,
                   "Text Editor - Unsaved Changes",
                   "Save unsaved changes in %s?" % self.filename,
                   QtGui.QMessageBox.Yes|QtGui.QMessageBox.No) == \
                QtGui.QMessageBox.Yes:
            try:
                self.save()
            except (IOError, OSError), e:
                QtGui.QMessageBox.warning(self, "Text Editor -- Save Error",
                        "Failed to save %s: %s" % (self.filename, e))

    def isModified(self):
        return self.document().isModified()
    ## =========================
    ## File management
    ## =========================
    def ensureDocumentIsSaved(self, event=None):
        if self.document().isModified():
            reply = QtGui.QMessageBox.question(self,
                    "SnipIt! - Unsaved Changes",
                    "Save unsaved changes in %s" % self.get_fileName(),
                    QtGui.QMessageBox.Save|QtGui.QMessageBox.Discard|
                    QtGui.QMessageBox.Cancel)
            if reply == QtGui.QMessageBox.Save:
                self.save()
            elif reply == QtGui.QMessageBox.Cancel:
                event.ignore()
                return

    def load(self, codecGiven= None):
        codec = codecGiven if codecGiven else self.codec
        exception = None
        fh = None
        try:
            fh = QtCore.QFile(self.filename)
            if not fh.open(QtCore.QIODevice.ReadOnly):
                raise IOError, unicode(fh.errorString())
            stream = QtCore.QTextStream(fh)
            stream.setCodec(self.codec)
            #stream.setCodec("UTF-8")
            self.setPlainText(stream.readAll())
            self.document().setModified(False)
            self.findHighlighter()
        except (IOError, OSError), e:
            exception = e
        finally:
            if fh is not None:
                fh.close()
            if exception is not None:
                raise exception

    def save(self, codecGiven= None):
        codec = codecGiven if codecGiven else self.codec
        if self.filename.startsWith("Unnamed"):
            filename = QtGui.QFileDialog.getSaveFileName(self,
                            "Text Editor -- Save File As",
                            self.filename, "Text files (*.txt *.*)")
            if filename.isEmpty():
                return
            self.filename = filename
        self.setWindowTitle(QtCore.QFileInfo(self.filename).fileName())
        exception = None
        fh = None
        try:
            fh = QtCore.QFile(self.filename)
            if not fh.open(QtCore.QIODevice.WriteOnly):
                raise IOError, unicode(fh.errorString())
            stream = QtCore.QTextStream(fh)
            stream.setCodec(codec)
            stream << self.toPlainText()
            self.document().setModified(False)
            self.findHighlighter()
        except (IOError, OSError), e:
            exception = e
        finally:
            if fh is not None:
                fh.close()
            if exception is not None:
                raise exception

    def saveFile(self, fileName):
        file = QtCore.QFile(fileName)
        if not file.open(QtCore.QFile.WriteOnly | QtCore.QFile.Text):
            QtGui.QMessageBox.warning(self, self.tr("Application"),
                        self.tr("Cannot write file %1:\n%2.").arg(fileName).arg(file.errorString()))
            return False

        outf = QtCore.QTextStream(file)
        outf.setCodec(self.codec)
        outf.setGenerateByteOrderMark(self.bom)

        QtGui.QApplication.setOverrideCursor(QtCore.Qt.WaitCursor)
        outf << self.toPlainText()
        QtGui.QApplication.restoreOverrideCursor()
        self.file = file

        self.statusBar().showMessage("File %s saved with codec %s and bom %s"%(self.getEditor().get_fileBaseName(),self.codec, self.bom), 2000)
        self.document().setModified(False)

        self.findHighlighter()
        self.setupCommands()
        self.emit(QtCore.SIGNAL("plugNeedsUpdate()"))
        self.parent.tabWidget_files.setTabText(self.current_tab,self.get_realFileName())
        #self.needBomCheckBox()
        return True

    def codecsChanged(self, choix):
        choice = Editor._codecs[unicode(choix)]
        self.statusBar().showMessage("Codec changed to %s"%(choice))
        self.codec = choice
        file = self.get_fileName()
        ## Now we load the file in choosen encoding
        if file.isEmpty() :
            pass
        else:
            self.loadFile(file)

        #self.needBomCheckBox()
    ## =========================
    ## File and directory names
    ## =========================
    def get_fileDir(self):
        """ if file is '/home/my_name/foo.py'
        return '/home/my_name'
        """
        return QtCore.QFileInfo(self.filename).absolutePath()

    def get_fileName(self):
        """If file is '/home/my_name/foo.py'
        returns /home/my_name/foo.py
        """
        return self.filename

    def get_fileExtension(self, withPoint=True):
        """If file is '/home/my_name/foo.py'
        returns '.py'
        """
        pt = ''
        if withPoint :
            pt = '.'

        return pt + QtCore.QFileInfo(self.filename).suffix()

    def get_fileBaseName(self):
        """ if file is '/home/my_name/foo.py'
        return 'foo'
        """
        return QtCore.QFileInfo(self.filename).baseName()

    def get_realFileName(self):
        """If file is '/home/my_name/foo.py'
        returns 'foo.py'
        """
        return QtCore.QFileInfo(self.filename).baseName() + self.get_fileExtension()

    ## =========================
    ##  Customizing : spaces-fonts
    ## =========================
    def toogleWhiteSpaces(self):
        if self.showSpaces :
            self.showSpaces = False
        else :
            self.showSpaces = True

    def setTabEditorWidth(self,tw):
        self.setTabStopWidth( self.fontMetrics().width( "x" ) * tw )

    ## Text editing
    def getCursorPosition(self, para, index):
        i = 0
        p = self.document().begin()
        while p.isValid() :
            if para == i :
                break
            i += 1
            p = p.next()
        return p.position()+index

    def setCursorPosition(self, para, index):
        pos = self.getCursorPosition(para,index)
        cur = self.textCursor()
        cur.setPosition(pos,QtGui.QTextCursor.MoveAnchor)
        self.setTextCursor(cur)
        self.ensureCursorVisible()
        self.setFocus()

    def numberOfLines(self):
        return self.document().blockCount()

    def gotoLine(self,line):
        #if line <= self.numberOfLines():
        self.setCursorPosition(line, 0)

    """More "algorithmically", insert n spaces on the left of
    each the line of the selection, and, reversely, to remove n but only if each
    line has (still) n spaces on its left or is blank (n=indentation spaces)
    """

    ## ===== Taken from Mark Summerfield's SanBox application
    def _walkTheLines(self, insert, text):
        userCursor = self.textCursor()
        userCursor.beginEditBlock()
        start = userCursor.position()
        end = userCursor.anchor()
        if start > end:
            start, end = end, start
        block = self.document().findBlock(start)
        while block.isValid():
            cursor = QtGui.QTextCursor(block)
            cursor.movePosition(QtGui.QTextCursor.StartOfBlock)
            if insert:
                cursor.insertText(text)
            else:
                cursor.movePosition(QtGui.QTextCursor.NextCharacter,
                        QtGui.QTextCursor.KeepAnchor, len(text))
                if cursor.selectedText() == text:
                    cursor.removeSelectedText()
            block = block.next()
            if block.position() > end:
                break
        userCursor.endEditBlock()

    def indentRegion(self):
        self._walkTheLines(True, " " * self.tab_long)

    def unindentRegion(self):
        self._walkTheLines(False, " " * self.tab_long)

    ## ===== end of M.S SanBox application

    def getLineNumber(self):
        return self.textCursor().blockNumber() + 1

    def getColumnNumber(self):
        return self.textCursor().columnNumber() + 1

    def getlineNumberFromBlock(self, b):
        lineNumber = 1;
        block = self.document().begin()
        while block.isValid() and block != b:
            lineNumber += 1
            block = block.next()
        return lineNumber + 1

    def selectLines(self, debut, fin):
        if debut > fin :
            debut, fin = fin, debut
        c = self.textCursor()
        c.movePosition(QtGui.QTextCursor.Start )
        c.movePosition(QtGui.QTextCursor.Down, QtGui.QTextCursor.MoveAnchor, debut-1 )
        c.movePosition(QtGui.QTextCursor.Down, QtGui.QTextCursor.KeepAnchor, fin-debut+1 )
        self.setTextCursor( c )
        self.ensureCursorVisible()

    ## ================== Ctrl+ MouseWheel for changing font size
    def wheelEvent(self, e):
        if e.modifiers() and QtCore.Qt.ControlModifier :
            delta = e.delta()
            if delta > 0:
                self.zoomOut(1)
            elif delta < 0:
                self.zoomIn(1)
            #self.parent.viewport().update()
            return
        QtGui.QAbstractScrollArea.wheelEvent(self,e)
        self.updateMicroFocus()
        #self.viewport().update()

    def currentLine(self):
        """Return the current edited line
        """
        cursor = self.textCursor()
        cursor.movePosition(QtGui.QTextCursor.StartOfLine)
        cursor.movePosition(QtGui.QTextCursor.EndOfLine, QtGui.QTextCursor.KeepAnchor)
        return cursor.selectedText()

    def findHighlighter(self, extGiven=False):
        """Tries to guess the highlighting from
        the extension.
        """
        ext = unicode(self.get_fileExtension(withPoint=False))
        lang = SYNTAXES + self.parent.guessLangage(ext).lower() + '_scheme.xml'
        if self.highlighter :
            self.highlighter.changeRules(lang)
        else:
            self.highlighter = genericHighlighter(self, lang)
        self.highlighter.rehighlight()

    ## ======================================== Settings
    def applyDefaultSettings(self):
        self.applySettings('#444031','#DBD6C1','DejaVu Sans Mono',11,'#CE5C00','#2E3436')
        #self.applySettings('#444031','#DBD6C1','DejaVu Sans Mono',11,'#CE5C00','#2E3436')

    def applySettings(self,fgcolor,bgcolor,fontfam,fontsize,lfgcolor,lbgcolor):

        palette = QtGui.QPalette()

        # Palette
        brush = QtGui.QBrush(QtGui.QColor(fgcolor))
        brush.setStyle(QtCore.Qt.SolidPattern)
        palette.setBrush(QtGui.QPalette.Active,QtGui.QPalette.Text,brush)

        brush = QtGui.QBrush(QtGui.QColor(bgcolor))
        brush.setStyle(QtCore.Qt.SolidPattern)
        palette.setBrush(QtGui.QPalette.Active,QtGui.QPalette.Base,brush)

        brush = QtGui.QBrush(QtGui.QColor(fgcolor))
        brush.setStyle(QtCore.Qt.SolidPattern)
        palette.setBrush(QtGui.QPalette.Inactive,QtGui.QPalette.Text,brush)

        brush = QtGui.QBrush(QtGui.QColor(bgcolor))
        brush.setStyle(QtCore.Qt.SolidPattern)
        palette.setBrush(QtGui.QPalette.Inactive,QtGui.QPalette.Base,brush)

        brush = QtGui.QBrush(QtGui.QColor(180,180,180))
        brush.setStyle(QtCore.Qt.SolidPattern)
        palette.setBrush(QtGui.QPalette.Active,QtGui.QPalette.Highlight,brush)

        brush = QtGui.QBrush(QtGui.QColor(0,0,0))
        brush.setStyle(QtCore.Qt.SolidPattern)
        palette.setBrush(QtGui.QPalette.Active,QtGui.QPalette.HighlightedText,brush)

        brush = QtGui.QBrush(QtGui.QColor(180,180,180))
        brush.setStyle(QtCore.Qt.SolidPattern)
        palette.setBrush(QtGui.QPalette.Inactive,QtGui.QPalette.Highlight,brush)

        brush = QtGui.QBrush(QtGui.QColor(170,250,124))
        brush.setStyle(QtCore.Qt.SolidPattern)
        palette.setBrush(QtGui.QPalette.Inactive,QtGui.QPalette.HighlightedText,brush)

        brush = QtGui.QBrush(QtGui.QColor(217,217,217))
        brush.setStyle(QtCore.Qt.SolidPattern)
        palette.setBrush(QtGui.QPalette.Disabled,QtGui.QPalette.Highlight,brush)

        brush = QtGui.QBrush(QtGui.QColor(255,255,255))
        brush.setStyle(QtCore.Qt.SolidPattern)
        palette.setBrush(QtGui.QPalette.Disabled,QtGui.QPalette.HighlightedText,brush)

        self.setPalette(palette)

        font = QtGui.QFont()
        font.setFamily(fontfam)
        font.setPointSize(fontsize)
        self.setFont(font)
        self.setAcceptRichText(False)
#        if self.highlighter :
#            self.parent.lines.fg_color = QtGui.QColor(lfgcolor)
#            self.parent.lines.applyBackgroundColor(QtGui.QColor(lbgcolor))

    def numoflines(self):
        """Returns the number of lines in text.
        Needed by Linenumberwidget"""
        num=0
        p = QtGui.QTextBlock()
        p = self.document().begin()
        while p.isValid() :
            num += 1
            p = p.next()
        return num

    def paintEvent(self, event):

        painter = QtGui.QPainter(self.viewport())

        # CurrentLine background
        if self.highlightCurrentLine:
            r = self.cursorRect()
            r.setX(0) #Sets the left edge of the rectangle to the given coordinate.
            r.setWidth( self.viewport().width() )

            painter.fillRect( r, QtGui.QBrush( self.line_col ) )
            painter.setPen( self.limit_color )
            painter.drawRect( r )

            #painter.setPen( self.limit_color )
            #painter.drawRoundRect ( r )

        # LimitLine
        if self.LimitLine > 0:
            x = ( QtGui.QFontMetrics( self.font() ).width( "X" ) * self.LimitLine ) - self.horizontalScrollBar().value()
            painter.setPen( self.limit_color )
            painter.drawLine( x, painter.window().top(), x, painter.window().bottom() )
        painter.end()

        # Tabs and spaces
        if self.showSpaces :
            self.printWhiteSpaces(event)

        # Callbacks from plugins
        if self.paint_callbacks :
            for pc in self.paint_callbacks:
                pc.paint(event)

        QtGui.QTextEdit.paintEvent(self,event)


    def printWhiteSpaces(self, e):
        # @param e : the event transmitted to the painEvent
        # p is our painter from paintEvent
        p = QtGui.QPainter(self.viewport())
        qp = QtGui.QPixmap("Images/pixmaps/spaces.png")
        contentsY = self.verticalScrollBar().value()
        pageBottom = contentsY + self.viewport().height()
        fm = QtGui.QFontMetrics(self.font())

        doc = self.document()
        block = doc.begin()

        while block.isValid() :

            layout = block.layout()
            boundingRect = layout.boundingRect()
            position = layout.position()

            if position.y() + boundingRect.height() < contentsY :
                block = block.next()
                continue
            if position.y() > pageBottom :
                break

            txt = block.text()
            tlen = txt.length()

            for i in range(tlen):
                cursor = self.textCursor()
                cursor.setPosition( block.position() + i, QtGui.QTextCursor.MoveAnchor)
                r = self.cursorRect(cursor)

                if txt[i] in [' ','\t']:
                    p1 = qp
                else:
                    continue
#                # draw with pixmaps
#                x = r.x() + 4
#                y = r.y() + fm.height() / 2 - 5
#                p.drawPixmap( x, y, p1 )

                x = r.x() + fm.width("X")
                y = r.y() + fm.height()/2.
                p.drawPoint(x,y)

            block = block.next()

        p.end()


if __name__ == "__main__":
    pass
