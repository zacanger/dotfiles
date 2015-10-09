#!/usr/bin/env python

# apt-wishlist - Express your software suggestions to your sysadmin
#
# Copyright (C) 2013 Eugenio M. Vigo
#
# This file is part of apt-wishlist.
#
# apt-wishlist is free software: you can redistribute it and/or modify it under 
# the terms of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later
# version.
#
# apt-wishlist is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# apt-wishlist. If not, see <http://www.gnu.org/licenses/>.

import sys
import os
import apt
from email.mime.text import MIMEText
import smtplib

class Error(object):
    """Data structure that holds information about some error."""

    def __init__(self, string = "", code = 0):
        self.string = string
        self.code = 0

    def no_error(self):
        if self.string and self.code:
            return False
        else:
            return True
            
def check_pkgs_apt(pkgs):
    apt_cache = apt.cache.Cache()

    pruned_pkgs = []
    for pkg in pkgs:
        if apt_cache.has_key(pkg):
            pruned_pkgs.append(pkg)
        
    return pruned_pkgs

def print_not_found(all_pkgs, found):
    not_found = [item for item in all_pkgs if item not in found]
    for pkg in not_found:
        print "Package {0} doesn't exist. Skipping.".format(pkg)

def format_pkgs(pkgs):
    return " ".join(pkgs)

def send_mail_to_root(pkgs, user):    
    user_to = "root@localhost" # This will actually send the mail to whomever root is aliased to.
    user_from = "{0}@localhost".format(user)
    
    msg = MIMEText(format_pkgs(pkgs))
    msg["Subject"] = "apt-wishlist: Packages suggested for install by {0}".format(user)
    msg["From"] = user_from
    msg["To"] = user_to

    error = Error()
    serv = smtplib.SMTP("localhost")
    try:
        serv.sendmail(user_from, [user_to], msg.as_string())
    except smtplib.SMTPRecipientsRefused:
        error.string = "SMTP Error: Recipients refused"
        error.code = 10
    except smtplib.SMTPHeloError:
        error.string = "SMTP Error: HELO greeting not properly replied by server"
        error.code = 20
    except smtplib.SMTPSenderRefused:
        error.string = "SMTP Error: Sender refused by server"
        error.value = 30
    except smtplib.SMTPDataError:
        error.string = "SMTP Error: Unknown error, possibly related to data"
        error.code = 40
        
    serv.quit()
    return error

def write_wishlist_file(dir, pkgs):
    wishes = open(os.path.join(dir, "wishes"), "w")
    wishes.write(" ".join(pkgs))
    wishes.close()

    return Error()

def read_wishlist_file(dir):
    wishes = open(os.path.join(dir, "wishes"), "r")
    pkgs = wishes.read().split()
    wishes.close()
    
    return pkgs

def delete_wishlist_file(dir):
    os.remove(os.path.join(dir, "wishes"))

def create_config_dir():
    path = os.path.join(os.getenv("HOME"), ".config", "apt-wishlist") 
    if not os.path.exists(path):
        os.mkdir(path)

    return path

def main(args):
    # All I/O should be handled here for now. This is to ensure scalability in
    # the future... even though it sorta complicates things right now (e.g. the
    # Error class to communicate whenever something happens, instead of just
    # printing the error directly in send_mail_to_root.

    exit = Error()
    
    config_dir = create_config_dir()
    
    if len(args) < 1:
        print """USAGE:
        apt-wishlist [save]  PACKAGES
        apt-wishlist [export]""" # Implement: send-saved | delete-saved
        return Error("", -1)

    if sys.argv[1] == "save":
        pkgs = args[1:]
        pruned_pkgs = check_pkgs_apt(pkgs)
        print_not_found(pkgs, pruned_pkgs)
        exit = write_wishlist_file(config_dir, pruned_pkgs)
    elif sys.argv[1] == "export":
        pkgs = read_wishlist_file(config_dir) # returns list, not string
        print " ".join(pkgs)
    elif sys.argv[1] == "delete-saved":
        try:
            delete_wishlist_file(config_dir)
        except OSError:
            pass
    elif sys.argv[1] == "edit-saved":
        edit = os.system("nano {0}".format(os.path.join(config_dir, "wishes")))
    else:
        if sys.argv[1] == "send-saved":
            pkgs = read_wishlist_file(config_dir)
        else:
            pkgs = args # If no command, everything past argv[0] are packages (but args is argv[1:]!)
        pruned_pkgs = check_pkgs_apt(pkgs)
        print_not_found(pkgs, pruned_pkgs)
        print "Sending mail to root@localhost..."
        exit = send_mail_to_root(pruned_pkgs, os.getenv("USER"))
        if exit.no_error():
            print "Message delivered!"
        else:
            print error.string + "(Error {0})".format(error.code)

    return exit
if __name__ == "__main__":
    error_obj = main(sys.argv[1:])

    sys.exit(error_obj.code)
