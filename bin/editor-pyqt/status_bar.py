# -*- coding: utf-8 -*-

from PyQt4.QtGui import (
    QStatusBar,
    QLabel
    )


class StatusBar(QStatusBar):

    def __init__(self):
        super(StatusBar, self).__init__()
        self.posicion_cursor = "Línea: %s, Columna: %s"
        self.linea_columna = QLabel(self.posicion_cursor % (0, 0))
        self.addWidget(self.linea_columna)

    def actualizar_label(self, linea, columna):
        self.linea_columna.setText(self.posicion_cursor % (linea, columna))