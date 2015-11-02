# -*- coding: utf-8 -*-

# Form implementation generated from reading ui file 'PyEdit.ui'
#
# Created: Sun Dec  9 18:15:51 2007
#      by: PyQt4 UI code generator 4.3
#
# WARNING! All changes made in this file will be lost!

from PyQt4 import QtCore, QtGui

class Ui_PyK(object):
    def setupUi(self, PyK):
        PyK.setObjectName("PyK")
        PyK.resize(QtCore.QSize(QtCore.QRect(0,0,822,600).size()).expandedTo(PyK.minimumSizeHint()))
        PyK.setWindowIcon(QtGui.QIcon(":/PyK.png"))
        PyK.setIconSize(QtCore.QSize(24,24))
        PyK.setDockOptions(QtGui.QMainWindow.AllowTabbedDocks|QtGui.QMainWindow.AnimatedDocks)

        self.centralwidget = QtGui.QWidget(PyK)
        self.centralwidget.setObjectName("centralwidget")

        self.hboxlayout = QtGui.QHBoxLayout(self.centralwidget)
        self.hboxlayout.setObjectName("hboxlayout")

        self.splitterMain = QtGui.QSplitter(self.centralwidget)

        sizePolicy = QtGui.QSizePolicy(QtGui.QSizePolicy.Preferred,QtGui.QSizePolicy.MinimumExpanding)
        sizePolicy.setHorizontalStretch(0)
        sizePolicy.setVerticalStretch(0)
        sizePolicy.setHeightForWidth(self.splitterMain.sizePolicy().hasHeightForWidth())
        self.splitterMain.setSizePolicy(sizePolicy)
        self.splitterMain.setOrientation(QtCore.Qt.Vertical)
        self.splitterMain.setObjectName("splitterMain")

        self.splitterTop = QtGui.QSplitter(self.splitterMain)

        sizePolicy = QtGui.QSizePolicy(QtGui.QSizePolicy.Expanding,QtGui.QSizePolicy.Preferred)
        sizePolicy.setHorizontalStretch(0)
        sizePolicy.setVerticalStretch(1)
        sizePolicy.setHeightForWidth(self.splitterTop.sizePolicy().hasHeightForWidth())
        self.splitterTop.setSizePolicy(sizePolicy)
        self.splitterTop.setOrientation(QtCore.Qt.Horizontal)
        self.splitterTop.setObjectName("splitterTop")

        self.dockWidget_project = QtGui.QDockWidget(self.splitterTop)

        sizePolicy = QtGui.QSizePolicy(QtGui.QSizePolicy.Preferred,QtGui.QSizePolicy.Preferred)
        sizePolicy.setHorizontalStretch(0)
        sizePolicy.setVerticalStretch(1)
        sizePolicy.setHeightForWidth(self.dockWidget_project.sizePolicy().hasHeightForWidth())
        self.dockWidget_project.setSizePolicy(sizePolicy)
        self.dockWidget_project.setWindowIcon(QtGui.QIcon(":/Images/crystal/snake_32.png"))
        self.dockWidget_project.setObjectName("dockWidget_project")

        self.dockWidgetContents = QtGui.QWidget(self.dockWidget_project)
        self.dockWidgetContents.setObjectName("dockWidgetContents")

        self.hboxlayout1 = QtGui.QHBoxLayout(self.dockWidgetContents)
        self.hboxlayout1.setObjectName("hboxlayout1")

        self.tabWidget_projets = QtGui.QTabWidget(self.dockWidgetContents)
        self.tabWidget_projets.setObjectName("tabWidget_projets")

        self.tab_proj = QtGui.QWidget()
        self.tab_proj.setObjectName("tab_proj")

        self.hboxlayout2 = QtGui.QHBoxLayout(self.tab_proj)
        self.hboxlayout2.setObjectName("hboxlayout2")

        self.listWidget_projects = QtGui.QListWidget(self.tab_proj)
        self.listWidget_projects.setObjectName("listWidget_projects")
        self.hboxlayout2.addWidget(self.listWidget_projects)
        self.tabWidget_projets.addTab(self.tab_proj,QtGui.QIcon(":/Images/crystal/projects.png"),"")

        self.tab_plugins = QtGui.QWidget()
        self.tab_plugins.setObjectName("tab_plugins")

        self.hboxlayout3 = QtGui.QHBoxLayout(self.tab_plugins)
        self.hboxlayout3.setObjectName("hboxlayout3")

        self.listWidget_structure = QtGui.QListWidget(self.tab_plugins)
        self.listWidget_structure.setObjectName("listWidget_structure")
        self.hboxlayout3.addWidget(self.listWidget_structure)
        self.tabWidget_projets.addTab(self.tab_plugins,QtGui.QIcon(":/Images/crystal/structure.png"),"")
        self.hboxlayout1.addWidget(self.tabWidget_projets)
        self.dockWidget_project.setWidget(self.dockWidgetContents)

        self.dockWidget_files = QtGui.QDockWidget(self.splitterTop)

        sizePolicy = QtGui.QSizePolicy(QtGui.QSizePolicy.Preferred,QtGui.QSizePolicy.Preferred)
        sizePolicy.setHorizontalStretch(1)
        sizePolicy.setVerticalStretch(1)
        sizePolicy.setHeightForWidth(self.dockWidget_files.sizePolicy().hasHeightForWidth())
        self.dockWidget_files.setSizePolicy(sizePolicy)
        self.dockWidget_files.setWindowIcon(QtGui.QIcon(":/Images/crystal/snake_32.png"))
        self.dockWidget_files.setFeatures(QtGui.QDockWidget.DockWidgetClosable|QtGui.QDockWidget.DockWidgetFloatable|QtGui.QDockWidget.DockWidgetVerticalTitleBar|QtGui.QDockWidget.NoDockWidgetFeatures)
        self.dockWidget_files.setObjectName("dockWidget_files")

        self.dockWidget_files_contents = QtGui.QWidget(self.dockWidget_files)
        self.dockWidget_files_contents.setObjectName("dockWidget_files_contents")

        self.hboxlayout4 = QtGui.QHBoxLayout(self.dockWidget_files_contents)
        self.hboxlayout4.setObjectName("hboxlayout4")
        self.dockWidget_files.setWidget(self.dockWidget_files_contents)

        self.dockWidget_console = QtGui.QDockWidget(self.splitterMain)

        sizePolicy = QtGui.QSizePolicy(QtGui.QSizePolicy.Preferred,QtGui.QSizePolicy.Preferred)
        sizePolicy.setHorizontalStretch(0)
        sizePolicy.setVerticalStretch(0)
        sizePolicy.setHeightForWidth(self.dockWidget_console.sizePolicy().hasHeightForWidth())
        self.dockWidget_console.setSizePolicy(sizePolicy)
        self.dockWidget_console.setObjectName("dockWidget_console")

        self.dockWidget_console_widget = QtGui.QWidget(self.dockWidget_console)
        self.dockWidget_console_widget.setObjectName("dockWidget_console_widget")

        self.hboxlayout5 = QtGui.QHBoxLayout(self.dockWidget_console_widget)
        self.hboxlayout5.setObjectName("hboxlayout5")

        self.tab_console = QtGui.QTabWidget(self.dockWidget_console_widget)

        sizePolicy = QtGui.QSizePolicy(QtGui.QSizePolicy.Preferred,QtGui.QSizePolicy.Preferred)
        sizePolicy.setHorizontalStretch(0)
        sizePolicy.setVerticalStretch(0)
        sizePolicy.setHeightForWidth(self.tab_console.sizePolicy().hasHeightForWidth())
        self.tab_console.setSizePolicy(sizePolicy)
        self.tab_console.setObjectName("tab_console")

        self.tab_output = QtGui.QWidget()
        self.tab_output.setObjectName("tab_output")

        self.hboxlayout6 = QtGui.QHBoxLayout(self.tab_output)
        self.hboxlayout6.setObjectName("hboxlayout6")

        self.console = QtGui.QTextEdit(self.tab_output)

        sizePolicy = QtGui.QSizePolicy(QtGui.QSizePolicy.Preferred,QtGui.QSizePolicy.Preferred)
        sizePolicy.setHorizontalStretch(0)
        sizePolicy.setVerticalStretch(0)
        sizePolicy.setHeightForWidth(self.console.sizePolicy().hasHeightForWidth())
        self.console.setSizePolicy(sizePolicy)
        self.console.setCursor(QtCore.Qt.ArrowCursor)
        self.console.setAcceptDrops(False)
        self.console.setReadOnly(True)
        self.console.setOverwriteMode(True)
        self.console.setObjectName("console")
        self.hboxlayout6.addWidget(self.console)
        self.tab_console.addTab(self.tab_output,QtGui.QIcon(":/Images/crystal/plugins/console.png"),"")

        self.tab_messages = QtGui.QWidget()
        self.tab_messages.setObjectName("tab_messages")

        self.hboxlayout7 = QtGui.QHBoxLayout(self.tab_messages)
        self.hboxlayout7.setObjectName("hboxlayout7")

        self.messages = QtGui.QTextEdit(self.tab_messages)
        self.messages.setObjectName("messages")
        self.hboxlayout7.addWidget(self.messages)
        self.tab_console.addTab(self.tab_messages,QtGui.QIcon(":/Images/crystal/messages.png"),"")
        self.hboxlayout5.addWidget(self.tab_console)
        self.dockWidget_console.setWidget(self.dockWidget_console_widget)
        self.hboxlayout.addWidget(self.splitterMain)
        PyK.setCentralWidget(self.centralwidget)

        self.menubar = QtGui.QMenuBar(PyK)
        self.menubar.setGeometry(QtCore.QRect(0,0,822,27))
        self.menubar.setObjectName("menubar")

        self.menuFiles = QtGui.QMenu(self.menubar)
        self.menuFiles.setObjectName("menuFiles")

        self.menuEdit = QtGui.QMenu(self.menubar)
        self.menuEdit.setObjectName("menuEdit")

        self.menuSearch = QtGui.QMenu(self.menubar)
        self.menuSearch.setObjectName("menuSearch")

        self.menuView = QtGui.QMenu(self.menubar)
        self.menuView.setObjectName("menuView")

        self.menuPlugins = QtGui.QMenu(self.menubar)
        self.menuPlugins.setObjectName("menuPlugins")

        self.menuAbout = QtGui.QMenu(self.menubar)
        self.menuAbout.setObjectName("menuAbout")

        self.menuCommands = QtGui.QMenu(self.menubar)
        self.menuCommands.setObjectName("menuCommands")

        self.menuDocument = QtGui.QMenu(self.menubar)
        self.menuDocument.setObjectName("menuDocument")
        PyK.setMenuBar(self.menubar)

        self.statusbar = QtGui.QStatusBar(PyK)
        self.statusbar.setObjectName("statusbar")
        PyK.setStatusBar(self.statusbar)

        self.toolBar = QtGui.QToolBar(PyK)
        self.toolBar.setObjectName("toolBar")
        PyK.addToolBar(self.toolBar)

        self.actionNew = QtGui.QAction(PyK)
        self.actionNew.setIcon(QtGui.QIcon(":/Images/crystal/filenew.png"))
        self.actionNew.setObjectName("actionNew")

        self.actionOpen = QtGui.QAction(PyK)
        self.actionOpen.setIcon(QtGui.QIcon(":/Images/crystal/fileopen.png"))
        self.actionOpen.setObjectName("actionOpen")

        self.actionSave = QtGui.QAction(PyK)
        self.actionSave.setIcon(QtGui.QIcon(":/Images/crystal/filesave.png"))
        self.actionSave.setObjectName("actionSave")

        self.actionSaveAs = QtGui.QAction(PyK)
        self.actionSaveAs.setIcon(QtGui.QIcon(":/Images/crystal/filesaveas.png"))
        self.actionSaveAs.setObjectName("actionSaveAs")

        self.actionQuit = QtGui.QAction(PyK)
        self.actionQuit.setIcon(QtGui.QIcon(":/Images/crystal/exit.png"))
        self.actionQuit.setObjectName("actionQuit")

        self.actionClose = QtGui.QAction(PyK)
        self.actionClose.setIcon(QtGui.QIcon(":/Images/crystal/fileclose.png"))
        self.actionClose.setObjectName("actionClose")

        self.actionAbout = QtGui.QAction(PyK)
        self.actionAbout.setIcon(QtGui.QIcon(":/Images/crystal/help_new.png"))
        self.actionAbout.setObjectName("actionAbout")

        self.actionShortCuts = QtGui.QAction(PyK)
        self.actionShortCuts.setIcon(QtGui.QIcon(":/Images/crystal/shortcuts.png"))
        self.actionShortCuts.setObjectName("actionShortCuts")

        self.actionShow_shortcuts = QtGui.QAction(PyK)
        self.actionShow_shortcuts.setIcon(QtGui.QIcon(":/Images/crystal/shortcuts.png"))
        self.actionShow_shortcuts.setObjectName("actionShow_shortcuts")

        self.actionWrite_a_BOM_Unicode = QtGui.QAction(PyK)
        self.actionWrite_a_BOM_Unicode.setCheckable(True)
        self.actionWrite_a_BOM_Unicode.setObjectName("actionWrite_a_BOM_Unicode")

        self.actionViewProjectPane = QtGui.QAction(PyK)
        self.actionViewProjectPane.setCheckable(True)
        self.actionViewProjectPane.setChecked(False)
        self.actionViewProjectPane.setObjectName("actionViewProjectPane")

        self.actionViewConsolePane = QtGui.QAction(PyK)
        self.actionViewConsolePane.setCheckable(True)
        self.actionViewConsolePane.setChecked(True)
        self.actionViewConsolePane.setIcon(QtGui.QIcon(":/Images/crystal/plugins/console.png"))
        self.actionViewConsolePane.setObjectName("actionViewConsolePane")

        self.actionPrint = QtGui.QAction(PyK)
        self.actionPrint.setObjectName("actionPrint")

        self.actionSettings = QtGui.QAction(PyK)
        self.actionSettings.setIcon(QtGui.QIcon(":/Images/crystal/settings.png"))
        self.actionSettings.setObjectName("actionSettings")

        self.actionColorDialog = QtGui.QAction(PyK)
        self.actionColorDialog.setIcon(QtGui.QIcon(":/Images/crystal/plugins/cell_32.png"))
        self.actionColorDialog.setObjectName("actionColorDialog")

        self.actionCalendar = QtGui.QAction(PyK)
        self.actionCalendar.setIcon(QtGui.QIcon(":/Images/crystal/cal.png"))
        self.actionCalendar.setObjectName("actionCalendar")
        self.menuFiles.addAction(self.actionNew)
        self.menuFiles.addAction(self.actionOpen)
        self.menuFiles.addAction(self.actionSave)
        self.menuFiles.addAction(self.actionSaveAs)
        self.menuFiles.addAction(self.actionClose)
        self.menuFiles.addSeparator()
        self.menuFiles.addAction(self.actionPrint)
        self.menuFiles.addSeparator()
        self.menuFiles.addAction(self.actionSettings)
        self.menuFiles.addSeparator()
        self.menuFiles.addAction(self.actionQuit)
        self.menuView.addAction(self.actionViewProjectPane)
        self.menuView.addAction(self.actionViewConsolePane)
        self.menuView.addAction(self.actionColorDialog)
        self.menuView.addAction(self.actionCalendar)
        self.menuAbout.addAction(self.actionAbout)
        self.menuDocument.addAction(self.actionWrite_a_BOM_Unicode)
        self.menubar.addAction(self.menuFiles.menuAction())
        self.menubar.addAction(self.menuEdit.menuAction())
        self.menubar.addAction(self.menuDocument.menuAction())
        self.menubar.addAction(self.menuSearch.menuAction())
        self.menubar.addAction(self.menuView.menuAction())
        self.menubar.addAction(self.menuPlugins.menuAction())
        self.menubar.addAction(self.menuCommands.menuAction())
        self.menubar.addAction(self.menuAbout.menuAction())
        self.toolBar.addAction(self.actionNew)
        self.toolBar.addAction(self.actionOpen)
        self.toolBar.addAction(self.actionSave)
        self.toolBar.addAction(self.actionSaveAs)
        self.toolBar.addAction(self.actionClose)
        self.toolBar.addSeparator()
        self.toolBar.addAction(self.actionShortCuts)
        self.toolBar.addAction(self.actionSettings)
        self.toolBar.addAction(self.actionAbout)
        self.toolBar.addSeparator()
        self.toolBar.addAction(self.actionColorDialog)
        self.toolBar.addSeparator()
        self.toolBar.addAction(self.actionQuit)

        self.retranslateUi(PyK)
        self.tabWidget_projets.setCurrentIndex(1)
        self.tab_console.setCurrentIndex(0)
        QtCore.QObject.connect(self.actionQuit,QtCore.SIGNAL("triggered()"),PyK.close)
        QtCore.QMetaObject.connectSlotsByName(PyK)

    def retranslateUi(self, PyK):
        PyK.setWindowTitle(QtGui.QApplication.translate("PyK", "PyK", None, QtGui.QApplication.UnicodeUTF8))
        self.dockWidget_project.setWindowTitle(QtGui.QApplication.translate("PyK", "Projects", None, QtGui.QApplication.UnicodeUTF8))
        self.tabWidget_projets.setTabText(self.tabWidget_projets.indexOf(self.tab_proj), QtGui.QApplication.translate("PyK", "Projects", None, QtGui.QApplication.UnicodeUTF8))
        self.tabWidget_projets.setTabText(self.tabWidget_projets.indexOf(self.tab_plugins), QtGui.QApplication.translate("PyK", "Structure", None, QtGui.QApplication.UnicodeUTF8))
        self.dockWidget_files.setWindowTitle(QtGui.QApplication.translate("PyK", "Files", None, QtGui.QApplication.UnicodeUTF8))
        self.dockWidget_console.setWindowTitle(QtGui.QApplication.translate("PyK", "Console", None, QtGui.QApplication.UnicodeUTF8))
        self.console.setHtml(QtGui.QApplication.translate("PyK", "<html><head><meta name=\"qrichtext\" content=\"1\" /><style type=\"text/css\">\n"
        "p, li { white-space: pre-wrap; }\n"
        "</style></head><body style=\" font-family:\'Sans Serif\'; font-size:10pt; font-weight:400; font-style:normal;\">\n"
        "<p style=\"-qt-paragraph-type:empty; margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px; font-family:\'DejaVu Sans Mono\'; font-size:8pt;\"></p></body></html>", None, QtGui.QApplication.UnicodeUTF8))
        self.tab_console.setTabText(self.tab_console.indexOf(self.tab_output), QtGui.QApplication.translate("PyK", "Output", None, QtGui.QApplication.UnicodeUTF8))
        self.tab_console.setTabText(self.tab_console.indexOf(self.tab_messages), QtGui.QApplication.translate("PyK", "Messages", None, QtGui.QApplication.UnicodeUTF8))
        self.menuFiles.setTitle(QtGui.QApplication.translate("PyK", "&Files", None, QtGui.QApplication.UnicodeUTF8))
        self.menuEdit.setTitle(QtGui.QApplication.translate("PyK", "&Edit", None, QtGui.QApplication.UnicodeUTF8))
        self.menuSearch.setTitle(QtGui.QApplication.translate("PyK", "&Search", None, QtGui.QApplication.UnicodeUTF8))
        self.menuView.setTitle(QtGui.QApplication.translate("PyK", "&View", None, QtGui.QApplication.UnicodeUTF8))
        self.menuPlugins.setTitle(QtGui.QApplication.translate("PyK", "&Plugins", None, QtGui.QApplication.UnicodeUTF8))
        self.menuAbout.setTitle(QtGui.QApplication.translate("PyK", "&About", None, QtGui.QApplication.UnicodeUTF8))
        self.menuCommands.setTitle(QtGui.QApplication.translate("PyK", "&Commands", None, QtGui.QApplication.UnicodeUTF8))
        self.menuDocument.setTitle(QtGui.QApplication.translate("PyK", "&Document", None, QtGui.QApplication.UnicodeUTF8))
        self.toolBar.setWindowTitle(QtGui.QApplication.translate("PyK", "toolBar", None, QtGui.QApplication.UnicodeUTF8))
        self.actionNew.setText(QtGui.QApplication.translate("PyK", "New", None, QtGui.QApplication.UnicodeUTF8))
        self.actionNew.setShortcut(QtGui.QApplication.translate("PyK", "Ctrl+N", None, QtGui.QApplication.UnicodeUTF8))
        self.actionOpen.setText(QtGui.QApplication.translate("PyK", "Open", None, QtGui.QApplication.UnicodeUTF8))
        self.actionOpen.setShortcut(QtGui.QApplication.translate("PyK", "Ctrl+O", None, QtGui.QApplication.UnicodeUTF8))
        self.actionSave.setText(QtGui.QApplication.translate("PyK", "Save", None, QtGui.QApplication.UnicodeUTF8))
        self.actionSave.setShortcut(QtGui.QApplication.translate("PyK", "Ctrl+S", None, QtGui.QApplication.UnicodeUTF8))
        self.actionSaveAs.setText(QtGui.QApplication.translate("PyK", "Save As", None, QtGui.QApplication.UnicodeUTF8))
        self.actionSaveAs.setShortcut(QtGui.QApplication.translate("PyK", "Ctrl+S, Ctrl+A", None, QtGui.QApplication.UnicodeUTF8))
        self.actionQuit.setText(QtGui.QApplication.translate("PyK", "Quit", None, QtGui.QApplication.UnicodeUTF8))
        self.actionQuit.setShortcut(QtGui.QApplication.translate("PyK", "Ctrl+Q", None, QtGui.QApplication.UnicodeUTF8))
        self.actionClose.setText(QtGui.QApplication.translate("PyK", "Close", None, QtGui.QApplication.UnicodeUTF8))
        self.actionClose.setShortcut(QtGui.QApplication.translate("PyK", "Ctrl+Shift+C", None, QtGui.QApplication.UnicodeUTF8))
        self.actionAbout.setText(QtGui.QApplication.translate("PyK", "About PyK", None, QtGui.QApplication.UnicodeUTF8))
        self.actionAbout.setShortcut(QtGui.QApplication.translate("PyK", "Ctrl+H", None, QtGui.QApplication.UnicodeUTF8))
        self.actionShortCuts.setText(QtGui.QApplication.translate("PyK", "ShowShortCuts", None, QtGui.QApplication.UnicodeUTF8))
        self.actionShortCuts.setShortcut(QtGui.QApplication.translate("PyK", "Ctrl+Alt+S", None, QtGui.QApplication.UnicodeUTF8))
        self.actionShow_shortcuts.setText(QtGui.QApplication.translate("PyK", "show shortcuts", None, QtGui.QApplication.UnicodeUTF8))
        self.actionWrite_a_BOM_Unicode.setText(QtGui.QApplication.translate("PyK", "Write a BOM Unicode", None, QtGui.QApplication.UnicodeUTF8))
        self.actionViewProjectPane.setText(QtGui.QApplication.translate("PyK", "Project Pane", None, QtGui.QApplication.UnicodeUTF8))
        self.actionViewConsolePane.setText(QtGui.QApplication.translate("PyK", "Console Pane", None, QtGui.QApplication.UnicodeUTF8))
        self.actionPrint.setText(QtGui.QApplication.translate("PyK", "Print", None, QtGui.QApplication.UnicodeUTF8))
        self.actionPrint.setShortcut(QtGui.QApplication.translate("PyK", "Ctrl+P", None, QtGui.QApplication.UnicodeUTF8))
        self.actionSettings.setText(QtGui.QApplication.translate("PyK", "Settings", None, QtGui.QApplication.UnicodeUTF8))
        self.actionColorDialog.setText(QtGui.QApplication.translate("PyK", "Color Dialog", None, QtGui.QApplication.UnicodeUTF8))
        self.actionCalendar.setText(QtGui.QApplication.translate("PyK", "Calendar", None, QtGui.QApplication.UnicodeUTF8))
        self.actionCalendar.setShortcut(QtGui.QApplication.translate("PyK", "Alt+V, Alt+C", None, QtGui.QApplication.UnicodeUTF8))

import pyedit_rc


if __name__ == "__main__":
    import sys
    app = QtGui.QApplication(sys.argv)
    PyK = QtGui.QMainWindow()
    ui = Ui_PyK()
    ui.setupUi(PyK)
    PyK.show()
    sys.exit(app.exec_())
