#!/usr/bin/env python2
import os
import json
import time
import cairo
import thread
import urllib
import base64
import urllib2
import threading
import subprocess
from gi.repository import Gtk, GdkPixbuf

class grab_region_dialog(Gtk.Dialog):
    def __init__(self, parent):
        Gtk.Dialog.__init__(self, "", None,
            Gtk.DialogFlags.MODAL, buttons=("OK", Gtk.ResponseType.OK))
        box = self.get_content_area()
        label = Gtk.Label('Click OK, then left click hold and move your mouse\nin order to grab the wanted area.')
        box.add(label)
        self.show_all()

class take_screenshot_at_launch:
    os.system('scrot /tmp/Screenshot1.png -t 425x240')
take_screenshot_at_launch()

class return_window:

    decorations = "on"

class sceenshot_gui:

    def on_send_to_changed(self, widget):
        active = self.send_to.get_active_text()
        if active == "imgur (share it)":
            #threading.Thread(target=self.on_upload_clicked).start() deprecate the locking
            thread.start_new_thread(self.on_upload_clicked, ("start_in_new_thread", ))

        if active == "Image viewer/editor":
            self.on_send_to_image_viewer_or_editor_clicked()

    def on_upload_clicked(self, widget):
        lock = threading.Lock()
        lock.acquire()
        self.take_new_snapshot.set_sensitive(False)
        self.send_to.set_sensitive(False)
        self.save_as.set_sensitive(False)
        self.capturemode.set_sensitive(False)
        self.capture_delay_button.set_sensitive(False)
        self.about.set_sensitive(False)
        self.vbox.remove(self.linkbut1)
        self.vbox.remove(self.linkbut2)
        self.vbox.add(self.upload_label)
        self.upload_label.show()
        with open('/tmp/Screenshot1.png', 'rb') as fh:
            contents = fh.read()
        payload = urllib.urlencode((('image', base64.b64encode(contents)),
            ('key', 'd6b1f349164de03db83f18bb6ed0a1307b723e5c'),))
        request = urllib2.Request('https://api.imgur.com/3/image', payload)
        request.add_header('Authorization', 'Client-ID ' + '0a4d37c6ef225c9')
        try:
            resp = urllib2.urlopen(request)
        except urllib2.HTTPError, exc:
            return False, 'Returned status: %s' % exc.code
        except urllib2.URLError, exc:
            return False, exc.reason
        resp_data = resp.read()
        try:
            resp_json = json.loads(resp_data)
        except ValueError:
            return False, 'Error decoding response: %s' % resp_data
        if resp_json['success']:
            self.vbox.remove(self.upload_label)
            self.vbox.add(self.linkbut1)
            self.vbox.add(self.linkbut2)
            self.linkbut1.set_uri("{0}".format(resp_json['data']['link']))
            self.linkbut2.set_uri("http://imgur.com/delete/{0}".format(resp_json['data']['deletehash']))
            self.linkbut1.set_label("Click to see the image and it\'s share link")
            self.linkbut2.set_label("Delete Link")
            self.take_new_snapshot.set_sensitive(True)
            self.send_to.set_sensitive(True)
            self.save_as.set_sensitive(True)
            self.capturemode.set_sensitive(True)
            self.capture_delay_button.set_sensitive(True)
            self.about.set_sensitive(True)
            self.upload_label.hide()
            lock.release()

    def on_window_decorations_toggled(self, decorations_toggled):
        if decorations_toggled.get_active():
            self.return_window = "on"
        else:
            self.return_window = "off"

    def on_capturemodebox_changed(self, widget):
        active = self.capturemode.get_active_text()

        if active == "Full Screen":
            self.window_decorations.set_sensitive(False)

        if active == "Active Window":
            self.window_decorations.set_sensitive(True)

        if active == "Grab Region":
            self.window_decorations.set_sensitive(False)

    def draw_transparency(self, widget, cr):
        cr.set_source_rgba(.1, .1, .1, 0.6)
        cr.set_operator(cairo.OPERATOR_SOURCE)
        cr.paint()
        cr.set_operator(cairo.OPERATOR_OVER)

    def on_take_new_snapshot_clicked(self, widget):
        time.sleep(float(self.capture_delay_button.get_text()))

        if self.capturemode.get_active_text() == "Grab Region":
            self.window.hide()
            grab_dialog = grab_region_dialog(self)
            response = grab_dialog.run()
            if response == Gtk.ResponseType.OK:
                grab_dialog.destroy()
                os.system("scrot -s /tmp/Screenshot1.png -t 425x240")
                self.PNG.set_from_file('/tmp/Screenshot1-thumb.png')
            grab_dialog.destroy()
            self.window.show()

        if self.capturemode.get_active_text() == "Active Window":
            # active window idea taken from https://wiki.archlinux.org/index.php/Taking_a_Screenshot#Screenshot_of_the_active.2Ffocused_window
            if "{0}".format(self.return_window) == "on":
                get_active_window = subprocess.check_output("xprop -root | grep '_NET_ACTIVE_WINDOW(WINDOW)'", shell=True)
                os.system("import -frame -window '{0}' /tmp/Screenshot1.png".format(get_active_window[40:-1]))

            if "{0}".format(self.return_window) == "off":
                get_active_window = subprocess.check_output("xprop -root | grep '_NET_ACTIVE_WINDOW(WINDOW)'", shell=True)
                os.system("import -window '{0}' /tmp/Screenshot1.png".format(get_active_window[40:-1]))
            os.system("convert /tmp/Screenshot1.png -resize 425x240 /tmp/Screenshot2.png")
            self.PNG.set_from_file('/tmp/Screenshot2.png')

        if self.capturemode.get_active_text() == "Full Screen":
            #width = os.system("xdpyinfo | grep dimensions | awk '{print $2}' | awk -Fx '{print $1}'")
            #height = os.system("xdpyinfo | grep dimensions | awk '{print $2}' | awk -Fx '{print $2}'")
            os.system('scrot /tmp/Screenshot1.png -t 425x240')
            self.PNG.set_from_file('/tmp/Screenshot1-thumb.png')

    def on_save_as_clicked(self, widget):
        chooser_dialog = Gtk.FileChooserDialog(title="Save To..."
        ,action=Gtk.FileChooserAction.SAVE
        ,buttons=["Save", Gtk.ResponseType.ACCEPT, "Cancel", Gtk.ResponseType.CANCEL])
        response = chooser_dialog.run()
        filename = chooser_dialog.get_filename()

        if response == Gtk.ResponseType.ACCEPT:
            if filename.endswith(".jpeg") or filename.endswith(".tiff") or filename.endswith(".tif") or filename.endswith(".jpg") or filename.endswith(".bmp") or filename.endswith(".gif"):
                os.system("convert /tmp/Screenshot1.png '{0}'".format(filename))
            elif filename.endswith(".png"):
                os.system("cp /tmp/Screenshot1.png " + filename)
            else:
                os.system("cp /tmp/Screenshot1.png " + filename + ".png")
        if response == Gtk.ResponseType.CANCEL:
            pass
        chooser_dialog.destroy()

    def on_about_clicked(self, widget):
        aboutdialog = Gtk.AboutDialog()
        aboutdialog.set_program_name("Pshot")
        aboutdialog.set_logo(GdkPixbuf.Pixbuf.new_from_file("data_pshot/pshot_logo.png"))
        aboutdialog.set_comments("Screenshot Utility\n")
        aboutdialog.set_website("http://linux.sytes.net/")
        aboutdialog.set_website_label("Developer Website")
        aboutdialog.set_authors(["Aaron"])
        aboutdialog.set_license('GPLv3 - http://www.gnu.org/licenses/gpl.html')
        aboutdialog.run()
        aboutdialog.destroy()

    def thread_image_viewer_or_editor(self, widget):
        selected_app = open("/tmp/.app_name")
        app_name = "{0}".format(selected_app.read())
        if app_name == "Pinta Image Editor":
            os.system("pinta /tmp/Screenshot1.png")
        elif app_name == "GNU Image Manipulation Program":
            os.system("gimp /tmp/Screenshot1.png")
        elif app_name == "Gwenview":
            os.system("gwenview /tmp/Screenshot1.png")
        elif app_name == "F-Spot Photo Viewer":
            os.system("f-spot /tmp/Screenshot1.png")
        elif app_name == "MyPaint":
            os.system("mypaint /tmp/Screenshot1.png")
        elif app_name == "Shotwell Photo Viewer":
            os.system("shotwell /tmp/Screenshot1.png")
        elif app_name == "Okular":
            os.system("okular /tmp/Screenshot1.png")
        elif app_name == "Ristretto Image Viewer":
            os.system("ristretto /tmp/Screenshot1.png")
        elif app_name == "gThumb Image Viewer":
            os.system("gthumb /tmp/Screenshot1.png")
        elif app_name == "Geeqie":
            os.system("geeqie /tmp/Screenshot1.png")
        elif app_name == "feh":
            os.system("feh /tmp/Screenshot1.png")
        elif app_name == "gimmage":
            os.system("gimmage /tmp/Screenshot1.png")
        elif app_name == "Viewnior":
            os.system("viewnior /tmp/Screenshot1.png")
        elif app_name == "Mirage":
            os.system("mirage /tmp/Screenshot1.png")
        elif app_name == "Image Viewer":
            os.system("eog /tmp/Screenshot1.png")
        elif app_name == "showFoto":
            os.system("showfoto /tmp/Screenshot1.png")
        elif app_name == "CinePaint":
            os.system("cinepaint /tmp/Screenshot1.png")
        elif app_name == "Krita":
            os.system("krita /tmp/Screenshot1.png")
        elif app_name == "Luminance HDR":
            os.system("luminance-hdr /tmp/Screenshot1.png")
        elif app_name == "RawTherapee":
            os.system("rawtherapee /tmp/Screenshot1.png")
        elif app_name == "KolourPaint":
            os.system("kolourpaint /tmp/Screenshot1.png")
        else:
            os.system("gimp /tmp/Screenshot1.png")

    def on_send_to_image_viewer_or_editor_clicked(self):
        appchooserdialog = Gtk.AppChooserDialog(content_type="image/png")
        response = appchooserdialog.run()
        if response == Gtk.ResponseType.OK:
            app_info = appchooserdialog.get_app_info()
            display_name = app_info.get_display_name()
            f = open("/tmp/.app_name", "w")
            f.write("{0}".format(display_name))
            f.close()
            thread.start_new_thread(self.thread_image_viewer_or_editor, ("start_in_new_thread", ))
        appchooserdialog.destroy()

    def __init__(self):
        self.intf = Gtk.Builder()
        self.intf.add_from_file('data_pshot/pshot.ui')
        self.intf.connect_signals(self)

        self.capturemode = self.intf.get_object('capturemodebox')
        self.capturemode.set_active(0)

        self.PNG = self.intf.get_object("image1")
        self.PNG.set_from_file('/tmp/Screenshot1-thumb.png')

        self.capture_delay_button = self.intf.get_object('spinbutton1')
        self.capturemode = self.intf.get_object('capturemodebox')
        self.spinbutton = self.intf.get_object('spinbutton1')
        self.send_to = self.intf.get_object('send_to')
        self.take_new_snapshot = self.intf.get_object('take_new_snapshot')
        self.send_to = self.intf.get_object('send_to')
        self.save_as = self.intf.get_object('save_as')
        self.about = self.intf.get_object('about')

        self.vbox = self.intf.get_object("box3")
        self.upload_label = self.intf.get_object("label1")
        self.vbox.remove(self.upload_label)
        self.linkbut1 = self.intf.get_object('linkbutton1')
        self.linkbut2 = self.intf.get_object('linkbutton2')
        self.vbox.remove(self.linkbut1)
        self.vbox.remove(self.linkbut2)
        self.intf2 = Gtk.Builder()
        self.intf2.add_from_file('data_pshot/infobar.ui')
        self.upload_label = self.intf2.get_object("infobar1")
        self.vbox.remove(self.upload_label)
        self.return_window = return_window.decorations


        self.spinbutton.set_text("2")
        self.window_decorations = self.intf.get_object('window_decorations')

        decorations = open("/tmp/.decorations", "w")
        decorations.write("on")
        decorations.close()

        self.window = self.intf.get_object("window1")

        self.window.screen = self.window.get_screen()
        self.window.visual = self.window.screen.get_rgba_visual()
        if self.window.visual is not None and self.window.screen.is_composited():
            self.window.set_visual(self.window.visual)
        self.window.set_app_paintable(True)
        self.window.connect("draw", self.draw_transparency)

        self.window.connect("delete-event", Gtk.main_quit)
        self.window.show_all()

if __name__ == '__main__':
    sceenshot_gui()
    Gtk.main()