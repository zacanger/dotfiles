from Tkinter import *
import tkFileDialog
import os, sys# inspect,


class Window():
    file_name=''
    text_box = ''
    def __init__(self, parent):
        window = Toplevel(parent)
        self.text_box = Text(window)
        self.text_box.pack(expand = 1, fill= BOTH)
        self.text_box.focus_set()
 #          button = Button(window, text="Do nothing button")
#           button.pack()

        
class Editor:
    file_name = "" # etc Users/Luke/programming/info.txt
    
    def __init__(self, master):
        initial_text_box = Text(root)
        initial_text_box.pack(expand = 1, fill= BOTH)
        initial_text_box.focus_set()
        initial_text_box.insert(END, """This is a simple text editor. Type the path of the file you want to load/save in
the small input box on the lower left of this window.""")

        #window = Window()
        self.file_opt = options = {}

        # options for opening files
        options['defaultextension'] = '.txt'
        options['filetypes'] = [('all files', '.*'), ('text files', '.txt')]
        options['initialdir'] = os.path
        options['initialfile'] = 'myfile.txt'
        options['parent'] = root
        options['title'] = 'This is a title'


        # defining options for opening a directory
        self.dir_opt = options = {}
        options['initialdir'] = os.path
        options['mustexist'] = False
        options['parent'] = root
        options['title'] = 'This is a title'
        
        


        def donothing():
           print root.focus_get()
        def find_focus():
           focus= root.focus_get()
           print focus
           print focus.get(1.0, END)
           

        menubar = Menu(root)
        filemenu = Menu(menubar, tearoff=0)
        filemenu.add_command(label="New", command=self.new_window, accelerator="Command+N")
        filemenu.add_command(label="Open", command=self.open_file, accelerator="Command+O")
        filemenu.add_command(label="Save", command=self.save_file, accelerator="Command+S")
        filemenu.add_command(label="Save as...", command=self.save_as_file)
        filemenu.add_separator()
        filemenu.add_command(label="Exit", command=self.quit_project, accelerator="Command+Q")
        menubar.add_cascade(label="File", menu=filemenu)

                             
        editmenu = Menu(menubar, tearoff=0)
        editmenu.add_command(label="Undo", command=donothing)
        editmenu.add_separator()
        editmenu.add_command(label="Cut", command=self.cut, accelerator="Command+X")
        editmenu.add_command(label="Copy", command=self.copy, accelerator="Command+C")
        editmenu.add_command(label="Paste", command=self.paste, accelerator="Command+V")
        editmenu.add_command(label="Select All", command=self.select_all, accelerator="Command+A")
        editmenu.add_command(label="Delete", command=self.delete_selection)
        menubar.add_cascade(label="Edit", menu=editmenu)

                             
        helpmenu = Menu(menubar, tearoff=0)
        helpmenu.add_command(label="Help Index", command=find_focus)
        helpmenu.add_command(label="About...", command=donothing)
        menubar.add_cascade(label="Help", menu=helpmenu)

        root.config(menu=menubar)

        root.bind_all("<Command-n>", self.new_window)
        root.bind_all("<Command-o>", self.open_file)
        root.bind_all("<Command-s>", self.save_file)
        root.bind_all("<Command-Shift-s>", self.save_as_file)
        root.bind_all("<Command-q>", self.quit_project)
        
    def open_file(self, event=''):
        open_file = tkFileDialog.askopenfile(mode='r', **self.file_opt)
        window.text_box.delete(1.0, END)
        window.text_box.insert(END, open_file.read())
        self.file_name = open_file.name
        print self.file_name

    def save_file(self, event=''):
        pass
        if (self.file_name == ''):
            self.save_as_file()
        else:
            focus=root.focus_get()
            save_file = open(self.file_name, 'w')
            save_file.write(focus.get(1.0, END))
            self.file_name = save_file.name
    
    def save_as_file(self, event=''):
        focus=root.focus_get()
        save_file = tkFileDialog.asksaveasfile(mode='w', **self.file_opt)
        save_file.write(focus.get(1.0, END))
        self.file_name = save_file.name
        print self.file_name


    def copy(self):
        focus=root.focus_get()
        root.clipboard_clear() #is this needed?
        root.clipboard_append(focus.selection_get())

    def cut(self):
        self.copy()
        self.delete_selection()

    def paste(self):
        focus=root.focus_get()
        result = root.selection_get(selection = "CLIPBOARD")
        focus.insert(INSERT, result)

    def delete_selection(self):
        focus=root.focus_get()
        focus.delete(SEL_FIRST, SEL_LAST)
        
    def new_window(self, event=''):
        self.app = Window(root)#root.another_window = Window()
   #     window = Toplevel(root) #, takefocus=True
#        self.app = Window(window)#root.another_window = Window()

    def quit_project(self):
        sys.exit()
if __name__=='__main__':
    root = Tk()
    root.wm_title("Luke's Text Editor")
    app = Editor(root)
    root.mainloop()

