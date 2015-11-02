#!/usr/bin/python
# -*- coding: utf-8 -*-

import os
import sys
from ftplib import FTP # on importe la librairie et on la renomme juste pour le script en "ftp"

## You must give your host here
HOST = "..."
USER = "..."
PASSWORD = "..."

## Tres bon tuto sur le site du zero
## http://www.siteduzero.com/tuto-3-24428-1-utiliser-la-librairie-ftp-de-python.html

def addFileToFtp(myfile, host = HOST, user = USER, password = PASSWORD, host_dir=None):
#    print "-"*78 + "\n"
#    print "Adding %s to directory %s"%(myfile, host_dir)
#    print "-"*78 + "\n"

    #host = HOST # adresse du serveur FTP
    #user = USER # votre identifiant
    #password = PASSWORD # votre mot de passe
    connect = FTP(host,user,password) # on se connecte

    # etat de la connexion
    state = connect.getwelcome() # Recupere le message de bienvenue
    print "Server state :\n",state # on l'affiche

    # on se deplace dans le repertoire voulu
    #connect.sendcmd('CWD %s'%host_dir)
    if host_dir:
        connect.sendcmd('CWD %s'%host_dir)
        #connect.cwd(host_dir)

    # envoi du fichier
    fichier = myfile
    file = open(fichier, 'rb') # ici j'ouvre le fichier ftp.py
    (head, tail) = os.path.split(myfile)
    connect.storbinary('STOR '+ tail, file) # ici j'indique le fichier à envoyer
    file.close() #on ferme le fichier

    connect.quit() # où "connect" est le nom de la variable dans laquelle vous avez déclaré la connexion !
    print "%s has been transfered successfully in directory %s\n...Bye!"%(tail, host_dir)

if __name__ == "__main__":
    # myfile, host, user, password, host_dir
    addFileToFtp(sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4],sys.argv[5])
