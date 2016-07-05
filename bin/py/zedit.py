#!/usr/bin/env python

from Tkinter import *
import tkFileDialog
import os, sys# inspect,


class Window():
    def __init__(self):
           filewin = Toplevel(root) #, takefocus=True
           button = Button(filewin, text="Do nothing button")
           button.pack()

class Editor:
    file_name = ""
    def __init__(self, master):
        self.file_opt = options = {}

        # options for opening files
        options['defaultextension'] = '.md'
        options['filetypes'] = [('all files', '.*'), ('markdown', '.md'), ('text files', '.txt')]
        options['initialdir'] = os.path
        options['initialfile'] = 'notes.md'
        options['parent'] = root
        options['title'] = 'Title'


        # defining options for opening a directory
        self.dir_opt = options = {}
        options['initialdir'] = os.path
        options['mustexist'] = False
        options['parent'] = root
        options['title'] = 'Title'

        global text_box
        text_box = Text(root)
        text_box.pack(expand = 1, fill= BOTH)
        text_box.focus_set()


        def donothing():
           window = Window()
           print root.focusmodel()#root.focus_get()
        def find_focus():
           print root.focusmodel()#root.focus_get()

        menubar = Menu(root)
        filemenu = Menu(menubar, tearoff=0)
        filemenu.add_command(label="New", command=donothing)
        filemenu.add_command(label="Open", command=self.open_file, accelerator="Command+N")
        filemenu.add_command(label="Save", command=self.save_file, accelerator="Command+S")
        filemenu.add_command(label="Save as...", command=self.save_as_file)
        filemenu.add_command(label="Close", command=donothing)
        filemenu.add_separator()
        filemenu.add_command(label="Exit", command=self.quit_project, accelerator="Command+Q")
        menubar.add_cascade(label="File", menu=filemenu)


        editmenu = Menu(menubar, tearoff=0)
        editmenu.add_command(label="Undo", command=donothing)
        editmenu.add_separator()
        editmenu.add_command(label="Cut", command=donothing)
        editmenu.add_command(label="Copy", command=self.copy)
        editmenu.add_command(label="Paste", command=self.paste)
        editmenu.add_command(label="Delete", command=donothing)
        editmenu.add_command(label="Select All", command=donothing)
        menubar.add_cascade(label="Edit", menu=editmenu)


        helpmenu = Menu(menubar, tearoff=0)
        helpmenu.add_command(label="Help Index", command=find_focus)
        helpmenu.add_command(label="About...", command=donothing)
        menubar.add_cascade(label="Help", menu=helpmenu)

        root.config(menu=menubar)

        root.bind_all("<Command-o>", self.open_file)
        root.bind_all("<Command-s>", self.save_file)
        root.bind_all("<Command-Shift-s>", self.save_as_file)
        root.bind_all("<Command-q>", self.quit_project)

    def open_file(self, event=''):
        open_file = tkFileDialog.askopenfile(mode='r', **self.file_opt)
        text_box.delete(1.0, END)
        text_box.insert(END, open_file.read())
        self.file_name = open_file.name
        print self.file_name

    def save_file(self, event=''):
        if (self.file_name == ''):
            self.save_as_file()
        else:
            save_file = open(self.file_name, 'w')
            save_file.write(text_box.get(1.0, END))
            self.file_name = save_file.name

    def save_as_file(self, event=''):
        save_file = tkFileDialog.asksaveasfile(mode='w', **self.file_opt)
        save_file.write(text_box.get(1.0, END))
        self.file_name = save_file.name
        print self.file_name



    def copy(self):
        root.clipboard_clear() #is this needed?
        root.clipboard_append(text_box.selection_get())
    def paste(self):
        result = root.selection_get(selection = "CLIPBOARD")
        text_box.insert(INSERT, result)


    def new_window(self):
        root.another_window = Window()

    def quit_project(self):
        sys.exit()
if __name__=='__main__':
    root = Tk()
    root.wm_title("zeditor")
    app = Editor(root)
    root.mainloop()

# root = Tkinter.Tk()
# TkFileDialogExample(root).pack()
# root.mainloop()


