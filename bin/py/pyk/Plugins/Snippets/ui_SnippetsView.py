# -*- coding: utf-8 -*-

# Form implementation generated from reading ui file 'ui_SnippetsView.ui'
#
# Created: Wed Dec  5 23:00:57 2007
#      by: PyQt4 UI code generator 4.3
#
# WARNING! All changes made in this file will be lost!

from PyQt4 import QtCore, QtGui

class Ui_SnippetsDialog(object):
    def setupUi(self, SnippetsDialog):
        SnippetsDialog.setObjectName("SnippetsDialog")
        SnippetsDialog.resize(QtCore.QSize(QtCore.QRect(0,0,650,300).size()).expandedTo(SnippetsDialog.minimumSizeHint()))

        self.vboxlayout = QtGui.QVBoxLayout(SnippetsDialog)
        self.vboxlayout.setSpacing(4)
        self.vboxlayout.setMargin(2)
        self.vboxlayout.setObjectName("vboxlayout")

        self.tableWidget = QtGui.QTableWidget(SnippetsDialog)
        self.tableWidget.setAlternatingRowColors(True)
        self.tableWidget.setSelectionMode(QtGui.QAbstractItemView.NoSelection)
        self.tableWidget.setSelectionBehavior(QtGui.QAbstractItemView.SelectRows)
        self.tableWidget.setGridStyle(QtCore.Qt.DashLine)
        self.tableWidget.setSortingEnabled(False)
        self.tableWidget.setObjectName("tableWidget")
        self.vboxlayout.addWidget(self.tableWidget)

        self.hboxlayout = QtGui.QHBoxLayout()
        self.hboxlayout.setSpacing(2)
        self.hboxlayout.setMargin(0)
        self.hboxlayout.setObjectName("hboxlayout")

        spacerItem = QtGui.QSpacerItem(131,31,QtGui.QSizePolicy.Expanding,QtGui.QSizePolicy.Minimum)
        self.hboxlayout.addItem(spacerItem)

        self.okButton = QtGui.QPushButton(SnippetsDialog)
        self.okButton.setObjectName("okButton")
        self.hboxlayout.addWidget(self.okButton)

        self.cancelButton = QtGui.QPushButton(SnippetsDialog)
        self.cancelButton.setObjectName("cancelButton")
        self.hboxlayout.addWidget(self.cancelButton)
        self.vboxlayout.addLayout(self.hboxlayout)

        self.retranslateUi(SnippetsDialog)
        QtCore.QObject.connect(self.okButton,QtCore.SIGNAL("clicked()"),SnippetsDialog.accept)
        QtCore.QObject.connect(self.cancelButton,QtCore.SIGNAL("clicked()"),SnippetsDialog.reject)
        QtCore.QMetaObject.connectSlotsByName(SnippetsDialog)

    def retranslateUi(self, SnippetsDialog):
        SnippetsDialog.setWindowTitle(QtGui.QApplication.translate("SnippetsDialog", "Snippets Viewer", None, QtGui.QApplication.UnicodeUTF8))
        self.tableWidget.clear()
        self.tableWidget.setColumnCount(3)
        self.tableWidget.setRowCount(0)

        headerItem = QtGui.QTableWidgetItem()
        headerItem.setText(QtGui.QApplication.translate("SnippetsDialog", "Trigger", None, QtGui.QApplication.UnicodeUTF8))
        headerItem.setIcon(QtGui.QIcon(":/ImagesSnippetsView/snippets.png"))
        self.tableWidget.setHorizontalHeaderItem(0,headerItem)

        headerItem1 = QtGui.QTableWidgetItem()
        headerItem1.setText(QtGui.QApplication.translate("SnippetsDialog", "Description", None, QtGui.QApplication.UnicodeUTF8))
        headerItem1.setIcon(QtGui.QIcon(":/ImagesSnippetsView/desc.png"))
        self.tableWidget.setHorizontalHeaderItem(1,headerItem1)

        headerItem2 = QtGui.QTableWidgetItem()
        headerItem2.setText(QtGui.QApplication.translate("SnippetsDialog", "Code", None, QtGui.QApplication.UnicodeUTF8))
        headerItem2.setIcon(QtGui.QIcon(":/ImagesSnippetsView/code.png"))
        self.tableWidget.setHorizontalHeaderItem(2,headerItem2)
        self.okButton.setText(QtGui.QApplication.translate("SnippetsDialog", "OK", None, QtGui.QApplication.UnicodeUTF8))
        self.cancelButton.setText(QtGui.QApplication.translate("SnippetsDialog", "Cancel", None, QtGui.QApplication.UnicodeUTF8))

import qrc_snippetsViewer_rc


if __name__ == "__main__":
    import sys
    app = QtGui.QApplication(sys.argv)
    SnippetsDialog = QtGui.QDialog()
    ui = Ui_SnippetsDialog()
    ui.setupUi(SnippetsDialog)
    SnippetsDialog.show()
    sys.exit(app.exec_())
