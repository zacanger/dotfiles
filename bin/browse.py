#!/usr/bin/env python3

import sys
import time
import codecs
from urllib.parse import quote_plus as qp
from PyQt5.QtWidgets import *
from PyQt5.QtCore import QUrl, QByteArray
from PyQt5.QtGui import QKeySequence
from PyQt5.QtWebEngineWidgets import *
from PyQt5 import QtWebEngineWidgets, QtNetwork
from PyQt5.Qt import pyqtSlot, pyqtSignal, Qt

"""
Originally based on https://github.com/Pebaz/LeafBrowser
Requires these packages on Ubuntu:
python3-pyqt5 python3-pyqt5.qtwebengine libqt5webenginewidgets5
"""


USER_AGENT = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 \
(KHTML, like Gecko) Chrome/86.0.4240.111 Safari/537.36"


class BrowserTab(QWidget):
    def __init__(self, page="https://duckduckgo.com", socks5=True):
        QWidget.__init__(self)

        # Widgets
        self.browser = QWebEngineView()
        self.addr_bar = QLineEdit(page)
        self.search = QLineEdit()
        self.find = QLineEdit()
        self.progress = QProgressBar()
        sbox = QHBoxLayout()
        sbox.addWidget(QLabel("DDG"))
        sbox.addWidget(self.search)
        hbox = QHBoxLayout()
        self.lbl_find = QLabel("Find")
        self.hide_find()
        hbox.addWidget(self.lbl_find)
        hbox.addWidget(self.find)
        addrbox = QHBoxLayout()
        back = QPushButton("<")
        back.setMaximumSize(32, 24)
        back.clicked.connect(self.browser.back)
        forward = QPushButton(">")
        forward.setMaximumSize(31, 24)
        forward.clicked.connect(self.browser.forward)
        addrbox.addWidget(back)
        addrbox.addWidget(forward)
        quit = QPushButton("Q")
        quit_short = QShortcut(QKeySequence("Ctrl+Q"), self)
        quit_short.activated.connect(QApplication.instance().quit)
        quit.clicked.connect(QApplication.instance().quit)
        addrbox.addWidget(quit)
        addrbox.addWidget(self.addr_bar)

        vbox = QVBoxLayout()
        vbox.addLayout(addrbox)
        vbox.addLayout(sbox)
        vbox.addLayout(hbox)
        vbox.addWidget(self.progress)
        vbox.addWidget(self.browser)

        # find
        find_short = QShortcut(QKeySequence("Ctrl+F"), self)
        find_short.activated.connect(self.show_find)
        find_hide = QShortcut(QKeySequence("Escape"), self)
        find_hide.activated.connect(self.hide_find)

        # Signals and Slots
        self.addr_bar.returnPressed.connect(
            lambda: self.browser.load(QUrl(self.addr_bar.text()))
        )
        self.search.returnPressed.connect(
            lambda: self.browser.load(
                QUrl(f"https://www.duckduckgo.com/?q={qp(self.search.text())}")
            )
        )
        self.find.returnPressed.connect(
            lambda: self.browser.page().findText(self.find.text())
        )
        self.browser.urlChanged.connect(self.handle_url_change)
        self.browser.loadProgress[int].connect(self.progress.setValue)
        self.browser.loadFinished.connect(self.progress.hide)
        self.browser.loadStarted.connect(self.progress.show)

        self.setLayout(vbox)

        # Set up profile with no storage and faked user agent
        profile = QWebEngineProfile("", self.browser)
        profile.setHttpUserAgent(USER_AGENT)
        webenginePage = QWebEnginePage(profile, self.browser)
        self.browser.setPage(webenginePage)
        self.browser.load(QUrl(page))

    def show_find(self):
        self.lbl_find.show()
        self.find.show()
        self.find.setFocus()

    def hide_find(self):
        self.lbl_find.hide()
        self.find.hide()
        self.browser.page().findText("")

    def handle_url_change(self, url):
        self.addr_bar.setText(url.toDisplayString())


styles = """
QTabWidget::pane {
    border: 0 solid white;
    margin: -4px -4px -4px -4px;
}
"""


class Browser(QTabWidget):
    def __init__(self):
        QTabWidget.__init__(self)
        self.setWindowTitle("browser")
        self.setStyleSheet(styles)
        self.resize(1024, 768)
        self.setTabsClosable(True)
        self.setMovable(True)
        self.setUsesScrollButtons(True)
        # self.setTabShape(self.Triangular)
        self.currentChanged.connect(self.tab_changed)
        self.tabCloseRequested.connect(self.close_tab)
        self.insertTab(-1, QWidget(), "+")

        new_tab = QShortcut(QKeySequence("Ctrl+T"), self)
        new_tab.activated.connect(self.add_tab)

    def close_tab(self, index):
        if index != self.count() - 1:
            if self.count() == 2:
                self.close()
            self.setCurrentIndex(self.count() - 3)
            self.removeTab(index)

    def add_tab(self):
        self.insertTab(self.count() - 1, BrowserTab(), "Tab")
        self.setCurrentIndex(self.count() - 2)

    def tab_changed(self, index):
        # Switched to any tab save for the last one
        if index != self.count() - 1:
            tab = self.widget(index)
            self.setTabText(index, tab.browser.url().host())

        # Switched to the last tab (the plus button)
        else:
            self.add_tab()


def main(args):
    app = QApplication(sys.argv)

    browser = Browser()
    browser.show()

    try:
        return_code = app.exec_()
    except:
        pass
    finally:
        # Makes sure that the QtWebEngineProcess process is killed
        del browser, app
    return return_code


if __name__ == "__main__":
    sys.exit(main(sys.argv))
