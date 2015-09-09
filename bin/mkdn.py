#!/usr/bin/env python2
'''
# markdown previewer
(requires pywebkitgtk)

## cli:
    mkdn.py <file>

## in vim:
    :!mkdn.py % &

## wrap it in a shell script:
    mkdn.py "$*" &
    ${EDITOR:-vim} "$*"
    kill %1

## template:
    ~/.mkdn.template (%s will be replaced by content)

## commands:
    c - copy source to clipboard
    s - toggle template
    v - toggle view source
    any other key will reset the window
'''

import codecs, gio, gobject, gtk, markdown, os, warnings, webkit
warnings.simplefilter('ignore', Warning)

class Previewer(object):

    def __init__(self, path):
        self.path = os.path.realpath(path)
        self.view_source = False
        self.clipboards = [gtk.Clipboard(selection="CLIPBOARD"),
                           gtk.Clipboard(selection="PRIMARY")]
        if os.path.isfile('%s/.mkdn.template' % os.environ['HOME']):
            fh = open('%s/.mkdn.template' % os.environ['HOME'])
            self.template = fh.read()
            fh.close()
            self.view_template = True
        else:
            self.template = '%s'
            self.view_template = False
        self.out = self.template
        if os.path.isfile(self.path):
            fh = open(self.path)
            self.html = markdown.markdown(fh.read().lstrip(codecs.BOM_UTF8))
            fh.close()
        else:
            self.html = ''

    def monitor(self, monitor, fl, ofl, kind):
        if kind == gio.FILE_MONITOR_EVENT_DELETED:
            self.view.load_html_string('', 'file:///')
        elif kind == gio.FILE_MONITOR_EVENT_CHANGES_DONE_HINT:
            try:
                self.html = fl.load_contents()[0].lstrip(codecs.BOM_UTF8)
                self.html = markdown.markdown(self.html)
            except:
                return
            self.view.load_html_string(self.out % self.html, 'file:///')

    def on_key_press(self, widget, event):
        keyname = gtk.gdk.keyval_name(event.keyval)
        func = getattr(self, 'key_press_' + keyname, None)
        if func:
            return func()
        else:
            self.view.load_html_string(self.out % self.html, 'file:///')

    def key_press_b(self):
        self.view.go_back()
        for i in dir(self.view):
            print i

    def key_press_c(self):
        for clipboard in self.clipboards:
            clipboard.set_text(self.html)

    def key_press_s(self):
        self.view_template = not self.view_template
        self.out = { True: self.template, False: '%s' }[self.view_template]
        self.view.load_html_string(self.out % self.html, 'file:///')

    def key_press_v(self):
        self.view_source = not self.view_source
        self.view.set_view_source_mode(self.view_source)
        self.view.load_html_string(self.out % self.html, 'file:///')

    def run(self):
        self.window = gtk.Window()
        self.view = webkit.WebView()
        self.view.props.settings.props.enable_default_context_menu = False
        self.window.connect('key_press_event', self.on_key_press)
        self.window.connect('destroy', gtk.main_quit)
        gio.File(self.path).monitor().connect('changed', self.monitor)
        self.window.add(self.view)
        self.window.set_title(self.path)
        self.view.load_html_string(self.out % self.html, 'file:///')
        self.window.show_all()
        gtk.main()

if __name__ == '__main__':
    import glob, sys
    args = ' '.join(sys.argv[1:])
    if not args:
        fls = glob.glob('README*')
        if fls:
            args = fls[0]
    if not args or args in ['-h', '--help']:
        print __doc__
        sys.exit(1)
    else:
        try:
            Previewer(args).run()
        except KeyboardInterrupt:
            pass
        sys.exit(0)
