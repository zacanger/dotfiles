#!/usr/bin/python

import tkinter as tk
import os

class Application(tk.Frame):
    def __init__(self, master=None):
        tk.Frame.__init__(self, master)
        self.pack()
        self.checkFiles()
        self.findSettings()
        self.createSettings()
        self.createFunctions()

    # Menu System

    def createSettings(self):
        self.sTitle = tk.Label(self)
        self.sTitle["text"] = "Settings"
        self.sTitle.grid(column = 0, row = 0, ipadx = 30, padx = 5, pady = 1, sticky = 'EW')

        self.loc = tk.Button(self)
        self.loc["text"] =  "Refresh Settings"
        self.loc["command"] = self.findSettings
        self.loc.grid(column = 0, row = 1, padx = 5, pady = 1, sticky = 'EW')

        self.dir = tk.Button(self)
        self.dir["text"] = "Directory..."
        self.dir["command"] = self.setDir
        self.dir.grid(column = 0, row = 2,padx = 5, pady = 1, sticky = 'EW')

        self.reset = tk.Button(self)
        self.reset["text"] = "Defaults"
        self.reset["command"] = self.default
        self.reset.grid(column = 0, row = 3,padx = 5, pady = 1, sticky = 'EW')

    def createFunctions(self):
        self.wTitle = tk.Label(self)
        self.wTitle["text"] = "Functions"
        self.wTitle.grid(column = 1, row = 0, ipadx = 29, padx = 5, pady = 1, sticky = 'EW')

        self.css = tk.Button(self)
        self.css["text"] = "Add Site"
        self.css["command"] = self.addSite
        self.css.grid(column = 1, row = 1, padx = 5, pady = 1, sticky = 'EW')

        self.edit = tk.Button(self)
        self.edit["text"] = "Edit Site"
        self.edit["command"] = self.editSite
        self.edit.grid(column = 1, row = 2, padx = 5, pady = 1, sticky = 'EW')

        self.rem = tk.Button(self)
        self.rem["text"] = "Remove Site"
        self.rem["command"] = self.remSite
        self.rem.grid(column = 1, row = 3, padx = 5, pady = 1, sticky = 'EW')

        self.uc = tk.Button(self)
        self.uc["text"] = "Generate"
        self.uc["command"] = self.generate
        self.uc.grid(column = 1, row = 4, padx = 5, pady = 1, sticky = 'EW')

    # Functions

    def checkFiles(self):
        if "Settings.txt" not in os.listdir():
            file = open("Settings.txt", "x")
            file.write("directory:.")
            file.close()
        if "raw.txt" not in os.listdir():
            file = open("raw.txt", "x")
            file.close()
        self.findSettings()

    def findSettings(self):
        file = open("Settings.txt", 'r')
        global types
        types = {}
        for l in file.readlines():
            section = l[:l.find(':')]
            types[section] = l[l.find(':') + 1:]
        file.close()

    def default(self):
        if tk.messagebox.askyesno("Warning", "This will reset everything. Continue?") == True:
            file = open("Settings.txt", 'w')
            file.write("directory:.")
            file.close()
            self.findSettings()

    def setDir(self):
        question = types["directory"]
        if question == ".":
            question = "root"
        answer = tk.simpledialog.askstring("Directory", question)
        if answer != None:
            if answer == "root":
                answer = "."
            types["directory"] = answer
            file = open("Settings.txt", 'w')
            file.write("directory:%s" % answer)
            file.close()

    def listSites(self):
        file = open("raw.txt", "r")
        data = file.readline()
        file.close()

        data = data.split("`")
        for i in range(len(data)):
            data[i] = data[i][:data[i].find('~')]
        data.pop()
        return(", ".join(data))

    def addSite(self):
        site = tk.simpledialog.askstring("Domain", "Existing: %s" % self.listSites())
        if site != None:
            tk.messagebox.showinfo("Alert", "This grabs the CSS from clipboard. Copy before continuing.")
            css = tk.Text.clipboard_get(self)
            css = css.replace("\n","~newline~")
            css = "%s~%s`" % (site, css)

            file = open("raw.txt", "r")
            tempStorage = file.readline()
            file.close()

            if site not in tempStorage:
                file = open("raw.txt", "w")
                file.write(tempStorage + css)
                file.close()
            else:
                tk.messagebox.showerror("Error", "Site exists!")

    def editSite(self):
        site = tk.simpledialog.askstring("Domain", "Existing: %s" % self.listSites())
        if site != None:
            tk.messagebox.showinfo("Alert", "This grabs the CSS from clipboard. Copy before continuing.")
            file = open("raw.txt", "r")
            data = file.readline()
            file.close()

            data = data.split("`")
            for i in range(len(data)):
                if site in data[i]:
                    css = tk.Text.clipboard_get(self)
                    css = css.replace("\n","~newline~")
                    data.pop(i)
                    data.pop(len(data)-1)
                    data.append("%s~%s`" % (site, css))
                    break

            file = open("raw.txt", "w")
            data = "`".join(data)
            file.write(data)
            file.close()

    def remSite(self):
        site = tk.simpledialog.askstring("Domain", "Existing: %s" % self.listSites())
        if site != None:
            file = open("raw.txt", "r")
            data = file.readline()
            file.close()

            file = open("raw.txt", "w")
            data = data.split("`")
            for i in range(len(data) - 1):
                if site in data[i]:
                    data.pop(i)
            file.write("`".join(data))
            file.close()

    def generate(self):
        file = open("raw.txt", "r")
        data = file.readline()
        file.close()
        if data != "":
            if "chrome" not in os.listdir(types["directory"]):
                os.mkdir(types["directory"] + "\\chrome")
                file = open(types["directory"] + "\\chrome\\userContent.css", "x")
            else:
                file = open(types["directory"] + "\\chrome\\userContent.css", "w")

            data = data.split("`")
            converted = []
            for i in range(len(data) - 1):
                site = data[i][:data[i].find("~")]
                css = data[i][data[i].find("~") + 1:]
                css = css.replace("~newline~","\n")
                css = css.replace(";", " !important;")
                converted.append("@-moz-document domain(%s) {\n%s\n}\n" % (site, css))
            file.write("".join(converted))
            file.close()

root = tk.Tk("",""," User Stylesheet")
app = Application(master=root)
app.mainloop()