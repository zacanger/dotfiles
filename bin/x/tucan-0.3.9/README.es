===================
 Descripción
=========

 - Tucan es una aplicación libre y de código abierto diseñada para la
   gestión automática de descargas y subidas en sitios de hosting como:

   - http://rapidshare.com/
   - http://megaupload.com/
   - http://gigasize.com/
   - http://mediafire.com/
   - http://4shared.com/
   - http://sendspace.com/
   - http://zshare.net/
   - http://filefactory.com/
   - http://easy-share.com/
   - http://badongo.com/
   - http://depositfiles.com/
   - http://hotfile.com/
   - (...)


===================
 Características
=========

 - Escrito enteramente en python.
 - Interfaz gráfica de usuario escrita en PyGTK (GTK+ toolkit).
 - Multiplataforma (GNU/Linux, FreeBSD, Microsoft Windows ...).
 - Fácil de ampliar con plugins.
 - Ligero y rápido.
 - Gestión de esperas entre descargas (accesos anónimos).
 - Reconocimiento de captchas donde se necesite (como los accesos anónimos de
   megaupload o gigasize).
 - Gestión de links intercambiables.
 - Soporte para proxys.


===================
 Plugins
=========

 +===================+========================+=============================+
 |   Hosting site    |        Downloads       |           Uploads           |
 +===================+========================+=============================+
 | rapidshare.com    | anonymous and premium  |                             |
 +-------------------+------------------------+-----------------------------+
 | megaupload.com    | anonymous and premium  |                             |
 +-------------------+------------------------+-----------------------------+
 | gigasize.com      | anonymous              |                             |
 +-------------------+------------------------+-----------------------------+
 | mediafire.com     | anonymous              |                             |
 +-------------------+------------------------+-----------------------------+
 | 4shared.com       | anonymous              |                             |
 +-------------------+------------------------+-----------------------------+
 | sendspace.com     | anonymous              |                             |
 +-------------------+------------------------+-----------------------------+
 | zshare.net        | anonymous              |                             |
 +-------------------+------------------------+-----------------------------+
 | filefactory.com   | anonymous              |                             |
 +-------------------+------------------------+-----------------------------+
 | easy-share.com    | anonymous              |                             |
 +-------------------+------------------------+-----------------------------+
 | badongo.com       | anonymous              |                             |
 +-------------------+------------------------+-----------------------------+
 | depositfiles.com  | anonymous              |                             |
 +-------------------+------------------------+-----------------------------+
 | hotfile.com       | anonymous              |                             |
 +-------------------+------------------------+-----------------------------+


===================
 Dependencias
=========

 - Python >= 2.5
 - PyGTK
 - Python Imaging Library
 - Tesseract OCR (con el paquete del idioma inglés)
 - SVG Rendering Library

 +=========================+===================+====================+
 | Paquete \ Distribución  |  Debian / Ubuntu  |       Gentoo       |
 +=========================+===================+====================+
 | Python >= 2.5           | python            | dev-lang/python    |
 +-------------------------+-------------------+--------------------+
 | PyGTK                   | python-gtk2       | dev-python/pygtk   |
 +-------------------------+-------------------+--------------------+
 | Python Imaging Library  | python-imaging    | dev-python/imaging |
 +-------------------------+-------------------+--------------------+
 | Tesseract OCR           | tesseract-ocr     | app-text/tesseract |
 | (english language pack) | tesseract-ocr-eng |    (linguas_en)    |
 +-------------------------+-------------------+--------------------+
 | SVG Rendering Library   | librsvg2-common   | gnome-base/librsvg |
 +-------------------------+-------------------+--------------------+

 +===========+====================+================+================+
 |   Arch    |       Fedora       |    OpenSuSE    |    Mandriva    |
 +===========+====================+================+================+
 | python    | python             | python         | python         |
 +-----------+--------------------+----------------+----------------+
 | pygtk     | pygtk2             | python-gtk     | pygtk2.0       |
 +-----------+--------------------+----------------+----------------+
 | pil       | python-imaging     | python-imaging | python-imaging |
 +-----------+--------------------+----------------+----------------+
 | tesseract | tesseract          | tesseract      | tesseract      |
 |           | tesseract-langpack |                |                |
 +-----------+--------------------+----------------+----------------+
 | librsvg   | librsvg2           | librsvg        | librsvg        |
 +-----------+--------------------+----------------+----------------+


===================
 Descargas
=========

 - Versión estable:

   https://forja.rediris.es/projects/cusl3-tucan/ -> Ficheros


 - Versión de desarrollo (se necesita subversion):

   $ svn co https://forja.rediris.es/svn/cusl3-tucan/trunk tucan


===================
 Instalación y Uso
=========

 - Desempaquetar el tarball:

   $ tar zxvf tucan-<version>.tar.gz
   $ cd tucan-<version>/

 - Instalar Tucan escribiendo (se necesitan privilegios de root):

   # make install

 - Ejecutar Tucan escribiendo en un terminal:

   $ tucan

   ----------

 - Desinstalar Tucan escribiendo (se necesitan privilegios de root):

   # make uninstall


===================
 Update Manager
=========

 - Tucan trae algunos servicios que de vez en cuando necesitan ser actualizados
   y otras veces hay nuevos servicios disponibles.
 - Con el fin de actualizar (o instalar nuevos) servicios Tucan tiene un sistema
   de actualizaciones:

   - Uso Automático:
     - Para activarlo/desactivarlo, el usuario debe ir a la ventana Preferencias >
       Avanzada > "Comprobación automática de actualizaciones." (activado por
       defecto).

   - Uso Manual:
     - Para activarlo el usuario debe ir a la ventana Preferencias > Servicios >
       Buscar.

 - Después de una actualización de servicios Tucan necesita ser reiniciado.


===================
 Tips & Tricks
=========

 - Antes de ejecutar una nueva versión, se recomienda eliminar el directorio
   /home/<user>/.tucan/ ó C:\Documents and Settings\<user>\.tucan\ si existe.
 - La primera vez que se ejecuta Tucan (si no existe el directorio ~/.tucan/)
   aparece la ventana de Preferencias.
 - Antes de usar un servicio, éste debe estar activado en la pestaña
   "Configuración de Servicio" de la ventana Preferencias.

 - Acceso anónimo de http://gigasize.com/:
   - gigasize.com no permite comprobar links si ya hay un link descargándose de
     este servicio.


===================
 Links
=========

 - http://tucaneando.com/
 - http://doc.tucaneando.com/
 - http://blog.tucaneando.com/
 - http://forums.tucaneando.com/
 - https://forja.rediris.es/projects/cusl3-tucan/
