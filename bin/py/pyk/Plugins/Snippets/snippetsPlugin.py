#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
from plugins import IPlugin

# PyQt specific
from PyQt4 import QtGui, QtCore
import xml.etree.cElementTree as ET
from Snippets.SnipEngine import *
from Snippets.ui_SnippetsView import Ui_SnippetsDialog

def readSnippetsDefs(file):
    """Reads an XML file containing the snippets and
    returns a dictionnary whose keys are the triggers
    to type, and the values a 2-uplet(description,snippet).
    """
    templates = {}
    doc = ET.parse(str(file))
    entries = doc.findall("snip/entry")
    for entry in entries:
        templates[entry.find("trigger").text] = (entry.find("description").text,entry.find("snippet").text)
    return templates

class snippetsPlugin(IPlugin):
    infos = {'name': 'snippetsPlugin',
            'author': 'Kibleur Christophe',
            'version': '0.0.1',
            'website':'http://kib2.free.fr/PyEdit/',
                }

    def __init__(self, parent):
        IPlugin.__init__(self,parent)

    def reset(self):
        self.insideSnippet = False
        self.start_snip = 0
        self.snippets = []
        self.field = None
        self.field_start = 0
        self.field_long = 0
        self.oldsnip = None

    def activate(self):
        self.act,self.actView  = None,None # action on Tab
        self.editor = None
        self.isActivated = False

        ## We connect to Tab Changed to see if we can activate the
        ## snippet [check to see if there's an editor instance]
        #self.parent.menuPlugins.addAction(QtGui.QIcon(":/Images/crystal/plugins/snippets.png"), "Snippets")
        QtCore.QObject.connect(self.parent, QtCore.SIGNAL("changeEditor(PyQt_PyObject)"),self.changeEditor)

    ## ======================================================================
    ## === Initialisation routines    =======================================
    ## ======================================================================

    def changeEditor(self, new_editor):
        """In case of parent window using multiple editors instances.
        """
        if self.editor :
            self.oldEditor = self.editor

        self.editor = self.parent.getEditor()
        if not self.isActivated:
            self.reset()
            self.sniprep = readSnippetsDefs(self.getSnippetsDir())
            self.isActivated = True
        #self.editor = new_editor
        self.resetAction()
        self.sniprep = readSnippetsDefs(self.getSnippetsDir())

    def resetAction(self):
        """Each time the editor is changed, we must change the plugin
        actions to act on the new one.
        """
        ## Tab action
        if self.act :
            QtCore.QObject.disconnect(self.act, QtCore.SIGNAL("triggered()"), self.whatToDoOnTab)
            self.oldEditor.removeAction(self.act)

        if self.actView :
            self.parent.disconnect(self.actView, QtCore.SIGNAL("triggered()"), self.showSnippets)
            self.parent.menuPlugins.removeAction(self.actView)
            self.parent.actions.remove(self.actView)

        ## New View Snippets Dialog
        self.actView = QtGui.QAction(self.parent)
        self.actView.setText("View Snippets Defs")
        self.actView.setShortcut("Shift+F12")
        self.actView.setIcon( QtGui.QIcon(":/Images/crystal/plugins/snippets.png"))

        # Register the Snippets View Dialog
        self.parent.connect(self.actView, QtCore.SIGNAL("triggered()"), self.showSnippets)
        self.parent.menuPlugins.addAction(self.actView)
        self.parent.registerActionShortCut(self.actView)

        ## New Tab action
        self.act = QtGui.QAction(self.editor)
        self.act.setShortcut("Tab")

        QtCore.QObject.connect(self.act, QtCore.SIGNAL("triggered()"), self.whatToDoOnTab)
        self.editor.addAction(self.act)
        self.parent.connect(self.editor, QtCore.SIGNAL("textChanged()"), self.updateChilds)

        ## reception of important signals from the main app
        # from main window load method
        QtCore.QObject.connect(self.parent, QtCore.SIGNAL("syntaxChanged()"),self.onLoad)
        self.parent.connect(self.editor, QtCore.SIGNAL("textChanged()"), self.updateChilds)

    ## ======================================================================

    def getSnippetsDir(self):
        APPLIREP = os.getcwd()
        SYNTAXES = os.path.join(APPLIREP, 'Schemes/')
        #edClass = self.editor.__class__
        ext = unicode(self.editor.get_fileExtension(withPoint=False))
        #ext = unicode(self.editor.get_fileExtension())
        #print 'SnippetsPlugin editor\'s extension=%s with editor %s'%(ext,self.editor.name)
        #return SYNTAXES + edClass._extensions[ext] + '_scheme.xml'
        return SYNTAXES + self.parent.guessLangage(ext).lower() + '_scheme.xml'

    def onLoad(self):
        self.sniprep = readSnippetsDefs(self.getSnippetsDir())

    def indentSnip(self, sometext, shortcut_len):
        ## Maybe I should take some inspiration
        ## from this great article :
        ## http://www.skymind.com/~ocrow/python_string/
        tc = self.editor.textCursor()
        sep = "\n"
        col = (tc.columnNumber()-shortcut_len)*" "
        sortie = []
        splitted = sometext.split(sep)

        for ind,line in enumerate(splitted):
            if ind > 0:
                #sortie.append( col+line)
                sortie.append( ''.join([col,line]))
            else:
                sortie.append( line)
        return sep.join(sortie)

    def insertSnippet(self):
        """ Called from whatToDoOnTab's method

        Takes the word before the cursor thanks to wordLeftExtend's
        method and tries to find the word in the snippet dictionary
        DICSNIP.

        If so, the snippet is added to the stack and expanded, returning True.
        """
        # récupère le curseur et sa position
        tc = self.editor.textCursor()
        p = tc.position()

        # recupère le mot le plus à gauche de celui-ci
        word = self.wordLeftExtend(tc)

        # position de depart du snippet
        # [Si on tape en (0,0) le mot 'link', le curseur
        # est alors en pos (4,0). Il faut alors corriger
        # ceci en enlevant la longeur du raccourci tapé.]


        # On essaye de récupérer dans le dico des snippets
        # celui qui correspond au raccourci tapé.
        try:
            # le mot est dans le dico
            tpl = self.sniprep[word][1]
            helptpl = self.sniprep[word][0]
            kk = self.indentSnip(unicode(tpl),len(unicode(word)))
            #self.snippet = Snippet(unicode(tpl))
            self.snippet = Snippet(kk)

            self.snippet.help = helptpl
            self.snippet.start = p - len(word)
            ##
            self.snippets.append(self.snippet)

            self.snippet.fielditer = self.snippet.fieldIter()
            rendu = self.snippet.expanded()
            self.snippet.long=len(rendu)

            #tc.beginEditBlock()
            self.editor.blockSignals(True)
            tc.insertText(rendu)
            self.editor.blockSignals(False)
            self.editor.ensureCursorVisible()
            #tc.endEditBlock()

            self.parent.statusBar().showMessage('Snippet infos: %s'%(self.snippet.help),1000)


            return True
        except :
            # word is not in DICSNIP
            self.removeSelection()
            return False

    def whatToDoOnTab(self):
        """ Slot called when 'Tab' is pressed.

           - Tries to expand the word before the cursor;

           - if return value is True in insertSnippet's method:
                - the snipped has been added to the stack and is expanded,
                  we then go to the next snippet's field, if any.

           - if return value is False in insertSnippet's method:
                - if there are already snippets in stack, pass to the next one.
                - if there are no snippet in stack : stop and insert a tab char.
        """

        expanded = self.insertSnippet() # boolean

        if expanded : # if a snippet has been entered previously
            self.nextField()

        else : # the word entered wasn't a shortcut
            if len(self.snippets) > 0:
                self.nextField()
            else:
                self.parent.statusBar().showMessage('No snippet in stack %s or it is badly written'%(self.snippets))
                self.editor.textCursor().insertText(" "*self.editor.tab_long)

    def nextField(self):

        try: # to go to next field
            self.field = self.snippet.fielditer.next()
            self.snippet.current_field = self.field

            self.field.start = self.snippet.getFieldPos(self.field)
            self.field.long = self.field.getLengh()
            #self.parent.statusBar().showMessage('Field=%s--Snippet=%s--Start=%s--Long=%s'%(self.field.code, self.snippet,self.field.start,self.field.long))
            self.selectFromTo(self.snippet.start + self.field.start, self.field.long)

            if self.field.isEnd:
                self.endSnip()
        except :
            pass
            #self.parent.statusBar().showMessage('nextField is %s %s'%(self.snippet, self.snippet.current_field))


    def endSnip(self):
        self.removeSelection()
        if len(self.snippets) < 1:
            self.snippets = []
            return

        oldval = self.snippet.expanded()
        self.snippets.pop() # the old snippet
        self.snippet = self.snippets[-1] # new snippet= last entry
        self.field = self.snippet.current_field
        self.updateChilds(given=oldval)
        self.whatToDoOnTab()

    def updateChilds(self, given=None):
        """ Slot called when textarea is modified.
        """
        if len(self.snippets) > 0:
            ## curseur
            c = self.editor.textCursor()
            cursor_pos = c.position()

            ## variables utiles
            # pos de depart du snippet
            debut_snip = self.snippet.start
            old_long = self.snippet.long
            # le champ
            f = self.snippet.current_field

            # le nbr d'esclaves
            nslaves = len(f.slaves)
            # la valeur de l'ancien champ (si existence)
            old_field_val = f.content
            # l'ancien champ
            self.oldfield = f

            ## Capture le texte du champ actuel
            # l'affiche dans la statusbar
            newpos = c.selectionStart()
            #c.setPosition(debutsnip+st, QtGui.QTextCursor.MoveAnchor)
            c.setPosition(self.field.start + self.snippet.start, QtGui.QTextCursor.MoveAnchor)
            c.setPosition(cursor_pos, QtGui.QTextCursor.KeepAnchor)
            if not given :
                self.exp = c.selectedText()
            else:
                self.exp = given
            self.parent.statusBar().showMessage("Field %s replaced by '%s'"%(f.code,unicode(self.exp)))

            ## Selectionne et remplace le snippet

            # update du champ avec la valeur calculee
            f.content = unicode(self.exp)

            # nouveau contenu du snippet
            cont = self.snippet.expanded()

            # self.snip_long est l'ancienne longueur
            offset = len(f.content) - len(old_field_val)
            self.selectFromTo(self.snippet.start, self.snippet.long+offset)
            #time.sleep(1)

            # on update la longueur du snippet
            self.snippet.long = len(cont)

            # On doit faire attention a bloquer
            # l'emission du signal
            self.editor.blockSignals(True)
            self.editor.textCursor().insertText(cont)
            self.editor.blockSignals(False)

            # Should I prefer this one-liner ?
            #self.selectFromTo(self.start_snip+f.start+len(self.exp), 0)

            c = self.editor.textCursor()
            c.setPosition(self.field.start + self.snippet.start+len(self.exp))
            self.editor.setTextCursor(c)

    ## ------------------------------------------
    ## Editor's functions
    ## ------------------------------------------
    # Find the word before the cursor and select it
    def wordLeftExtend(self, my_cursor):
        """ Catches the word left to the cursor
        , select it and return its unicode value.
        """
        oldpos = my_cursor.position()

        # manips curseur
        my_cursor.select(QtGui.QTextCursor.WordUnderCursor)
        #self.editor.setTextCursor(my_cursor)

        newpos = my_cursor.selectionStart()

        my_cursor.setPosition(newpos, QtGui.QTextCursor.MoveAnchor)
        my_cursor.setPosition(oldpos, QtGui.QTextCursor.KeepAnchor)
        self.editor.setTextCursor(my_cursor)
        return unicode(my_cursor.selectedText())

    # selectionne le texte de pos à pos + nbr_car
    def selectFromTo(self, pos, nbr_car) :
        """ Selectionne la partie de texte comprise
            entre pos et pos + nbr_car
        """
        #print "Je dois Selectionner de ", pos," a ",lon
        c = self.editor.textCursor()
        # on se positionne au debut
        c.setPosition(pos)
        # on va vers la droite de nbr_car caractères
        c.movePosition(QtGui.QTextCursor.Right, QtGui.QTextCursor.KeepAnchor,nbr_car)
        # on repositionne alors le curseur
        self.editor.setTextCursor(c)

    # enleve toute selection
    def removeSelection(self):
        """ Enleve la selection et deplace le
            curseur à la fin de celle-ci.
        """
        p = self.editor.textCursor().position()
        self.selectFromTo(p,0)

    ## SNIPPETS DIALOG
    def showSnippets(self):
        """Shows the Snippets dialog
        """
        Dialog = QtGui.QDialog(self.parent)
        ui = Ui_SnippetsDialog()
        ui.setupUi(Dialog)
        Dialog.show()
        tbl = ui.tableWidget

        # Beware one thing
        # deactivate the sorting before using
        # setItem in a loop !
        # See http://doc.trolltech.com/4.3/qtablewidget.html#setItem
        tbl.setSortingEnabled(False)
        tbl.setRowCount(len(self.sniprep.keys()))
        for i,el in enumerate(self.sniprep.keys()):
            contenu = self.sniprep[el]
            desc = QtCore.QString(contenu[0])
            code = QtCore.QString(contenu[1])

            it_doc = QtGui.QTableWidgetItem(el,0)
            it_desc = QtGui.QTableWidgetItem(desc,0)
            it_code = QtGui.QTableWidgetItem(code,0)

            tbl.setItem(i,0,it_doc)
            tbl.setItem(i,1,it_desc)
            tbl.setItem(i,2,it_code)

        tbl.setSortingEnabled(True)
        tbl.resizeColumnsToContents()
        tbl.resizeRowsToContents()

