#!/usr/bin/env python

import sys
from PyQt5.QtWidgets import QApplication, QWidget, QPushButton, QColorDialog
from PyQt5.QtGui import QIcon
from PyQt5.QtCore import pyqtSlot
from PyQt5.QtGui import QColor


def openColorDialog(_):
    color = QColorDialog.getColor()


class App(QWidget):
    def __init__(self):
        super().__init__()
        self.title = 'colorpicker'
        self.left = 10
        self.top = 10
        self.width = 320
        self.height = 200
        self.initUI()

    def initUI(self):
        self.setWindowTitle(self.title)
        self.setGeometry(self.left, self.top, self.width, self.height)

        button = QPushButton('open color picker', self)
        button.move(10, 10)
        button.clicked.connect(self.on_click)

        quit_button = QPushButton('Quit', self)
        quit_button.move(10, 40)
        quit_button.clicked.connect(self.close)

        self.show()

    @pyqtSlot()
    def on_click(self):
        openColorDialog(self)


if __name__ == '__main__':
    app = QApplication(sys.argv)
    ex = App()
    sys.exit(app.exec_())