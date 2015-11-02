#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import urllib
from plugins import IPlugin

# PyQt specific
from PyQt4 import QtGui, QtCore
from Html2Rest.ui_html2rest import Ui_Dialog
from Html2Rest.xhtml2rest import main

PAGESTART = u"""<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="fr" lang="fr">
<head>
  <title>Some title</title>
</head>
<body>
"""
PAGEEND = u"""</body>
</html>
"""

class html2restPlugin(IPlugin):
    infos = {'name': 'html2restPlugin',
            'author': 'Kibleur Christophe',
            'version': '0.0.1',
            'website':'http://kib2.free.fr/PyEdit/',
                }

    def __init__(self, parent):
        IPlugin.__init__(self,parent)

    def activate(self):
        self.sb = self.parent.statusBar()
        self.act  = None # action on Ctrl+Alt+R
        self.editor = None
        self.isActivated = False

        QtCore.QObject.connect(self.parent, QtCore.SIGNAL("changeEditor(PyQt_PyObject)"),self.changeEditor)
        self.parent.menuPlugins.addAction(QtGui.QIcon(":/Images/crystal/plugins/uranium_32.png"), "html2rest")

    def changeEditor(self, new_editor):
        """In case of parent window using multiple editors instances.
        """
        ## keep track of the old editor to disconnect its signal
        if self.editor :
            self.oldEditor = self.editor

        self.editor = self.parent.getEditor()

        if not self.isActivated:
            self.isActivated = True

        self.resetAction()

        self.sb.showMessage("Editor changed",500)

    def resetAction(self):
        """Each time the editor is changed, we must change the plugin
        actions to act on the new one.
        """
        if self.act :
            self.parent.disconnect(self.act, QtCore.SIGNAL("triggered()"), self.showAdressDialog)
            self.editor.removeAction(self.act)

        ## Alt+X,Ctrl+K action
        self.act = QtGui.QAction(self.editor)
        self.act.setShortcut("Alt+X,Ctrl+K")

        self.editor.addAction(self.act)
        QtCore.QObject.connect(self.act, QtCore.SIGNAL("triggered()"),self.showAdressDialog)

    def showAdressDialog(self):
        dial = QtGui.QDialog(self.parent)
        dial.setWindowTitle("html2rest")

        self.adressdialog = dial
        self.tbl_dial = Ui_Dialog()
        self.tbl_dial.setupUi(dial)
        self.edit = self.tbl_dial.lineEdit
        self.htmlcontent = self.tbl_dial.textEdit
        QtCore.QObject.connect(dial,QtCore.SIGNAL("accepted()"),self.convertToRest)
        dial.show()

    def convertToRest(self):
        """Use Pandoc to do the conversion.
        """
        addr = unicode(self.edit.text())
        if addr != u"" :
            addr = addr.replace('/','%2F')

            rac = r"http://johnmacfarlane.net/cgi-bin/html2x.pl?url=http%3A%2F%2F"
            endrac = r"&format=rst"
            realadd = rac + addr + endrac

            sock = urllib.urlopen(realadd)

            restSource = sock.read()
            sock.close()

            restSource = unicode( restSource, "utf-8" )
            c = self.parent.getEditor().textCursor()
            c.insertText(restSource)
        else:
            codec = QtCore.QTextCodec.codecForName("UTF-8")
            tc = self.htmlcontent.document().toPlainText()
            encod = codec.fromUnicode(tc)
            #truc = PAGESTART + encod + PAGEEND

            ## Now, we use BeautifullSoup
            ## to have a beautifull document !
            doc = PAGESTART + encod + PAGEEND
            soup = BeautifulSoup(doc)
            print soup.originalEncoding
            truc = unicode(soup)

            retour = main(truc)
            #retour = main(encod)

            tobetreated = retour.split('\n')
            for ind,el in enumerate(tobetreated):
                #print el
                if el == u'::' :
                    tobetreated[ind] = u'.. sourcecode:: python'
                elif el == u'..' :
                    tobetreated[ind] = u''

            retour = '\n'.join(tobetreated)

            c = self.parent.getEditor().textCursor()
            c.insertText(retour)
