# -*- coding: utf-8 -*-

# Form implementation generated from reading ui file 'ui_arraydialog.ui'
#
# Created: Sun Oct 28 18:04:00 2007
#      by: PyQt4 UI code generator 4.3
#
# WARNING! All changes made in this file will be lost!

from PyQt4 import QtCore, QtGui

class Ui_ArrayDialog(object):
    def setupUi(self, ArrayDialog):
        ArrayDialog.setObjectName("ArrayDialog")
        ArrayDialog.resize(QtCore.QSize(QtCore.QRect(0,0,472,393).size()).expandedTo(ArrayDialog.minimumSizeHint()))

        self.gridlayout = QtGui.QGridLayout(ArrayDialog)
        self.gridlayout.setMargin(9)
        self.gridlayout.setSpacing(6)
        self.gridlayout.setObjectName("gridlayout")

        self.gridlayout1 = QtGui.QGridLayout()
        self.gridlayout1.setMargin(0)
        self.gridlayout1.setSpacing(6)
        self.gridlayout1.setObjectName("gridlayout1")

        self.label_3 = QtGui.QLabel(ArrayDialog)
        self.label_3.setObjectName("label_3")
        self.gridlayout1.addWidget(self.label_3,2,0,1,1)

        self.tableWidget = QtGui.QTableWidget(ArrayDialog)
        self.tableWidget.setObjectName("tableWidget")
        self.gridlayout1.addWidget(self.tableWidget,0,0,1,2)

        self.spinBoxColumns = QtGui.QSpinBox(ArrayDialog)
        self.spinBoxColumns.setMinimum(1)
        self.spinBoxColumns.setProperty("value",QtCore.QVariant(2))
        self.spinBoxColumns.setObjectName("spinBoxColumns")
        self.gridlayout1.addWidget(self.spinBoxColumns,2,1,1,1)

        self.spinBoxRows = QtGui.QSpinBox(ArrayDialog)
        self.spinBoxRows.setProperty("value",QtCore.QVariant(2))
        self.spinBoxRows.setObjectName("spinBoxRows")
        self.gridlayout1.addWidget(self.spinBoxRows,1,1,1,1)

        self.label_4 = QtGui.QLabel(ArrayDialog)
        self.label_4.setObjectName("label_4")
        self.gridlayout1.addWidget(self.label_4,1,0,1,1)
        self.gridlayout.addLayout(self.gridlayout1,0,0,1,1)

        self.hboxlayout = QtGui.QHBoxLayout()
        self.hboxlayout.setSpacing(6)
        self.hboxlayout.setMargin(0)
        self.hboxlayout.setObjectName("hboxlayout")

        spacerItem = QtGui.QSpacerItem(131,31,QtGui.QSizePolicy.Expanding,QtGui.QSizePolicy.Minimum)
        self.hboxlayout.addItem(spacerItem)

        self.okButton = QtGui.QPushButton(ArrayDialog)
        self.okButton.setObjectName("okButton")
        self.hboxlayout.addWidget(self.okButton)

        self.cancelButton = QtGui.QPushButton(ArrayDialog)
        self.cancelButton.setObjectName("cancelButton")
        self.hboxlayout.addWidget(self.cancelButton)
        self.gridlayout.addLayout(self.hboxlayout,1,0,1,1)

        self.retranslateUi(ArrayDialog)
        QtCore.QMetaObject.connectSlotsByName(ArrayDialog)

    def retranslateUi(self, ArrayDialog):
        self.label_3.setText(QtGui.QApplication.translate("ArrayDialog", "Number of columns", None, QtGui.QApplication.UnicodeUTF8))
        self.tableWidget.setRowCount(0)
        self.tableWidget.setColumnCount(0)
        self.tableWidget.clear()
        self.tableWidget.setColumnCount(0)
        self.tableWidget.setRowCount(0)
        self.label_4.setText(QtGui.QApplication.translate("ArrayDialog", "Number of rows:", None, QtGui.QApplication.UnicodeUTF8))
        self.okButton.setText(QtGui.QApplication.translate("ArrayDialog", "OK", None, QtGui.QApplication.UnicodeUTF8))
        self.cancelButton.setText(QtGui.QApplication.translate("ArrayDialog", "Cancel", None, QtGui.QApplication.UnicodeUTF8))



if __name__ == "__main__":
    import sys
    app = QtGui.QApplication(sys.argv)
    ArrayDialog = QtGui.QDialog()
    ui = Ui_ArrayDialog()
    ui.setupUi(ArrayDialog)
    ArrayDialog.show()
    sys.exit(app.exec_())
