#!/usr/bin/env python2

import gtk

window = gtk.Window()
window.set_default_size(640, 480)
window.set_title("Image Viewer")

class Image:
    def __init__(self):

        vbox = gtk.VBox(False, 5)
        scrolledwindow = gtk.ScrolledWindow()

        self.image = gtk.Image()
        self.button = gtk.FileChooserButton("Select Image", None)
        self.button.connect("file-set", self.load_image)

        window.add(vbox)
        vbox.pack_start(self.button, False, False, 0)
        vbox.pack_start(scrolledwindow, True, True, 0)

        scrolledwindow.add_with_viewport(self.image)

        window.show_all()

    def load_image(self, widget):
        self.image.set_from_file(self.button.get_filename())
        window.set_title("Image Viewer - " + self.button.get_filename())
        window.set_icon_from_file(self.button.get_filename())

Image()
gtk.main()
