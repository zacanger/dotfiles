TUCAN SERVICE HOWTO
-------------------

Indice:
 1 - Introducción
 2 - Breve resumen
 3 - Secciones
 3.1 - Directorio de servicio (obligatorio)
 3.2 - Archivo __init__.py (obligatorio)
 3.3 - Archivo service.conf (obligatorio)
 3.4 - Archivo imagen o icono (opcional)
 3.5 - Archivo check_links.py (opcional)
 3.6 - Archivo anonymous_download.py (opcional)
 3.7 - Archivo premium.accounts (opcional)
 3.8 - Archivo premium_downloads.py (opcional)
 3.9 - Archivo premium_cookie.py (opcional)


1 - Introducción
----------------
En este documento se van a explicar las lineas generales para implementar un
nuevo servicio para Tucan (archivos mínimos, ubicación de esos archivos,
formato, parómetros de entrada/salida... etc).


2 - Breve resumen
-----------------
servicio/             : obligatorio: Directorio que contiene todos los
                                     archivos del servicio, no puede contener
                                     ningún punto "." en el nombre.

__init__.py           : obligatorio: Necesario para que python reconozca el
                                     directorio como módulo.

service.conf          : obligatorio: Descripción e información del servicio
                                     para que el sistema de plugins sepa que
                                     soporta este servicio.

<imagen o icono>      : opcional: Imagen o icono de tamaño 48x48 pixels
                                  representativo del servicio.

check_links.py        : opcional: Sólo necesario si el servicio tiene soporte
                                  para descargas. Puede ser un archivo o puede
                                  ser un metodo de un plugin de descarga.

anonymous_download.py : opcional: Sólo necesario si el servicio tiene soporte
                                  para descargas anónimas.

premium.accounts      : opcional: Sólo necesario si el servicio tiene soporte
                                  para cuentas premium (se genera desde el GUI).

premium_download.py   : opcional: Sólo necesario si el servicio tiene soporte
                                  para descargas premium.

premium_cookie.py     : opcional: Sólo necesario si el servicio tiene soporte
                                  para descargas premium.


3 - Secciones
-------------

3.1 - Directorio de Servicio (obligatorio)
------------------------------------------
El directorio contendrá todos los archivos de los diferentes plugins del
servicio, no debe contener ningún punto "." en el nombre. Ejemplos:

   http://rapidshare.com  ->  rapidshare/
   http://megaupload.com  ->  megaupload/
   http://gigasize.com    ->  gigasize/
   http://foobar.com      ->  foobar/


3.2 - Archivo __init__.py (obligatorio)
---------------------------------------
Este archivo es necesario para que python reconozca el directorio como módulo.
Es un archivo vacio.


3.3 - Archivo service.conf (obligatorio)
----------------------------------------
Este archivo describe y da información de los distintos plugins al sistema de
plugins de Tucan para que conozca las funcionalidades del servicio.

Consta de varias secciones:

   [main]
   enabled = False
   name = rapidshare.com
   icon = rapidshare.png
   premium_cookie = PremiumCookie
   downloads = True
   uploads = False
   update = 200904180200

   [anonymous_download]
   name = AnonymousDownload
   author = Crak
   captcha = True
   version = 0.3
   slots = 1

   [premium_download]
   name = PremiumDownload
   author = Crak
   version = 0.2
   accounts = premium.accounts


Sección [main]:
"enabled"        : Opción para notificar que el servicio esta activado o
                   desactivado. Valores: True, False. Por defecto estará
                   desactivado (el usuario debe activar el servicio en la
                   ventana preferencias antes de poder usarlo).
"name"           : Opción para notificar el nombre del servicio.
                   Ejemplos: rapidshare.com, megaupload.com, gigasize.com
"icon"           : Opción para notificar el nombre del icono o imagen
                   representativa del servicio que se va a usar en el GUI.
                   Opcional: si no se va a usar se debe poner None.
"downloads"      : Opción para notificar que el servicio puede realizar
                   descargas. Valores: True, False.
"premium_cookie" : Opción para notificar el nombre de la clase que se va a
                   usar para gestionar la cookie necesaria en las cuentas
                   premium.
"uploads"        : Opción para notificar que el servicio puede realizar
                   subidas. Valores: True, False.
"update"         : Opcion para la actualización automática del servicio, será un
                   número a incrementar cuando se quiera actualizar el servicio.
                   Valores: int (preferiblemente en formato YYYYMMDDHHMM).


Sección [anonymous_download]:
"name"    : Opción para notificar el nombre de la clase que se va a usar para
            realizar este tipo de acceso.
            Valor por defecto: AnonymousDownload.
"author"  : Opción para notificar el nombre (o nick o email) del creador.
"captcha" : Opción para notificar si el servicio tiene captcha en las
            descargas anónimas. Valores: True, False.
"version" : Versión del plugin.
"slots"   : Número máximo de descargas simultaneas permitidas por este servicio.
            Valores: int (ó "Unlimited" para los servicios que no implementan
                          la clase slots).


Sección [premium_download]:
"name"     : Opción para notificar el nombre de la clase que se va a usar para
             realizar este tipo de acceso.
             Valor por defecto: PremiumDownload.
"author"   : Opción para notificar el nombre (o nick o email) del creador.
"version"  : Versión del plugin.
"accounts" : Nombre del archivo donde se van a almacenar los datos de las
             cuentas premium de este servicio.


3.4 - Archivo imagen o icono (opcional)
---------------------------------------
Imagen o icono de tamaño 48x48 pixels representativo del servicio que se va a
usar en el GUI.
Si no se va a usar se debe notificar en el archivo service.conf, sección [main]
opción "icon = None".


3.5 - Archivo check_links.py (opcional)
---------------------------------------
Este archivo sólo es necesario si el servicio tiene soporte para descargas.
Puede ser un archivo si lo usan varios plugins (descargas anónimas, descargas
premium) o puede ser un metodo de los distintos plugins de descarga.

parámetros de entrada: url.
parámetros de salida: nombre del archivo a descargar, tamaño y unidades.

    comprobaciones/tareas mínimas:
        url activa
        determinar nombre del archivo y tamaño total.


3.6 - Archivo anonymous_download.py (opcional)
----------------------------------------------
Este archivo sólo es necesario si el servicio tiene soporte para descargas
anónimas. Plugin típico.

clases: AnonymousDownload (declarada en el archivo service.conf, sección
                          [anonymous_download])
métodos:
  __init__: inicialización de slots.py y download_plugin.py
  add: parámetros de entrada: ruta, link y nombre del archivo
  delete: parámetros de entrada: nombre del archivo.
  check_links: parámetros de entrada: url. parámetros de salida: nombre del
  archivo a descargar, tamaño y unidades.


3.7 - Archivo premium.accounts (opcional)
-----------------------------------------
Este archivo sólo es necesario si el servicio tiene soporte para cuentas
premium.
Se genera desde el GUI (preferencias) y esta cifrado.


3.8 - Archivo premium_downloads.py (opcional)
---------------------------------------------
Este archivo sólo es necesario si el servicio tiene soporte para descargas
Premium. Plugin típico.

clases: PremiumDownload (declarada en el archivo service.conf, sección
                          [premium_download])
métodos:
  __init__: inicialización de accounts.py
  add: parámetros de entrada: ruta, link y nombre del archivo
  delete: parámetros de entrada: nombre del archivo
  check_links: parámetros de entrada: url. parámetros de salida: nombre del
  archivo a descargar, tamaño y unidades.


3.9 - Archivo premium_cookie.py (opcional)
------------------------------------------
Este archivo sólo es necesario si el servicio tiene soporte para cuentas
Premium.

clases: PremiumCookie (declarada en el archivo service.conf, sección
                        [main])
métodos:
  get_cookie: parámetros de entrada: user, password url.
  parámetros de salida: cookie (cookielib.CookieJar).
