# -*- coding: utf-8 -*-

from PyQt4.QtGui import (
    QMainWindow,
    QAction,
    QToolBar,
    QIcon,
    QFileDialog,
    QMessageBox
    )

from PyQt4.QtCore import Qt

from editor import Editor
from status_bar import StatusBar


class MainWindow(QMainWindow):

    def __init__(self):
        super(MainWindow, self).__init__()
        self.setWindowTitle(self.tr("Editor - PyQt"))
        self.setMinimumSize(750, 500)
        # Menubar
        menu = self.menuBar()
        self.__crear_acciones()
        self.__crear_menu(menu)

        # Widget central
        self.editor = Editor()
        self.editor.modificationChanged[bool].connect(self._modificado)
        self.editor.cursorPositionChanged.connect(self._actualizar_status_bar)
        self.setCentralWidget(self.editor)

        # ToolBar
        self.toolbar = QToolBar()
        self.__crear_toolbar(self.toolbar)
        self.addToolBar(Qt.LeftToolBarArea, self.toolbar)

        # Status bar
        self.status = StatusBar()
        self.setStatusBar(self.status)

        # Conexiones
        self.nuevo.triggered.connect(self._nuevo_archivo)
        self.abrir.triggered.connect(self._abrir_archivo)
        self.guardar.triggered.connect(self._guardar_archivo)

    def __crear_acciones(self):
        self.nuevo = QAction("Nuevo", self)
        self.nuevo.setIcon(QIcon("imagenes/nuevo.svg"))
        self.nuevo.setShortcut("Ctrl+N")
        self.abrir = QAction("Abrir", self)
        self.abrir.setShortcut("Ctrl+O")
        self.abrir.setIcon(QIcon("imagenes/abrir.svg"))
        self.guardar = QAction("Guardar", self)
        self.guardar.setShortcut("Ctrl+S")
        self.guardar.setIcon(QIcon("imagenes/guardar.svg"))
        self.guardar_como = QAction("Guardar como", self)
        self.salir = QAction("Salir", self)
        self.deshacer = QAction("Deshacer", self)
        self.deshacer.setShortcut("Ctrl+Z")
        self.deshacer.setIcon(QIcon("imagenes/deshacer.svg"))
        self.rehacer = QAction("Rehacer", self)
        self.rehacer.setShortcut("Ctrl+Y")
        self.rehacer.setIcon(QIcon("imagenes/rehacer.svg"))
        self.cortar = QAction("Cortar", self)
        self.cortar.setShortcut("Ctrl+X")
        self.cortar.setIcon(QIcon("imagenes/cortar.svg"))
        self.copiar = QAction("Copiar", self)
        self.copiar.setShortcut("Ctrl+C")
        self.copiar.setIcon(QIcon("imagenes/copiar.svg"))
        self.pegar = QAction("Pegar", self)
        self.pegar.setShortcut("Ctrl+V")
        self.pegar.setIcon(QIcon("imagenes/pegar.svg"))
        self.acerca_de = QAction("Acerca de", self)

    def __crear_menu(self, menu_bar):
        menu_archivo = menu_bar.addMenu("&Archivo")
        menu_archivo.addAction(self.nuevo)
        menu_archivo.addAction(self.abrir)
        menu_archivo.addAction(self.guardar)
        menu_archivo.addAction(self.guardar_como)
        menu_archivo.addSeparator()
        menu_archivo.addAction(self.salir)
        menu_editar = menu_bar.addMenu("&Editar")
        menu_editar.addAction(self.deshacer)
        menu_editar.addAction(self.rehacer)
        menu_editar.addSeparator()
        menu_editar.addAction(self.cortar)
        menu_editar.addAction(self.copiar)
        menu_editar.addAction(self.pegar)
        menu_ayuda = menu_bar.addMenu("A&yuda")
        menu_ayuda.addAction(self.acerca_de)

    def __crear_toolbar(self, toolbar):
        toolbar.addAction(self.nuevo)
        toolbar.addAction(self.abrir)
        toolbar.addAction(self.guardar)
        toolbar.addSeparator()
        toolbar.addAction(self.deshacer)
        toolbar.addAction(self.rehacer)
        toolbar.addSeparator()
        toolbar.addAction(self.cortar)
        toolbar.addAction(self.copiar)
        toolbar.addAction(self.pegar)

    def _abrir_archivo(self):
        nombre = QFileDialog.getOpenFileName(self, self.tr("Abrir archivo"))
        if nombre:
            if not self.editor.modificado:
                self.__abrir_archivo(nombre)
            else:
                flags = QMessageBox.Yes
                flags |= QMessageBox.No
                flags |= QMessageBox.Cancel

                r = QMessageBox.information(self, self.tr("Modificado!"),
                                self.tr("No se ha guardado el archivo."
                                "Guardar?"),
                                flags)
                if r == QMessageBox.Yes:
                    self._guardar_archivo()
                    self.__abrir_archivo(nombre)
                elif r == QMessageBox.No:
                    self.__abrir_archivo(nombre)
                else:
                    return

    def __abrir_archivo(self, nombre):
        with open(nombre) as archivo:
            contenido = archivo.read()
            self.editor.setPlainText(contenido)
            self.editor.es_nuevo = False
            self.editor.nombre = nombre

    def _guardar_archivo(self):
        if self.editor.es_nuevo:
            self._guardar_como()
        else:
            contenido = self.editor.toPlainText()
            with open(self.editor.nombre, 'w') as archivo:
                archivo.write(contenido)

    def _guardar_como(self):
        nombre = QFileDialog.getSaveFileName(self, self.tr("Guardar archivo"))
        if nombre:
            contenido = self.editor.toPlainText()
            with open(nombre, 'w') as archivo:
                archivo.write(contenido)
            self.editor.es_nuevo = False
            self.editor.nombre = nombre

    def _nuevo_archivo(self):
        if self.editor.modificado:
            SI = QMessageBox.Yes
            NO = QMessageBox.No
            CANCELAR = QMessageBox.Cancel
            respuesta = QMessageBox.question(self, self.tr("Modicado!"),
                                        self.tr("El archivo %s fue modificado\n"
                                        "¿Guardar?") % self.editor.nombre,
                                        SI | NO | CANCELAR)
            if respuesta == CANCELAR:
                return
            elif respuesta == SI:
                self._guardar_archivo()
            else:
                self.editor.setPlainText("")
                self.editor.modificado = False
        else:
            self.editor.setPlainText("")
            self.editor.modificado = False

    def _modificado(self, valor):
        if valor:
            self.editor.modificado = True
        else:
            self.editor.modificado = False

    def _actualizar_status_bar(self):
        linea = self.editor.textCursor().blockNumber() + 1
        columna = self.editor.textCursor().columnNumber()
        self.status.actualizar_label(linea, columna)

    def closeEvent(self, evento):
        if self.editor.modificado:
            flags = QMessageBox.Yes
            flags |= QMessageBox.No
            flags |= QMessageBox.Cancel

            r = QMessageBox.information(self, self.tr("Modificado!"),
                                self.tr("Cerrar la aplicación sin guardar?"),
                                flags)
            if r == QMessageBox.Yes:
                self._guardar_archivo()
            elif r == QMessageBox.No:
                evento.accept()
            else:
                evento.ignore()