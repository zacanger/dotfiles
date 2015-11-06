#!/bin/bash

busybox httpd -p 8080 -v -f

#this will run as what ever user you start it as unless you tell it otherwise with '-u'
#this means that if you start it with 'sudo' it will have sudo permissions.
#default / is the current dir unless you use '-h'
#cgi files should be in 'cgi-bin' of servers /
#don't forget to chmod +x cgi files
#'-f' Do not daemonize
#more info at http://wiki.openwrt.org/doc/howto/http.httpd

#example config:
#busybox httpd -p 8080 -v -f -c http.conf
#H:/tmp/web
#A:127.0.0.1
#D:*
#*.cgi:/bin/sh
#example user is bob and password is linux2
#/:bob/linux2
#password as hash httpd -m "linux2"
#/:bob:$1$1mWbCBYu$3Yp2f6Kao5SiEdW.f/WEv0
