#-------------------------------------------------------
import pickle, sys

#Functions tab
def help():
    print("These are the available commands:")
    print("make new doc")
    print("view doc")
    print("help")
    print("bye")
def make_new_doc():
    filename = raw_input("name =")
    filename = filename + ".pydoc"
    print("----- Editing " + filename + " -----")
    additions = raw_input("")
    print("Saving file.")
    pickle.dump(additions, open(filename, "wb"))
    print("File saved.")
def view_doc():
    filename = raw_input("name =")
    filename = filename + ".pydoc"
    view = pickle.load(open(filename, "rb"))
    print(view)

def while_loop():
    print("Welcome to notepyd")
    while True:
        command = raw_input(">")
        cmd = command.lower()
        if cmd == "view doc":
            view_doc()
        if cmd == "make new doc":
            make_new_doc()
        if cmd == "help":
            help()
        if cmd == "bye":
            sys.exit()
while_loop()

