# -*- coding: utf-8 -*-

# Form implementation generated from reading ui file 'ui_ShortCutsView.ui'
#
# Created: Sun Nov 25 21:23:34 2007
#      by: PyQt4 UI code generator 4.3
#
# WARNING! All changes made in this file will be lost!

from PyQt4 import QtCore, QtGui

class Ui_ShortcutDialog(object):
    def setupUi(self, ShortcutDialog):
        ShortcutDialog.setObjectName("ShortcutDialog")
        ShortcutDialog.resize(QtCore.QSize(QtCore.QRect(0,0,400,300).size()).expandedTo(ShortcutDialog.minimumSizeHint()))

        self.vboxlayout = QtGui.QVBoxLayout(ShortcutDialog)
        self.vboxlayout.setSpacing(4)
        self.vboxlayout.setMargin(2)
        self.vboxlayout.setObjectName("vboxlayout")

        self.tableWidget = QtGui.QTableWidget(ShortcutDialog)
        self.tableWidget.setAlternatingRowColors(True)
        self.tableWidget.setGridStyle(QtCore.Qt.DashLine)
        self.tableWidget.setSortingEnabled(True)
        self.tableWidget.setObjectName("tableWidget")
        self.vboxlayout.addWidget(self.tableWidget)

        self.hboxlayout = QtGui.QHBoxLayout()
        self.hboxlayout.setSpacing(2)
        self.hboxlayout.setMargin(0)
        self.hboxlayout.setObjectName("hboxlayout")

        spacerItem = QtGui.QSpacerItem(131,31,QtGui.QSizePolicy.Expanding,QtGui.QSizePolicy.Minimum)
        self.hboxlayout.addItem(spacerItem)

        self.okButton = QtGui.QPushButton(ShortcutDialog)
        self.okButton.setObjectName("okButton")
        self.hboxlayout.addWidget(self.okButton)

        self.cancelButton = QtGui.QPushButton(ShortcutDialog)
        self.cancelButton.setObjectName("cancelButton")
        self.hboxlayout.addWidget(self.cancelButton)
        self.vboxlayout.addLayout(self.hboxlayout)

        self.retranslateUi(ShortcutDialog)
        QtCore.QObject.connect(self.okButton,QtCore.SIGNAL("clicked()"),ShortcutDialog.accept)
        QtCore.QObject.connect(self.cancelButton,QtCore.SIGNAL("clicked()"),ShortcutDialog.reject)
        QtCore.QMetaObject.connectSlotsByName(ShortcutDialog)

    def retranslateUi(self, ShortcutDialog):
        ShortcutDialog.setWindowTitle(QtGui.QApplication.translate("ShortcutDialog", "ShortCuts Viewer", None, QtGui.QApplication.UnicodeUTF8))
        self.tableWidget.clear()
        self.tableWidget.setColumnCount(2)
        self.tableWidget.setRowCount(0)

        headerItem = QtGui.QTableWidgetItem()
        headerItem.setText(QtGui.QApplication.translate("ShortcutDialog", "ShortCut", None, QtGui.QApplication.UnicodeUTF8))
        headerItem.setIcon(QtGui.QIcon(":/Images/crystal/plugins/uranium_32.png"))
        self.tableWidget.setHorizontalHeaderItem(0,headerItem)

        headerItem1 = QtGui.QTableWidgetItem()
        headerItem1.setText(QtGui.QApplication.translate("ShortcutDialog", "Action", None, QtGui.QApplication.UnicodeUTF8))
        headerItem1.setIcon(QtGui.QIcon(":/Images/crystal/plugins/test_tube_1_32.png"))
        self.tableWidget.setHorizontalHeaderItem(1,headerItem1)
        self.okButton.setText(QtGui.QApplication.translate("ShortcutDialog", "OK", None, QtGui.QApplication.UnicodeUTF8))
        self.cancelButton.setText(QtGui.QApplication.translate("ShortcutDialog", "Cancel", None, QtGui.QApplication.UnicodeUTF8))

import pyedit_rc


if __name__ == "__main__":
    import sys
    app = QtGui.QApplication(sys.argv)
    ShortcutDialog = QtGui.QDialog()
    ui = Ui_ShortcutDialog()
    ui.setupUi(ShortcutDialog)
    ShortcutDialog.show()
    sys.exit(app.exec_())
