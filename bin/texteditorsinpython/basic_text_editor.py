from Tkinter import *

class Editor:

    def __init__(self, master):

        global text_box
        text_box = Text(root)
        text_box.pack()

        text_box.focus_set()

        

        def contents():
                contents = text.get(1.0, END)
                print contents
                
        def load(path):
                user_file = open(path, 'r')
                text = str(user_file.read())
                print text
                text_box.delete(1.0, END)
                text_box.insert(END, text)
                user_file.close()
                
        def save(path):
                user_file = open(path, 'w')
                contents = text_box.get(1.0, END)
                user_file.write(contents)
                user_file.close()
                print contents
                
    
                
        path = Entry(master)
        path.pack(side=RIGHT)
        path.insert(0, 'text_file.txt')

        load(path.get())
        
        save_b = Button(root, text="save", width=10, command = lambda: save(path.get()))#command=save(path.get()))
        load_b = Button(root, text="load", width=10, command = lambda: load(path.get()))#command=load(path.get()))
        get_b = Button(root, text="get", width=10, command=contents)
 

        load_b.pack(side=LEFT)
        save_b.pack(side=LEFT)
        get_b.pack(side=LEFT)



root = Tk()

root.wm_title("Luke's Text Editor")

app = Editor(root)

root.mainloop()
