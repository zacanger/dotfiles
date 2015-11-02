#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""The Browser plugin is a QTextBrowser
with HTML and pseudo CSS support.
"""

import os
from docutils import core
import Browser.RegisterPygment
from plugins import IPlugin

# PyQt specific
from PyQt4 import QtGui, QtCore
from Browser.ui_browser_dialog import Ui_BrowserDialog

class browserPlugin(IPlugin):
    infos = {'name': 'browserPlugin',
            'author': 'Kibleur Christophe',
            'version': '0.0.1',
            'website':'http://kib2.free.fr/PyEdit/',
                }
    count = 0
    ## =======================================

    def __init__(self, parent):
        IPlugin.__init__(self,parent)


    def activate(self):
        self._plugContext = 'rst'
        self.editor = self.parent.getEditor()
        self.sb = self.parent.statusBar()
        act = QtGui.QAction(self.parent)
        act.setText("View inside PyK! Browser")
        act.setShortcut("Ctrl+Alt+B")
        act.setIcon(QtGui.QIcon(":/Images/crystal/plugins/structure.png"))

        # Add the plugin to the Plugins Menu once only
        self.parent.connect(act, QtCore.SIGNAL("triggered()"), self.toBrowser)
        self.parent.menuPlugins.addAction(act)
        self.parent.registerActionShortCut(act)

        ## reception of important signals from the main app
        #QtCore.QObject.connect(self.parent, QtCore.SIGNAL("syntaxChanged()"),self.parseDocForTitles)
        QtCore.QObject.connect(self.parent, QtCore.SIGNAL("changeEditor(PyQt_PyObject)"),self.changeEditor)

    def changeEditor(self, new_editor):
        """In case of parent window using multiple editors instances.
        """
        self.sb.showMessage("Editor changed",500)
        self.editor = new_editor

    def toBrowser(self):
        """ Transforme le texte de l'editeur en HTML
            pour le voir dans la partie browser.
        """
        # Construct the browser dialog
        dialog = QtGui.QDialog(self.parent)
        self.browserDial = Ui_BrowserDialog()
        self.browserDial.setupUi(dialog)
        self.browser = self.browserDial.browser

        if self.parent.getEditor().get_fileExtension(withPoint=False) != self._plugContext:
            self.parent.Attention("The Browser plugin can only be accessed from a reStructuredText file.")
            return

        #self.browser.document().setDefaultStyleSheet(open(os.getcwd() + "/browser.css","r").read())
        filePath = unicode(self.editor.get_fileDir())
        sortie = core.publish_string(unicode(self.editor.document().toPlainText()).encode("utf-8"),
                writer_name='html',
                settings_overrides={'input_encoding': 'utf-8',
                                    'output_encoding': 'latin-1',
                                    'language': 'en',
                                    },
                            )
        self.browser.setSearchPaths([os.path.expanduser(filePath)])
        self.browser.setHtml(sortie)
        dialog.show()
