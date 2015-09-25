#!/usr/bin/env python

import gtk, webkit

def go_but(widget):
    add = addressbar.get_text()
    if add.startswith("http://"):
       web.open(add)
    else:
       add = "http://" + add
       addressbar.set_text(add)
       web.open(add)

def	new_title(view, frame, title):
	win.set_title(title)

def	on_click_link(view, frame):
	uri=frame.get_uri()
	#addressbar.set_text(uri)

win = gtk.Window()
win.set_default_size(890,700)
win.connect('destroy', lambda w: gtk.main_quit())

box1 = gtk.VBox()
win.add(box1)

box2 = gtk.HBox()
box1.pack_start(box2, False)


#addressbar = gtk.Entry()
#addressbar.connect("activate", go_but)
#box2.pack_start(addressbar)

#gobutton = gtk.Button("GO")
#box2.pack_start(gobutton, False)
#gobutton.connect('clicked', go_but)

scroller = gtk.ScrolledWindow()
box1.pack_start(scroller)

web = webkit.WebView()
web.open("file:///usr/share/cookbook/index.html")
#web.open("http://website.org")
web.connect("title-changed", new_title)
web.connect("load-committed", on_click_link)

scroller.add(web)

win.show_all()

gtk.main()


