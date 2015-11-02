# -*- coding: utf-8 -*-
#!/usr/bin/python

import os
import sys

## PyQt4 specific
from PyQt4 import QtGui, QtCore
from ui_PyEdit import Ui_PyK
from ui_About import Ui_About
from ui_ShortCutsView import Ui_ShortcutDialog

## Personal
from editor import Editor
from plugins import *
from commands import *
from HL import getNameExtensionsDic
from ui_PyKsettings import Ui_PyKsettings

APPLIREP = os.getcwd()
PLUGINS = os.path.join(APPLIREP,'Plugins')
COMMANDS = os.path.join(APPLIREP,'commands')


__version__ = "1.0.15"

class Myapp(QtGui.QMainWindow, Ui_PyK):

    def __init__(self):
        QtGui.QMainWindow.__init__(self)
        Ui_PyK.__init__(self)

        # user interface configuration.
        self.setupUi(self)

        ## EXTENSIONS
        # a dictionnary containing all
        # the possible extensions
        self.extensions = getNameExtensionsDic()

        ## SHORTCUTS
        self.actions = []

        ## BOM for UTF-8 files
        self.def_encoding = "utf8"
        self.alreadyBomCheck = False

        ## TAB WIDGET
        self.tabWidget = QtGui.QTabWidget(self.dockWidget_files_contents)
        self.tabWidget.setObjectName("tabWidget")
        self.hboxlayout4.addWidget(self.tabWidget)

        ## COMMANDS
        self.commandsHaveBeenRead = False
        self.cmds = None

        ## VIEW MENU
        self.viewlines = -1
        self.viewProjects = False
        self.viewConsole = True

        ## SETTINGS
        self.preferedDir = os.path.join(APPLIREP, 'test_files/')
        self.loadSettings()

        ## STATUSBAR
        self.manageStatusBar()

        ## SPLITTERS MANAGEMENT
        self.splitterTop.setStretchFactor(0,1)
        self.splitterTop.setStretchFactor(1,6)
        self.splitterMain.setStretchFactor(0,5)
        self.splitterMain.setStretchFactor(1,3)

        self.dockWidget_project.connect(self.actionViewProjectPane,QtCore.SIGNAL("toggled(bool)"),self.viewHideShowProjects)
        self.dockWidget_console.connect(self.actionViewConsolePane,QtCore.SIGNAL("toggled(bool)"),self.viewHideShowConsole)

        ## SIGNALS AND SLOTS
        self.connect(self.actionNew,QtCore.SIGNAL("triggered()"),self.fileNew)
        self.connect(self.actionOpen,QtCore.SIGNAL("triggered()"),self.fileOpen)
        self.connect(self.actionSave,QtCore.SIGNAL("triggered()"),self.fileSave)
        self.connect(self.actionSaveAs,QtCore.SIGNAL("triggered()"),self.fileSaveAs)
        self.connect(self.actionPrint,QtCore.SIGNAL("triggered()"),self.filePrint)
        self.connect(self.actionClose,QtCore.SIGNAL("triggered()"),self.fileCloseTab)
        self.connect(self.actionAbout,QtCore.SIGNAL("triggered()"),self.showAbout)
        self.connect(self.actionShortCuts,QtCore.SIGNAL("triggered()"),self.showShortCuts)
        self.connect(self.actionSettings,QtCore.SIGNAL("triggered()"),self.showSettings)
        self.connect(self.actionColorDialog,QtCore.SIGNAL("triggered()"),self.showColors)
        self.connect(self.actionCalendar,QtCore.SIGNAL("triggered()"),self.showCalendar)
        self.connect(self.tabWidget,QtCore.SIGNAL("currentChanged(int)"),self.tabChanged)

        ## OLD FILES LOADING AT STARTUP
        QtCore.QTimer.singleShot(0, self.loadFiles)

        ## CONNECTIONS SHORTCUTS INDENT/UNINDENT REGION
        QtGui.QShortcut(QtGui.QKeySequence("Shift++"), self, self.indent)
        QtGui.QShortcut(QtGui.QKeySequence("Shift+-"), self, self.unindent)

        ## PLUGINS
        self.setPlugins()

    def indent(self):
        self.getEditor().indentRegion()

    def unindent(self):
        self.getEditor().unindentRegion()

    ## FILES MANAGEMENT
    def loadFiles(self):
        if len(sys.argv) > 1:
            count = 0
            for filename in sys.argv[1:]:
                filename = QtCore.QString(filename)
                if QtCore.QFileInfo(filename).isFile():
                    self.loadFile(filename)
                    QtGui.QApplication.processEvents()
                    count += 1
                    if count >= 10: # Load at most 10 files
                        break
        else:
            settings = QtCore.QSettings()
            files = settings.value("CurrentFiles").toStringList()
            for filename in files:
                filename = QtCore.QString(filename)
                if QtCore.QFile.exists(filename):
                    self.loadFile(filename)
                    QtGui.QApplication.processEvents()

    def fileNew(self):
        textEdit = Editor(parent=self)
        #textEdit.setStyleSheet(TES)
        self.tabWidget.addTab(textEdit, textEdit.windowTitle())
        self.tabWidget.setCurrentWidget(textEdit)
        textEdit.setFocus()
        self.setupCommands()
        self.connect(textEdit, QtCore.SIGNAL("cursorPositionChanged()"),
                         self.updateIndicators)
        self.emit(QtCore.SIGNAL("changeEditor(PyQt_PyObject)"),textEdit )

    def fileOpen(self):
        filename = QtGui.QFileDialog.getOpenFileName(self,
                            "PyK -- Open File",
                            unicode(self.preferedDir),
                            )
        if not filename.isEmpty():
            for i in range(self.tabWidget.count()):
                textEdit = self.tabWidget.widget(i)
                if textEdit.filename == filename:
                    self.tabWidget.setCurrentWidget(textEdit)
                    break
            else:
                self.loadFile(filename)
                self.setupCommands()
                self.preferedDir = self.getEditor().get_fileDir()

    def loadFile(self, filename):
        if isinstance(filename, str):
            filename = QtCore.QString(unicode(filename))
        textEdit = Editor(filename,parent=self)
        try:
            textEdit.load()
            textEdit.setFocus()
        except (IOError, OSError), e:
            QtGui.QMessageBox.warning(self, "PyK -- Load Error",
                    "Failed to load %s: %s" % (filename, e))
            textEdit.close()
            del textEdit
        else:
            self.tabWidget.addTab(textEdit, textEdit.windowTitle())
            self.tabWidget.setCurrentWidget(textEdit)
            #self.setPlugins()
            self.setCorrectExtension(textEdit)
            #ext = unicode(textEdit.get_fileExtension(withPoint=False))
            #self.combo.setCurrentIndex( self.combo.findText(self.guessLangage(ext)) )
            self.connect(textEdit, QtCore.SIGNAL("cursorPositionChanged()"),
                         self.updateIndicators)
            self.emit(QtCore.SIGNAL("changeEditor(PyQt_PyObject)"),textEdit )

    def fileSave(self):
        textEdit = self.tabWidget.currentWidget()
        if textEdit is None or not isinstance(textEdit, QtGui.QTextEdit):
            return
        try:
            textEdit.save()
            #self.emit(QtCore.SIGNAL("hasSaved(PyQt_PyObject)"),textEdit)
            self.setCorrectExtension(textEdit)
            self.tabWidget.setTabText(self.tabWidget.currentIndex(), textEdit.get_realFileName())
            self.setupCommands()
            self.emit(QtCore.SIGNAL("changeEditor(PyQt_PyObject)"),textEdit)
            self.statusBar().showMessage("File %s has been saved"%(textEdit.get_realFileName()),2000)
        except (IOError, OSError), e:
            QtGui.QMessageBox.warning(self, "PyK -- Save Error",
                    "Failed to save %s: %s" % (textEdit.filename, e))

    def fileSaveAs(self):
        textEdit = self.tabWidget.currentWidget()
        if textEdit is None or not isinstance(textEdit, QtGui.QTextEdit):
            return
        filename = QtGui.QFileDialog.getSaveFileName(self,
                        "PyK -- Save File As",
                        textEdit.filename, "Text files (*.txt *.*)")
        if not filename.isEmpty():
            textEdit.filename = filename
            self.fileSave()
            # We set the prefered Dir to the given value
            self.preferedDir = self.getEditor().get_fileDir()

    def filePrint(self):
        textEdit = self.tabWidget.currentWidget()
        self.printer = QtGui.QPrinter(QtGui.QPrinter.HighResolution)
        self.printer.setPageSize(QtGui.QPrinter.Letter)

        dialog = QtGui.QPrintDialog(self.printer, self)
        if dialog.exec_():
            doc = textEdit.document()
            doc.print_(self.printer)

    def setCorrectExtension(self, textEdit):
        ext = unicode(textEdit.get_fileExtension(withPoint=False))
        self.combo.setCurrentIndex( self.combo.findText(self.guessLangage(ext)) )

    def guessLangage(self,ext):
        """Given an extension, ie 'tex', we must guess that
        it is a LaTeX file.
        """
        Langs = self.extensions
        for langName,lang in zip(Langs.keys(),Langs.values()):
            for langext in lang:
                if ext in langext:
                    return langName
        return 'Default'

    ## TABS MANAGEMENT
    def fileCloseTab(self):
        textEdit = self.tabWidget.currentWidget()
        if textEdit is None or not isinstance(textEdit, QtGui.QTextEdit):
            return
        textEdit.close()
        self.tabWidget.removeTab(self.tabWidget.currentIndex())

    def tabChanged(self, tab_id):
        """Slot called when tab has changed.

        It emits the 'changeEditor(PyQt_PyObject)' SIGNAL for the plugins
        to know if the editor has changed.
        """
        ed = self.tabWidget.widget(tab_id)
        ed.setFocus()
        self.emit(QtCore.SIGNAL("changeEditor(PyQt_PyObject)"),ed )
        self.setupCommands()


    def getEditor(self):
        """returns the current tabWidget editor if any
        """
        return self.tabWidget.currentWidget()

    ## STATUSBAR CONSTRUCTION
    def manageStatusBar(self):
        """Populates a statusBar
        """
        ## Encoding combo box
        citems = Editor._codecs.keys()
        self.encoding_combo = QtGui.QComboBox(self.statusbar)
        self.encoding_combo.addItems(citems)
        self.encoding_combo.setCurrentIndex( self.encoding_combo.findText(self.def_encoding.toString()) )
        self.statusbar.addPermanentWidget(self.encoding_combo)
        self.connect(self.encoding_combo,QtCore.SIGNAL("currentIndexChanged(const QString)"),self.codecsChanged)

        ## Langages combo box
        self.combo = QtGui.QComboBox(self.statusbar)
        combo_langList = self.extensions.keys()
        self.langList = QtCore.QStringList(combo_langList)
        self.langList.sort()
        self.combo.addItems(self.langList)
        self.statusbar.addPermanentWidget(self.combo)
        self.combo.setCurrentIndex( self.combo.findText('Default') )
        self.connect(self.combo,QtCore.SIGNAL("currentIndexChanged(const QString)"),self.langChanged)

        ## Cursor position indicators
        self.columnCountLabel = QtGui.QLabel("(empty)")
        self.statusbar.addPermanentWidget(self.columnCountLabel)
        self.lineCountLabel = QtGui.QLabel("(empty)")
        self.statusbar.addPermanentWidget(self.lineCountLabel)

        ## BOM
        self.bomCheck = QtGui.QCheckBox(self.tr("Bom"),self.statusbar)
        #self.bomCheck.setCheckState(QtCore.Qt.Checked)
        self.statusbar.insertPermanentWidget(0,self.bomCheck)

        self.statusbar.showMessage(self.tr("Ready..."))

    ## MANAGEMENT OF :
    ## PLUGINS
    ## EDITOR
    ## COMMANDS
    def setPlugins(self):
        """Plugins will be instanciated once only for
        saving memory storage.
        """
        ## plugins management
        ## the manager loads the python files
        ## ie 'snippetplugin.py'
        ## contains the class snippetPlugin

        ## PLUGINS
        # we import the modules only here
        # the plugin manager will create
        # the instances alone
        self.pm = pluginManager(self,
                        {'plugin_path': PLUGINS,
                        'plugins': [
                        'Snippets.snippetsPlugin',
                        'Blog.blogPlugin',
                        'Browser.browserPlugin',
                        'Tables.tablesPlugin',
                        'Structures.structuresPlugin',
                        'Eval.evalPlugin',
                        'Html2Rest.html2restPlugin',
                        ]}
                        )


        self.pm.init_plugin_system()
        self.pm.activateAllPlugins()

    def setupEditor(self):
        self.getEditor().sb = self.statusbar
        QtCore.QObject.connect(self.actionOpen,QtCore.SIGNAL("triggered()"),self.load)
        QtCore.QObject.connect(self.actionSave_As,QtCore.SIGNAL("triggered()"),self.saveAs)
        QtCore.QObject.connect(self.actionSave,QtCore.SIGNAL("triggered()"),self.save)
        QtCore.QObject.connect(self.getEditor(), QtCore.SIGNAL("cursorPositionChanged()"),
                         self.updateIndicators)
        self.connect(self.bomCheck,QtCore.SIGNAL("stateChanged(int)"),self.onBom)

    def setupCommands(self):
        """Retrieve the avaible commands
        given the editor's context based
        on file extension
        """
        ## TODO : improve perfs by loading them all once
        ##        and select them later
        if self.cmds :
            for c in self.cmds:
                self.menuCommands.removeAction(c.getAction())

        if not self.commandsHaveBeenRead :
            self.allCommands = readCommandsFromXML(self)
            commandsHaveBeenRead = True

        commands = self.allCommands
        self.cmds = [cmd for cmd in commands if self.getEditor().getContext() in cmd.context]
        self.menuCommands.clear()

        for c in self.cmds:
            self.menuCommands.addAction(c.getAction())

    ## ENCODING SUPPORT
    def codecsChanged(self, choix):
        choice = Editor._codecs[unicode(choix)]
        self.statusBar().showMessage("Codecs changed to %s"%(choice))
        ed = self.getEditor()
        ed.set_Codec(choice)
        ## Now we load the textEdit content
        ## to the given encoding
        try:
            toCodec = QtCore.QTextCodec.codecForName(choice)
            ed.load(codecGiven=toCodec)
        except:
            self.Attention("You must save your file before specifying its encoding")

    def onBom(self, n):
        if n == 0:
            self.getEditor().bom = False
        else:
            self.getEditor().bom = True

    def needBomCheckBox(self):
        if self.getEditor().codec == "UTF-8" :
            return self.getEditor().bom

    ## STATUS BAR CURSOR POS INDICATORS
    def updateIndicators(self):
        editor = self.getEditor()
        lines = editor.document().blockCount()
        cursor = editor.textCursor()
        self.columnCountLabel.setText("Column %d" % (
                cursor.columnNumber() + 1))
        if lines == 0:
            text = "(empty)"
        else:
            text = "Line %d of %d" % (cursor.blockNumber() + 1, lines)
        self.lineCountLabel.setText(text)

    ## CLOSING THE APP
    def closeEvent(self, event):
        """Keeps track of the user settings.
        """
        ## Save the not saved files
        failures = []
        for i in range(self.tabWidget.count()):
            textEdit = self.tabWidget.widget(i)
            if textEdit.isModified():
                try:
                    textEdit.save()
                except IOError, e:
                    failures.append(str(e))
        if failures and \
           QtGui.QMessageBox.warning(self, "Text Editor -- Save Error",
                    "Failed to save%s\nQuit anyway?" % \
                    "\n\t".join(failures),
                    QtGui.QMessageBox.Yes|QtGui.QMessageBox.No) == QtGui.QMessageBox.No:
            event.ignore()
            return
        ## Settings Storage
        settings = QtCore.QSettings()
        settings.setValue("MainWindow/Size", QtCore.QVariant(self.size()))
        settings.setValue("MainWindow/Position",
                QtCore.QVariant(self.pos()))
        settings.setValue("MainWindow/State",
                QtCore.QVariant(self.saveState()))
        files = QtCore.QStringList()
        for i in range(self.tabWidget.count()):
            textEdit = self.tabWidget.widget(i)
            if not textEdit.filename.startsWith("Unnamed"):
                files.append(textEdit.filename)
        settings.setValue("CurrentFiles", QtCore.QVariant(files))
        while self.tabWidget.count():
            textEdit = self.tabWidget.widget(0)
            textEdit.close()
            self.tabWidget.removeTab(0)
        settings.setValue("Encoding",QtCore.QVariant(self.def_encoding))
        settings.setValue("Prefered_Directory",QtCore.QVariant(self.preferedDir))


    ## LANGAGE CHANGES
    def langChanged(self, name):
        ed = self.getEditor()
        choice = str(name).lower()
        ext = unicode(ed.get_fileExtension(withPoint=False))
        #ext = Editor._langtoextension[choice] # returns ie '.py'
        ed.findHighlighter(extGiven=ext)
        self.statusbar.showMessage(self.tr("Choice of file extension: %s"%(choice)))
        self.setupCommands()

    ## TODO: VIEW MENU
    def makeViewMenu(self):
        act = QtGui.QAction(self.getEditor())
        act.setText("Toogle White spaces")
        act.setShortcut("Ctrl+W,Alt+S")
        self.menuView.addAction(act)
        QtCore.QObject.connect(act, QtCore.SIGNAL("triggered()"), self.getEditor().toogleWhiteSpaces)
        self.getEditor().addAction(act)
        self.registerActionShortCut(act)

    ## PROJECTS PANE
    def viewHideShowProjects(self, isChecked):
        if self.viewProjects :
            self.dockWidget_project.show()
        else:
            self.dockWidget_project.hide()
        self.viewProjects = isChecked

    ## CONSOLE PANE
    def viewHideShowConsole(self, isChecked):
        if self.viewConsole :
            self.dockWidget_console.hide()
        else:
            self.dockWidget_console.show()
        self.viewConsole = isChecked

    ## ABOUT DIALOG
    def showAbout(self):
        """Shows the About dialog
        """
        Dialog = QtGui.QDialog(self)
        ui = Ui_About()
        ui.setupUi(Dialog)
        Dialog.show()

    ## SETTINGS DIALOG
    def showSettings(self):
        """Shows the About dialog
        """
        Dialog = QtGui.QDialog(self)
        ui = Ui_PyKsettings()
        ui.setupUi(Dialog)

        # populate the comboBox with supported encodings
        citems = Editor._codecs.keys()
        ui.encodeCombo.addItems(citems)
        ui.encodeCombo.setCurrentIndex( ui.encodeCombo.findText(self.def_encoding.toString()) )

        self.connect(ui.encodeCombo,QtCore.SIGNAL("currentIndexChanged(QString)"),self.settingsEncodingChanged)
        Dialog.show()

    ## COLORS DIALOG
    def showColors(self):
        self.colorDlg = QtGui.QColorDialog.getColor()
        if self.colorDlg.isValid():
            self.getEditor().insertPlainText(self.colorDlg.name())

    ## CALENDAR
    def showCalendar(self):
        self.calDlg = QtGui.QCalendarWidget()
        self.connect(self.calDlg, QtCore.SIGNAL('clicked(const QDate)'), self.showDate)
        self.calDlg.show()

    def showDate(self,the_date):
        mois = unicode(QtCore.QDate.longMonthName(the_date.month()))[0:4]
        mois = mois.replace(u'é',u'e')
        jour = unicode(the_date.day())
        annee = unicode(the_date.year())
        date = mois + " " + jour + " " + annee + " "

        self.getEditor().insertPlainText( date )

    ## SETTINGS ENCODING CHANGED
    def settingsEncodingChanged(self, name):
        self.def_encoding = unicode(name)

    ## SHORTCUTS DIALOG
    def showShortCuts(self):
        """Shows the ShortCuts dialog
        """
        Dialog = QtGui.QDialog(self)
        ui = Ui_ShortcutDialog()
        ui.setupUi(Dialog)
        Dialog.show()
        #self.showActionShortCuts()
        tbl = ui.tableWidget

        i=0
        tbl.setRowCount(len(self.actions))
        #print 'nbr actions =' ,len(self.actions)
        for el in self.actions:
            #print 'el text + i =',el.text(),el.shortcut().toString(),i
            it1 = QtGui.QTableWidgetItem(el.text(),0)
            it2 = QtGui.QTableWidgetItem(el.shortcut().toString(),0)
            tbl.setItem(i,1,it1)
            tbl.setItem(i,0,it2)
            i += 1
        tbl.resizeColumnsToContents()

    ## ACTIONS AND SHORTCUTS MANAGEMENT
    def registerActionShortCut(self, act):
        #print 'registerAction =',act, self.sender()
        if act not in self.actions :
            self.actions.append(act)

    ## CAUTION MESSAGES
    def Attention(self, mess):
        message = QtGui.QMessageBox(self)
        message.setText(mess)
        message.setWindowTitle('Attention')
        message.setIcon(QtGui.QMessageBox.Warning)
        message.addButton('Ok', QtGui.QMessageBox.AcceptRole)
        message.exec_()

    ## SETTINGS
    def loadSettings(self):
        settings = QtCore.QSettings()
        size = settings.value("MainWindow/Size",
                              QtCore.QVariant(QtCore.QSize(800, 250))).toSize()
        self.resize(size)
        position = settings.value("MainWindow/Position",
                                  QtCore.QVariant(QtCore.QPoint(0, 0))).toPoint()
        self.move(position)
        self.restoreState(settings.value("MainWindow/State").toByteArray())
        self.def_encoding = settings.value("Encoding",
                              QtCore.QVariant(QtCore.QString("utf8")))
        self.preferedDir = settings.value("Prefered_Directory",
                              QtCore.QVariant(QtCore.QString("utf8"))).toString()

if __name__ == "__main__":
    app = QtGui.QApplication(sys.argv)
    app.setOrganizationName("Kib Ltd")
    app.setOrganizationDomain("kib2.free.fr")
    app.setApplicationName("PyK!")
    window = Myapp()
    window.show()
    if len(sys.argv) == 2 :
        print 'loading the given file'
        window.loadFile(sys.argv[1])

    sys.exit(app.exec_())
