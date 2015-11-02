#!/usr/bin/env python
# -*- coding: utf-8 -*-
import os
from plugins import IPlugin
from PyQt4 import QtGui, QtCore
from Tables.ui_arraydialog import Ui_ArrayDialog

class tablesPlugin(IPlugin):
    infos = {'name': 'tablesPlugin',
            'author': 'Kibleur Christophe',
            'version': '0.0.1',
            'website':'http://kib2.free.fr/PyEdit/',
                }
    count = 0

    def __init__(self, parent):
        IPlugin.__init__(self,parent)

    def activate(self):
        self._plugContext = '.rst'
        # Add the plugin to the Menu
        act = QtGui.QAction(self.parent)
        act.setText("Create a table")
        act.setShortcut("Ctrl+Alt+T")
        act.setIcon(QtGui.QIcon(":/Images/crystal/plugins/RNA_32.png"))

        self.parent.connect(act, QtCore.SIGNAL("triggered()"), self.tableCreate)
        self.parent.menuPlugins.addAction(act)
        self.parent.registerActionShortCut(act)

    def tableCreate(self):
        """ This function creates a QTableWidgetItem out of a 2-dimension nested list which contains numbers, and then uses it to "paint" the someTbl object, which is a QTableWidget """
        if self.parent.getEditor().get_fileExtension() != self._plugContext:
            self.parent.Attention("The Table plugin can only be accessed from a reStructuredText file.")
            return

        dial = QtGui.QDialog(self.parent)
        dial.setWindowTitle("Table creator")
        self.tabledialog = dial
        self.tbl_dial = Ui_ArrayDialog()
        self.tbl_dial.setupUi(dial)


        #ArrayDialog.show()
        tbl = self.tbl_dial.tableWidget
        col = self.tbl_dial.spinBoxColumns
        lin = self.tbl_dial.spinBoxRows
        but = self.tbl_dial.okButton

        # Connexions
        self.parent.connect(col, QtCore.SIGNAL("valueChanged(int)"), self.actualiseTable)
        self.parent.connect(lin, QtCore.SIGNAL("valueChanged(int)"), self.actualiseTable)
        #dial.connect(but, QtCore.SIGNAL("cliked()"), self.insertRestTable)
        QtCore.QObject.connect(but,QtCore.SIGNAL("clicked()"),self.insertRestTable)
        tbl.setColumnCount(col.value())
        tbl.setRowCount(lin.value())

        dial.show()

    def actualiseTable(self, int_number):
        tbl = self.tbl_dial.tableWidget
        col = self.tbl_dial.spinBoxColumns
        lin = self.tbl_dial.spinBoxRows

        tbl.setColumnCount(col.value())
        tbl.setRowCount(lin.value())

    def insertRestTable(self):
        lines = self.tbl_dial.tableWidget.rowCount()
        cols = self.tbl_dial.tableWidget.columnCount()
        mylist = []
        for col in range(cols) :
            poorlist=[]
            for line in range(lines) :
                try :
                    text = self.tbl_dial.tableWidget.item(line,col).text()
                except:
                    text = ''
                truc = unicode(text)
                poorlist.append(truc)
            mylist.append(poorlist)
        self.traiteListe(mylist)
        self.tabledialog.close()

    def traiteListe(self, laliste):
        # see new changes in Python 2.5 max function
        # http://www.onlamp.com/pub/a/python/2006/10/26/python-25.html?page=3
        output = []

        def myord(astr):
            return len(astr)

        nbr_lines = len(laliste[0])
        for lin in range(nbr_lines):
            textcell,deco = [],[]

            for col in laliste:
                largeur = len(max(col, key=myord))
                spaces = largeur - len(col[lin])
                if lin == 1:
                    deco.append('+' + (largeur+2)*'=')
                else:
                    deco.append('+' + (largeur+2)*'-')
                textcell.append( "| " + col[lin] + (spaces+1)*" " )
            deco.append( "+" )
            textcell.append( "|" )
            output.append("".join(deco))
            output.append("".join(textcell))
        output.append(output[0])

        c = self.parent.getEditor().textCursor()
        c.insertText("\n".join(output))
