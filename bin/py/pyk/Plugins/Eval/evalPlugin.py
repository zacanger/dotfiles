#!/usr/bin/env python
# -*- coding: utf-8 -*-
import os
import re
from plugins import IPlugin
# PyQt specific
from PyQt4 import QtGui, QtCore

"""
Inspirated from Emacs pymdev :
http://www.toolness.com/pymdev/

Enter an expression in textEditor, select it and replace it
with Python's eval method.

ie, try to use it with this little line :
'\tfoo\n'*10
"""

_py_globals = { "__builtins__" : __builtins__ }

class evalModePlugin(IPlugin):
    infos = {'name': 'evalModePlugin',
            'author': 'Kibleur Christophe',
            'version': '0.0.1',
            'website':'http://kib2.free.fr/PyEdit/',
                }
    count = 0
    ## ======================================================================

    def __init__(self, parent):
        IPlugin.__init__(self,parent)
        #"=|\-|`|:|'|"|~|\^|_|\*|\+|#|\<|\>"
        self._motif = re.compile(r'(class|def)\s+\w+', re.UNICODE )
        #self._motif = re.compile(r"""^((=|\-|`|\:|'|"|~|\^|_|\*|\+|#|\<|\>)+)""", re.UNICODE )

    def activate(self):
        self._plugContext = '.py'
        self.editor = self.parent.getEditor()
        self.sb = self.parent.statusBar()

        act = QtGui.QAction(self.parent)
        act.setText("Eval! plugin")
        act.setShortcut("Ctrl+Alt+E")
        act.setIcon(QtGui.QIcon(":/Images/crystal/plugins/flask_1_32.png"))


        self.parent.connect(act, QtCore.SIGNAL("triggered()"), self.evalRegion)
        self.parent.menuPlugins.addAction(act)
        self.parent.registerActionShortCut(act)

        ## reception of important signals from the main app
        QtCore.QObject.connect(self.parent, QtCore.SIGNAL("changeEditor(PyQt_PyObject)"),self.changeEditor)

    def changeEditor(self, new_editor):
        """In case of parent window using multiple editors instances.
        """
        self.sb.showMessage("Editor changed",500)
        self.editor = new_editor

    def evalRegion(self):
        """Evaluate the current region and return the result."""
        tc = self.editor.textCursor()
        to_eval = unicode(tc.selectedText())
        try:
            s = eval(to_eval, _py_globals)
            tc.insertText(s)
        except:
            self.sb.showMessage('cannot evaluate this.')

