# -*- coding: utf-8 -*-

# Form implementation generated from reading ui file 'browser_dialog.ui'
#
# Created: Sun Dec  2 21:11:12 2007
#      by: PyQt4 UI code generator 4.3
#
# WARNING! All changes made in this file will be lost!

from PyQt4 import QtCore, QtGui

class Ui_BrowserDialog(object):
    def setupUi(self, BrowserDialog):
        BrowserDialog.setObjectName("BrowserDialog")
        BrowserDialog.resize(QtCore.QSize(QtCore.QRect(0,0,532,476).size()).expandedTo(BrowserDialog.minimumSizeHint()))

        self.hboxlayout = QtGui.QHBoxLayout(BrowserDialog)
        self.hboxlayout.setObjectName("hboxlayout")

        self.browser = browser(BrowserDialog)
        self.browser.setObjectName("browser")
        self.hboxlayout.addWidget(self.browser)

        self.retranslateUi(BrowserDialog)
        QtCore.QMetaObject.connectSlotsByName(BrowserDialog)

    def retranslateUi(self, BrowserDialog):
        BrowserDialog.setWindowTitle(QtGui.QApplication.translate("BrowserDialog", "PyK Browser", None, QtGui.QApplication.UnicodeUTF8))

from browser import browser


if __name__ == "__main__":
    import sys
    app = QtGui.QApplication(sys.argv)
    BrowserDialog = QtGui.QDialog()
    ui = Ui_BrowserDialog()
    ui.setupUi(BrowserDialog)
    BrowserDialog.show()
    sys.exit(app.exec_())
