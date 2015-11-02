#!/usr/bin/env python
# -*- coding: utf-8 -*-
import os
import re
from plugins import IPlugin
# PyQt specific
from PyQt4 import QtGui, QtCore

class structurePlugin(IPlugin):
    infos = {'name': 'structurePlugin',
            'author': 'Kibleur Christophe',
            'version': '0.0.1',
            'website':'http://kib2.free.fr/PyK/',
                }
    ## =======================================

    def __init__(self, parent):
        IPlugin.__init__(self,parent)


        """We define here a dictionnary whose
        - keys are :
            the langage extension ;
        - values are:
            a tuple (regexp, callback function used while parsing)
        """
        self.structs = {
        'rst' : (re.compile(r'^(?P<line>(?P<deco>[\*|\-|\=|#|~|\'|"|:|\^|_|\+])(?P=deco)+)', re.UNICODE ), self.onRest),
        'py'  : (re.compile(r'(\s|\t)*(class|def)\s+(\w+)', re.UNICODE ), self.onPython),
        }

        self.decos = []
        # remember that reSt decorations are :
        # "=|\-|`|:|'|"|~|\^|_|\*|\+|#|\<|\>"
        # "_|\+|#|\<|\>"
        # so I have to catch them all

    def activate(self):
        self.act  = None # action on Ctrl+Alt+R
        self.editor = None
        self.isActivated = False

        ## We connect to Tab Changed to see if we can activate the
        ## snippet [check to see if there's an editor instance]
        QtCore.QObject.connect(self.parent, QtCore.SIGNAL("changeEditor(PyQt_PyObject)"),self.changeEditor)

    def changeEditor(self, new_editor):
        """In case of parent window using multiple editors instances.
        """
        ## keep track of the old editor to disconnect its signal
        if self.editor :
            self.oldEditor = self.editor

        self.editor = self.parent.getEditor()

        if not self.isActivated:
            self.isActivated = True

        #self.editor = new_editor
        self.resetAction()
        self.parseDocForTitles()
        self.parent.listWidget_structure.update()


    def resetAction(self):
        """Each time the editor is changed, we must change the plugin
        actions to act on the new one.
        """
        if self.act :
            self.parent.disconnect(self.act, QtCore.SIGNAL("triggered()"), self.parseDocForTitles)
            self.parent.menuPlugins.removeAction(self.act)
            self.parent.actions.remove(self.act)

        ## Ctrl+Alt+R action
        self.act = QtGui.QAction(self.parent)
        self.act.setText("Structure mode refresh")
        self.act.setShortcut("Ctrl+Alt+R")
        self.act.setIcon(QtGui.QIcon(":/Images/crystal/plugins/structure.png"))

        self.parent.connect(self.act, QtCore.SIGNAL("triggered()"), self.parseDocForTitles)
        self.parent.menuPlugins.addAction(self.act)
        self.parent.registerActionShortCut(self.act)

        QtCore.QObject.connect(self.parent, QtCore.SIGNAL("syntaxChanged()"),self.parseDocForTitles)

    def parseDocForTitles(self):
        # From Docutils docs
        # The underline/overline must be at
        # least as long as the title text
        lw = self.parent.listWidget_structure
        lw.clear()
        extension = self.editor.get_fileExtension(withPoint=False)

        if extension in self.structs.keys():
            text = unicode(self.parent.getEditor().document().toPlainText())

            # get the regexp
            motif = self.structs[unicode(extension)][0]
            callback = self.structs[unicode(extension)][1]
            self.titles = []
            lig = 0
            recherche = text.split('\n')

            for line in recherche:
                for m in re.finditer(motif, line):
                    callback(recherche,m,lig)
                lig += 1
            kk = [el[0] for el in self.titles]

            for it in kk :
                lw.addItem(it)

        self.parent.connect(lw,QtCore.SIGNAL("doubleClicked(QModelIndex)"), self.gotoChoice)

    def gotoChoice(self, idx):
        row = idx.row()
        ln = self.titles[row][1] # line number
        self.editor.gotoLine(ln)

    ## These are the callbacks methods called by the parser
    ## one for each Langage
    def onRest(self, recherche, matchedobj, line):
        lw = self.parent.listWidget_structure
        ## get the decoration symbol
        deco_type = matchedobj.group(2)

        ## if not present in decos, add it
        if deco_type not in self.decos:
            self.decos.append(deco_type)

        ## get the section title
        try:
            tit = recherche[line-1]
        ## if we can't, that's the title of the doc
        except:
            tit = recherche[line+1]

        ## now computes the indent level
        ## according to the index in decos
        indent_level = self.decos.index(deco_type)*4

        if len(matchedobj.group()) == len(tit):
            #self.titles.append((tit, line))
            it_text = " "*indent_level + tit
            it_icon = QtGui.QIcon(":/Images/crystal/plugins/structure.png")
            newItem  = QtGui.QListWidgetItem(it_icon,it_text,lw)
            self.titles.append((newItem, line))

    def onPython(self, recherche, matchedobj, line):
        # ideas : couting whitespaces or tabs to know
        # ident level
        lw = self.parent.listWidget_structure
        sectype = matchedobj.group(2)

        idt = " "*self.editor.tab_long
        try:
            identlevel = len(matchedobj.group(1))*idt
        except:
            identlevel = ""

        if sectype == 'class':
            it_icon = QtGui.QIcon(":/Images/crystal/plugins/class.png")
        else:
            if identlevel == "" :
                it_icon = QtGui.QIcon(":/Images/crystal/plugins/func.png")
            else:
                it_icon = QtGui.QIcon(":/Images/crystal/plugins/def.png")

        it_text = identlevel + matchedobj.group(2)+" "+ matchedobj.group(3)
        newItem  = QtGui.QListWidgetItem(it_icon,it_text,lw)
        #self.titles.append((identlevel + matchedobj.group(2)+" "+(matchedobj.group(3)), line))
        self.titles.append((newItem, line))
