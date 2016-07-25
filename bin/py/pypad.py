#!/usr/bin/env python

import pickle, sys

def help():
    print("commands:")
    print("    write")
    print("    view")
    print("    help")
    print("    exit")
def write():
    filename = raw_input("name = ")
    print("editing " + filename)
    additions = raw_input("")
    print("saving " + filename)
    pickle.dump(additions, open(filename, "wb"))
    print(filename + " saved")
def view():
    filename = raw_input("name = ")
    view = pickle.load(open(filename, "rb"))
    print(view)

def go():
    print("pypad")
    while True:
        command = raw_input("> ")
        cmd = command.lower()
        if cmd == "view":
            view()
        if cmd == "write":
            write()
        if cmd == "help":
            help()
        if cmd == "exit":
            sys.exit()
go()
