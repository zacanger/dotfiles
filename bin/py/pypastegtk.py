#!/usr/bin/env python
# -*- coding: utf-8 -*-

###########
#
#   File    pygtkpaste.py
#   Author  nicolas <nicolas.caen@gmail.com>
#   Version 0.1
#   Licence GPLv3
#   Date    15/09/2010
#
#####

import pygtk
pygtk.require('2.0')
import gtk
import urllib2
import urllib
import os
import ConfigParser
import re, htmlentitydefs
import string

# front end writen in pygtk for pastebin.com

class Pastebin:
    #Définition des attributs pour pastebin
    def __init__(self):
        self.paste_code = ""
        self.paste_name = ""
        self.paste_email = ""
        self.paste_subdomain = ""
        self.paste_private = 0
        self.paste_expire_date = "N"
        self.paste_expire_date_list = ( 'N', '10M', '1H', '1D', '1M' )
        self.paste_format = ""
        self.paste_format_fav = []
        self.paste_format_list = (
        'abap', 'actionscript', 'actionscript3', 'ada', 'apache',
        'applescript', 'apt_sources', 'asm', 'asp', 'autoit', 'avisynth',
        'bash', 'basic4gl', 'bibtex', 'blitzbasic', 'bnf', 'boo', 'bf', 'c',
        'c_mac', 'cill', 'csharp', 'cpp', 'caddcl', 'cadlisp', 'cfdg',
        'klonec', 'klonecpp', 'cmake', 'cobol', 'cfm', 'css', 'd', 'dcs',
        'delphi', 'dff', 'div', 'dos', 'dot', 'eiffel', 'email', 'erlang',
        'fo', 'fortran', 'freebasic', 'gml', 'genero', 'gettext', 'groovy',
        'haskell', 'hq9plus', 'html4strict', 'idl', 'ini', 'inno', 'intercal',
        'io', 'java', 'java5', 'javascript', 'kixtart', 'latex', 'lsl2',
        'lisp', 'locobasic', 'lolcode', 'lotusformulas', 'lotusscript',
        'lscript', 'lua', 'm68k', 'make', 'matlab', 'matlab', 'mirc',
        'modula3', 'mpasm', 'mxml', 'mysql', 'text', 'nsis', 'oberon2', 'objc',
        'ocaml-brief', 'ocaml', 'glsl', 'oobas', 'oracle11', 'oracle8',
        'pascal', 'pawn', 'per', 'perl', 'php', 'php-brief', 'pic16',
        'pixelbender', 'plsql', 'povray', 'powershell', 'progress', 'prolog',
        'properties', 'providex', 'python', 'qbasic', 'rails', 'rebol', 'reg',
        'robots', 'ruby', 'gnuplot', 'sas', 'scala', 'scheme', 'scilab',
        'sdlbasic', 'smalltalk', 'smarty', 'sql', 'tsql', 'tcl',
        'teraterm', 'thinbasic', 'typoscript', 'unreal', 'vbnet', 'verilog',
        'vhdl', 'vim', 'visualprolog', 'vb', 'visualfoxpro', 'whitespace',
        'whois', 'winbatch', 'xml', 'xorg_conf', 'xpp', 'z80'
        )

    #Submition of the pastebin
    def submit (self):
        api_url = 'http://pastebin.com/api_public.php'
        argv = { 'paste_code' : self.paste_code }

        if self.paste_format is not "":
            argv['paste_format'] = self.paste_format

        if self.paste_name is not "":
            argv['paste_name'] = self.paste_name

        if self.paste_subdomain is not "":
            argv['paste_subdomain'] = self.paste_subdomain

        if self.paste_email is not "":
            argv['paste_email'] = self.paste_email

        argv['paste_expire_date'] = self.paste_expire_date
        argv['paste_private'] = self.paste_private

        url = urllib2.urlopen(api_url, urllib.urlencode(argv))
        try:
            response = url.read()
        finally:
            url.close()
        del url
        return response        

    #If there is no config file, it will be created
    def create_config (self):
        home = os.environ['HOME']
        conf_file = home + '/.pygtkparserc'

        conf = ConfigParser.RawConfigParser()
        if os.path.isfile(conf_file):
            return

        conf.add_section('pastebin')

        conf.set('pastebin', 'paste_name', self.paste_name)
        conf.set('pastebin', 'paste_email', self.paste_email)
        conf.set('pastebin', 'paste_subdomain', self.paste_subdomain)
        conf.set('pastebin', 'paste_private', 0)
        conf.set('pastebin', 'paste_expire_date', self.paste_expire_date)
        conf.set('pastebin', 'paste_format_fav', 'c,text,php,python')
        self.paste_format_fav = ['c', 'text', 'php', 'python']

        #",".join(self.paste_format_fav))
        
        with open(conf_file, 'wb') as config:
            conf.write(config)

        print 'the configuration file has been created'
    
    #The config file, been parse at the start of programme
    def init_config(self):
        conf_file = os.environ['HOME'] + '/.pygtkparserc'
        conf = ConfigParser.RawConfigParser()
        conf.read(conf_file)

        self.paste_name = conf.get('pastebin', 'paste_name')
        self.paste_email = conf.get('pastebin', 'paste_email')
        self.paste_subdomain = conf.get('pastebin', 'paste_subdomain')
        self.paste_private = conf.getint('pastebin', 'paste_private')
        self.paste_expire_date = conf.get('pastebin', 'paste_expire_date')
        self.paste_format_fav = conf.get('pastebin',\
        'paste_format_fav').split(',')

    def save_config(self):

        conf_file = os.environ['HOME'] + '/.pygtkparserc'
        conf = ConfigParser.RawConfigParser()
        conf.read(conf_file)

        conf.set('pastebin', 'paste_name', self.paste_name)
        conf.set('pastebin', 'paste_email', self.paste_email)
        conf.set('pastebin', 'paste_subdomain', self.paste_subdomain)
        conf.set('pastebin', 'paste_private', self.paste_private)
        conf.set('pastebin', 'paste_expire_date', self.paste_expire_date)
        conf.set('pastebin', 'paste_format_fav',
        ",".join(self.paste_format_fav))

        with open(conf_file, 'wb') as config:
            conf.write(config)

class PygtkPaste:
    def __init__(self):
    
        # If the configuration file doesn't exist, we create it
        # then we go to the main loop
        conf_file = os.environ['HOME'] + '/.pygtkparserc'
        if os.path.isfile(conf_file) == False:
            pastebin.create_config()
        else:
            pastebin.init_config()
        
        # Init de la fenêtre principal
        self.window = gtk.Window(gtk.WINDOW_TOPLEVEL)
        self.window.set_resizable(True)
        self.window.connect("destroy", gtk.main_quit)
        self.window.set_title("PygtkPaste")
        self.window.set_border_width(10)
        self.window.resize(800, 800)
        
        # contenanceur
        self.box1 = gtk.VBox(False, 0)
        self.window.add(self.box1)
        self.box1.show()

        self.box2 = gtk.VBox(False, 10)
        self.box2.set_border_width(10)
        self.box1.pack_start(self.box2, True, True, 0)
        self.box2.show()

        # Import fonction above the text area
        # If the text field contain http:// it will be download
        # else, it will check if the path is on the pc
        frame_download = gtk.Frame("Get From URL or File")
        self.box2.pack_start(frame_download, False, False, 0)
        frame_download.show()

        box_download = gtk.HBox(False, 10)
        box_download.show()
        frame_download.add(box_download)
        
        self.get_field = gtk.Entry()
        box_download.pack_start(self.get_field, True, True, 10)
        self.get_field.connect("activate", self.get_pastebin_cb, None)
        self.get_field.show()

        button_get = gtk.Button("Get-it")
        button_get.connect("clicked", self.get_pastebin_cb, None)
        box_download.pack_end(button_get, False, False, 10)
        button_get.show()
        

        # The text area
        self.fd = gtk.ScrolledWindow()
        self.fd.set_policy(gtk.POLICY_AUTOMATIC, gtk.POLICY_AUTOMATIC)
        self.textpaste = gtk.TextView()
        self.buffer_text = self.textpaste.get_buffer()
        self.fd.add(self.textpaste)
        self.fd.show()
        self.textpaste.show()

        self.box2.pack_start(self.fd)
        
        # All three frames are added here, show after the text area
        # Option, Result and Submit
        self.frame_option = gtk.Frame("Pastebin Option")
        self.frame_result = gtk.Frame("Pastebin Result")
        self.frame_submit = gtk.Frame("Pastebin Submit")
        self.box_option = gtk.HBox(False, 10)
        self.box_result = gtk.HBox(True, 10)
        self.box_submit = gtk.HBox(False, 10)
        self.box2.pack_start(self.frame_option, False, False, 0)
        self.box2.pack_start(self.frame_result, False, False, 0)
        self.box2.pack_start(self.box_submit, False, False, 0)
        self.frame_option.add(self.box_option)
        self.frame_result.add(self.box_result)
        #self.frame_submit.add(self.box_submit)
        self.frame_option.show()
        self.frame_result.show()
        #self.frame_submit.show()
        self.box_option.show()
        self.box_result.show()
        self.box_submit.show()

        # Pastebin Option Frame display
        # First, the right and left box are defined
        box_option_left = gtk.VBox(False, 10)
        box_option_right = gtk.VBox(False, 10)
        separator = gtk.VSeparator()
        self.box_option.pack_start(box_option_left, False, False, 10)
        self.box_option.pack_start(separator, False, False, 10)
        self.box_option.pack_start(box_option_right, True, True, 10)
        box_option_left.show()
        separator.show()
        box_option_right.show()

        # Left options added
        # Syntax Highlighting (paste_format)
        list_paste_format = gtk.combo_box_new_text()
        list_paste_format.set_wrap_width(5)
        for index in range(len(pastebin.paste_format_list)):
            list_paste_format.append_text(pastebin.paste_format_list[index])
        box_option_left.pack_start(list_paste_format)
        list_paste_format.append_text('----- FAVORITES : -------')
        for index in range(len(pastebin.paste_format_fav)):
            list_paste_format.append_text(pastebin.paste_format_fav[index])
            if pastebin.paste_format_fav[index] == 'text':
                list_paste_format.set_active(len(pastebin.paste_format_list) +
                index + 1)
        list_paste_format.connect('changed', self.paste_format_cb, None)
        list_paste_format.show()

        separator = gtk.HSeparator()
        box_option_left.pack_start(separator, True, True, 0)
        separator.show()
        
        # Post expire Buttons
        # 5 Radio buttions
        box_expire = gtk.HBox(True, 0)
        box_option_left.pack_start(box_expire)
        box_expire.show()

        button = gtk.RadioButton(None, 'Never')
        button.connect('toggled', self.expire_cb, 0)
        box_expire.pack_start(button, True, True, 0)
        if pastebin.paste_expire_date == 'N':
            button.set_active(True)
        button.show()

        button = gtk.RadioButton(button, '10 Min')
        button.connect('toggled', self.expire_cb, 1)
        box_expire.pack_start(button, True, True, 0)
        if pastebin.paste_expire_date == '10M':
            button.set_active(True)
        button.show()
        
        button = gtk.RadioButton(button, '1 Hour')
        button.connect('toggled', self.expire_cb, 2)
        box_expire.pack_start(button, True, True, 0)
        if pastebin.paste_expire_date == '1H':
            button.set_active(True)
        button.show()
        
        button = gtk.RadioButton(button, '1 Day')
        button.connect('toggled', self.expire_cb, 3)
        box_expire.pack_start(button, True, True, 0)
        if pastebin.paste_expire_date == '1D':
            button.set_active(True)
        button.show()
        
        button = gtk.RadioButton(button, '1 Month')
        button.connect('toggled', self.expire_cb, 4)
        box_expire.pack_start(button, True, True, 0)
        if pastebin.paste_expire_date == '1M':
            button.set_active(True)
        button.show()

        separator = gtk.HSeparator()
        box_option_left.pack_start(separator, True, True, 0)
        separator.show()
        
        # Post exposure (priv/public)
        box_exposure = gtk.HBox(False, 0)
        box_option_left.pack_start(box_exposure)
        box_exposure.show()
        
        button = gtk.RadioButton(None, 'Public')
        button.connect('toggled', self.exposure_cb, 0)
        box_exposure.pack_start(button, False, True, 0)
        if pastebin.paste_private == 0:
            button.set_active(True)
        button.show()

        button = gtk.RadioButton(button, 'Private')
        button.connect('toggled', self.exposure_cb, 1)
        box_exposure.pack_start(button, False, True, 0)
        if pastebin.paste_private == 1:
            button.set_active(True)
        button.show()

        # Right box option, contain name and subdir
        # NAME option
        box_name = gtk.HBox(False, 0)
        box_option_right.pack_start(box_name, False, False, 0)
        box_name.show()

        label = gtk.Label('Name         ')
        box_name.pack_start(label, False, False, 0)
        label.show()

        self.name = gtk.Entry()
        self.name.set_max_length(30)
        box_name.pack_start(self.name, False, False, 10)
        self.name.connect("focus-out-event", self.name_cb)
        if pastebin.paste_name is not "":
            self.name.set_text(pastebin.paste_name)
        self.name.show()

        # subdomain option
        box_subdomain = gtk.HBox(False, 0)
        box_option_right.pack_start(box_subdomain, False, False, 0)
        box_subdomain.show()

        label = gtk.Label('subdomain')
        box_subdomain.pack_start(label, False, False, 0)
        label.show()

        self.subdomain = gtk.Entry()
        self.subdomain.set_max_length(30)
        box_subdomain.pack_start(self.subdomain, False, False, 10)
        self.subdomain.connect("focus-out-event", self.subdomain_cb)
        if pastebin.paste_subdomain is not "":
            self.subdomain.set_text(pastebin.paste_subdomain)
        self.subdomain.show()
        
        # Radio Button to diplay Normal, Download, Raw and embebed URL
        box_url_choice = gtk.HBox(True, 0)
        self.box_result.pack_start(box_url_choice, True, True, 20)
        box_url_choice.show()
        
        button = gtk.RadioButton(None, 'Normal')
        button.connect('toggled', self.url_display_cb, 0)
        box_url_choice.pack_start(button, True, True, 0)
        button.set_active(True)
        button.show()

        button = gtk.RadioButton(button, 'Download')
        button.connect('toggled', self.url_display_cb, 1)
        box_url_choice.pack_start(button, True, True, 0)
        button.show()
        
        button = gtk.RadioButton(button, 'Raw')
        button.connect('toggled', self.url_display_cb, 2)
        box_url_choice.pack_start(button, True, True, 0)
        button.show()
        
        button = gtk.RadioButton(button, 'Embed')
        button.connect('toggled', self.url_display_cb, 3)
        box_url_choice.pack_start(button, True, True, 0)
        button.show()

        self.display_url_active = 0

        # Button and text field on the Result part
        self.result_field = gtk.Entry()
        self.result_field.set_max_length(50)
        self.box_result.pack_start(self.result_field, True, True, 10)
        self.result_field.set_editable(False)
        self.result_field.show()

        # Button on the Submit part
        self.button_past = gtk.Button("Paste-It")
        self.button_past.connect("clicked", self.submit_pastebin, self.buffer_text)
        self.button_quit = gtk.Button("Quit")
        self.button_quit.connect("clicked", gtk.main_quit, None)
        self.box_submit.pack_start(self.button_past, False, False, 10)
        self.box_submit.pack_end(self.button_quit, False, False, 10)
        self.button_past.show()
        self.button_quit.show()
        button_save = gtk.Button("Save as Conf")
        button_save.connect("clicked", self.save_as_conf, None)
        self.box_submit.pack_start(button_save, False, False, 10)
        button_save.show()

        self.window.show()

    def submit_pastebin(self, widget, paste_code=None):
        #global pastebin
        start, end = paste_code.get_bounds()
        
        pastebin.paste_code = str(paste_code.get_text(start, end, True))
        paste_url = pastebin.submit()

        self.paste_number = paste_url.split('/')[-1]
        url_suffix = ('', 'download.php?i=', 'raw.php?i=', 'embeb.php?i=')
        self.result_field.set_text('http://' + paste_url.split('/')[-2] +\
        '/' + url_suffix[self.display_url_active] + self.paste_number)

    def url_display_cb(self, widget, value=None):
        if widget.get_active() == 1:
            self.display_url_active = value
            paste_url =  self.result_field.get_text()
            if paste_url == "":
                return
            url_suffix = ('', 'download.php?i=', 'raw.php?i=', 'embeb.php?i=')
            self.result_field.set_text('http://' + paste_url.split('/')[-2] +\
            '/' + url_suffix[self.display_url_active] + self.paste_number)

    def save_as_conf(self, widget, value=None):
        pastebin.save_config()
    
    def paste_format_cb(self, widget, value=None):
        active = widget.get_active_text()
        pastebin.paste_format = active

    def expire_cb(self, widget, value=None):
        if widget.get_active() == 1:
            pastebin.paste_expire_date =\
            pastebin.paste_expire_date_list[value]

    def exposure_cb(self, widget, value=None):
        if widget.get_active() == 1:
            pastebin.paste_private = value

    def name_cb(self, widget, value=None):
        pastebin.paste_name = widget.get_text()
    
    def subdomain_cb(self, widget, value=None):
        pastebin.paste_subdomain = widget.get_text()

    def get_pastebin_cb(self, widget, value=None):
        source = self.get_field.get_text()
        if source == "":
            return
        # First, if it is an URL, we get it from pastebin.com
        if 'http://' in source:
            url = urllib2.urlopen(source)
            try:
                data = url.read()
                data = data.split('</textarea')[-2]
                data = data.split('paste_textarea">')[1]
                data = self.unescape(data)
                self.buffer_text.set_text(data)
                self.paste_number = source.split('/')[-1]
                url_suffix = ('', 'download.php?i=', 'raw.php?i=', 'embeb.php?i=')
                self.result_field.set_text('http://' + source.split('/')[-2] +\
                '/' + url_suffix[self.display_url_active] + self.paste_number)
                self.textpaste.set_buffer(self.buffer_text)

            finally:
                url.close()

        if source[0] == '~':
            source = string.replace(source, '~', os.environ['HOME'])
        if os.path.isfile(source):
            file = open(source, "r")
            if file:
                self.buffer_text.set_text(file.read())
                file.close()
                self.textpaste.set_buffer(self.buffer_text)
                
##
# Removes HTML or XML character references and entities from a text string.
#
# @param text The HTML (or XML) source text.
# @return The plain text, as a Unicode string, if necessary.
# Fonction taken from Frederik Lundh blog.
    def unescape(self, text):
        def fixup(m):
            text = m.group(0)
            if text[:2] == "&#":
                # character reference
                try:
                    if text[:3] == "&#x":
                        return unichr(int(text[3:-1], 16))
                    else:
                        return unichr(int(text[2:-1]))
                except ValueError:
                    pass
            else:
                # named entity
                try:
                    text = unichr(htmlentitydefs.name2codepoint[text[1:-1]])
                except KeyError:
                    pass
            return text # leave as is
        return re.sub("&#?\w+;", fixup, text)
            
            
            

def main():
    gtk.main()
    return 0

if __name__ == "__main__":
    pastebin = Pastebin()
    PygtkPaste()
    main()