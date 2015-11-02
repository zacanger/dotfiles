# -*- coding: utf-8 -*-

# Form implementation generated from reading ui file 'PyKsettings.ui'
#
# Created: Sat Dec  1 15:06:54 2007
#      by: PyQt4 UI code generator 4.3
#
# WARNING! All changes made in this file will be lost!

from PyQt4 import QtCore, QtGui

class Ui_PyKsettings(object):
    def setupUi(self, PyKsettings):
        PyKsettings.setObjectName("PyKsettings")
        PyKsettings.resize(QtCore.QSize(QtCore.QRect(0,0,310,265).size()).expandedTo(PyKsettings.minimumSizeHint()))

        self.hboxlayout = QtGui.QHBoxLayout(PyKsettings)
        self.hboxlayout.setObjectName("hboxlayout")

        self.vboxlayout = QtGui.QVBoxLayout()
        self.vboxlayout.setObjectName("vboxlayout")

        self.toolBox = QtGui.QToolBox(PyKsettings)
        self.toolBox.setObjectName("toolBox")

        self.page = QtGui.QWidget()
        self.page.setGeometry(QtCore.QRect(0,0,290,108))
        self.page.setObjectName("page")

        self.frame = QtGui.QFrame(self.page)
        self.frame.setGeometry(QtCore.QRect(3,10,276,84))
        self.frame.setFrameShape(QtGui.QFrame.StyledPanel)
        self.frame.setFrameShadow(QtGui.QFrame.Raised)
        self.frame.setObjectName("frame")

        self.layoutWidget = QtGui.QWidget(self.frame)
        self.layoutWidget.setGeometry(QtCore.QRect(10,11,256,62))
        self.layoutWidget.setObjectName("layoutWidget")

        self.vboxlayout1 = QtGui.QVBoxLayout(self.layoutWidget)
        self.vboxlayout1.setObjectName("vboxlayout1")

        self.hboxlayout1 = QtGui.QHBoxLayout()
        self.hboxlayout1.setObjectName("hboxlayout1")

        self.label = QtGui.QLabel(self.layoutWidget)
        self.label.setObjectName("label")
        self.hboxlayout1.addWidget(self.label)

        spacerItem = QtGui.QSpacerItem(40,20,QtGui.QSizePolicy.Expanding,QtGui.QSizePolicy.Minimum)
        self.hboxlayout1.addItem(spacerItem)

        self.encodeCombo = QtGui.QComboBox(self.layoutWidget)
        self.encodeCombo.setObjectName("encodeCombo")
        self.hboxlayout1.addWidget(self.encodeCombo)
        self.vboxlayout1.addLayout(self.hboxlayout1)

        self.bom_checkBox = QtGui.QCheckBox(self.layoutWidget)
        self.bom_checkBox.setObjectName("bom_checkBox")
        self.vboxlayout1.addWidget(self.bom_checkBox)
        self.toolBox.addItem(self.page,QtGui.QIcon(":/Images/crystal/configure.png"),"")

        self.page_2 = QtGui.QWidget()
        self.page_2.setGeometry(QtCore.QRect(0,0,290,108))
        self.page_2.setObjectName("page_2")
        self.toolBox.addItem(self.page_2,QtGui.QIcon(":/Images/crystal/plugins/cell_32.png"),"")

        self.page_3 = QtGui.QWidget()
        self.page_3.setGeometry(QtCore.QRect(0,0,96,26))
        self.page_3.setObjectName("page_3")
        self.toolBox.addItem(self.page_3,QtGui.QIcon(":/Images/crystal/fileopen.png"),"")
        self.vboxlayout.addWidget(self.toolBox)

        self.buttonBox = QtGui.QDialogButtonBox(PyKsettings)
        self.buttonBox.setOrientation(QtCore.Qt.Horizontal)
        self.buttonBox.setStandardButtons(QtGui.QDialogButtonBox.Cancel|QtGui.QDialogButtonBox.NoButton|QtGui.QDialogButtonBox.Ok)
        self.buttonBox.setObjectName("buttonBox")
        self.vboxlayout.addWidget(self.buttonBox)
        self.hboxlayout.addLayout(self.vboxlayout)

        self.retranslateUi(PyKsettings)
        self.toolBox.setCurrentIndex(0)
        QtCore.QObject.connect(self.buttonBox,QtCore.SIGNAL("accepted()"),PyKsettings.accept)
        QtCore.QObject.connect(self.buttonBox,QtCore.SIGNAL("rejected()"),PyKsettings.reject)
        QtCore.QMetaObject.connectSlotsByName(PyKsettings)

    def retranslateUi(self, PyKsettings):
        PyKsettings.setWindowTitle(QtGui.QApplication.translate("PyKsettings", "Dialog", None, QtGui.QApplication.UnicodeUTF8))
        self.label.setText(QtGui.QApplication.translate("PyKsettings", "Default encoding:", None, QtGui.QApplication.UnicodeUTF8))
        self.bom_checkBox.setText(QtGui.QApplication.translate("PyKsettings", "BOM in utf-8", None, QtGui.QApplication.UnicodeUTF8))
        self.toolBox.setItemText(self.toolBox.indexOf(self.page), QtGui.QApplication.translate("PyKsettings", "Encoding", None, QtGui.QApplication.UnicodeUTF8))
        self.toolBox.setItemText(self.toolBox.indexOf(self.page_2), QtGui.QApplication.translate("PyKsettings", "Highlightning rules", None, QtGui.QApplication.UnicodeUTF8))
        self.toolBox.setItemText(self.toolBox.indexOf(self.page_3), QtGui.QApplication.translate("PyKsettings", "Files", None, QtGui.QApplication.UnicodeUTF8))

import pyedit_rc


if __name__ == "__main__":
    import sys
    app = QtGui.QApplication(sys.argv)
    PyKsettings = QtGui.QDialog()
    ui = Ui_PyKsettings()
    ui.setupUi(PyKsettings)
    PyKsettings.show()
    sys.exit(app.exec_())
