#!/usr/bin/env python3
# vim: ft=python fileencoding=utf-8 sts=4 sw=4 et:

"""super simple browser. call it with a url."""

import sys
import argparse

from PyQt5.QtCore import QUrl
from PyQt5.QtWidgets import QApplication
from PyQt5.QtWebKit import QWebSettings
from PyQt5.QtWebKitWidgets import QWebView

try:
    from PyQt5.QtWebEngineWidgets import QWebEngineView
    WEBENGINE = True
except ImportError:
    WEBENGINE = False


def parse_args():
    """Parse commandline arguments."""
    parser = argparse.ArgumentParser()
    parser.add_argument('url', help='The URL to open')
    parser.add_argument('--plugins', '-p', help='Enable plugins',
                        default=False, action='store_true')
    if WEBENGINE:
        parser.add_argument('--webengine', help='Use QtWebEngine',
                            default=False, action='store_true')
    return parser.parse_args()


if __name__ == '__main__':
    args = parse_args()
    app = QApplication(sys.argv)

    if WEBENGINE and args.webengine:
        wv = QWebEngineView()
    else:
        wv = QWebView()

    wv.loadStarted.connect(lambda: print("Loading started"))
    wv.loadProgress.connect(lambda p: print("Loading progress: {}%".format(p)))
    wv.loadFinished.connect(lambda: print("Loading finished"))

    if args.plugins and not WEBENGINE:
        wv.settings().setAttribute(QWebSettings.PluginsEnabled, True)

    wv.load(QUrl.fromUserInput(args.url))
    wv.show()

    app.exec_()
