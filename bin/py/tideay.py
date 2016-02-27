#!/usr/bin/env python
# encoding: UTF-8

#         1         2         3         4         5         6         7
#1234567890123456789012345678901234567890123456789012345678901234567890123456789

try:
    import gtksourceview2
    SV2 = True
except:
    import gtksourceview
    SV2 = False

import mimetypes
import os
import re
import socket
import subprocess
import sys
import weakref

import glob
import gobject
import gtk
import pango

### constants ###

CLOSE_TIMEOUT = 400

if SV2:
    MANAGER = gtksourceview2.language_manager_get_default()
else:
    MANAGER = gtksourceview.SourceLanguagesManager()

KEYVAL_TAB = 65289
KEYVAL_SHIFT_TAB = 65056
KEYVAL_RETURN = 65293
KEYVAL_BACKSPACE = 65288

# not a dict, because order matters, and we iterate it anyway.
# some symbols are supported from HTML entity names, minus the ;
# (LaTeX might also be supported in the future, but redundancy is OK here)
# TODO maybe just find a Python module that already does HTMLentities
PRODUCTIVE_REWRITE_MAP = (
    # four or more characters
    (u'    ', u'        '),
    (u'&cap', u'∩'),
    (u'&cup', u'∪'),
    (u'&sub', u'⊂'),
    (u'&sup', u'⊃'),
    (u'&isin', u'∈'),
    (u'&notin', u'∉'),
    # greek alphabet (three or more characters)
    (u'&alpha', u'α'),
    (u'&beta', u'β'),
    (u'&gamma', u'γ'),
    (u'&delta', u'δ'),
    (u'&epsilon', u'ε'),
    (u'&zeta', u'ζ'),
    (u'&theta', u'θ'),
    (u'&iota', u'ι'),
    (u'&kappa', u'κ'),
    (u'&lambda', u'λ'),
    (u'&mu', u'μ'),
    (u'&nu', u'ν'),
    (u'&xi', u'ξ'),
    (u'&omicron', u'ο'),
    (u'&pi', u'π'),
    (u'&rho', u'ρ'),
    (u'&sigma', u'σ'),
    (u'&tau', u'τ'),
    (u'&upsilon', u'υ'),
    (u'&phi', u'φ'),
    (u'&chi', u'χ'),
    (u'&psi', u'ψ'),
    (u'&omega', u'ω'),
    # three characters
    (u'(c)', u'©'),
    (u'GBP', u'£'),
    (u'EUR', u'€'),
    (u".'.", u'∴'),
    (u'<->', u'↔'),
    (u'<~>', u'↭'),
    (u'...', u'…'),
    (u'(x)', u'⊗'),
    (u'(.)', u'⊙'),
    (u'(+)', u'⊕'),
    (u'(-)', u'⊖'),
    (u'(/)', u'⊘'),
    # two characters
    (u"''", u'ˮ'),   # this is a dbl-apo U+02EE.
    (u'--', u'—'),
    (u'->', u'→'),
    (u'<-', u'←'),
    (u'-^', u'↑'),
    (u'-v', u'↓'),
    (u'~>', u'↝'),
    (u'<~', u'↜'),
    (u'=>', u'⇒'),
    (u'=<', u'⇐'),   # <= is already used for ≤…
    (u'=^', u'⇑'),
    (u'=v', u'⇓'),
    (u'<<', u'«'),
    (u'>>', u'»'),
    (u'[[', u'⟦'),
    (u']]', u'⟧'),
    (u'<.', u'⟨'),
    (u'.>', u'⟩'),
    (u'[^', u'「'),
    (u'^]', u'」'),
    (u'<=', u'≤'),
    (u'⊂=', u'⊆'),
    (u'>=', u'≥'),
    (u'⊃=', u'⊇'),
    (u'/=', u'≠'),
    (u'c/', u'¢'),
    (u'<3', u'♡'),
    (u'&&', u'⌘'),
    (u'*5', u'☆'),
    (u'<>', u'♢'),
    (u'{}', u'∅'),
    (u'[]', u'□'),
    (u'./', u'÷'),
    (u'.*', u'×'),
    (u'.^', u'·'),
    (u'^I', u'\t'),
    (u'a`', u'à'),
    (u"a'", u'á'),
    (u'a:', u'ä'),
    (u'e`', u'è'),
    (u"e'", u'é'),
    (u'e:', u'ë'),
    (u"i:", u'ï'),
    (u"i'", u'í'),
    (u'o:', u'ö'),
    (u"o'", u'ó'),
    (u'u:', u'ü'),
    (u'U:', u'Ü'),
    (u"u'", u'ú'),
    (u'ae', u'æ'),
    (u'AE', u'Æ'),
    # one character.  note the swapping.
    (u'♡', u'♥'),
    (u'♥', u'♡'),
    (u'☆', u'★'),
    (u'★', u'☆'),
    (u'♢', u'♦'),
    (u'♦', u'♢'),
    (u'·', u'•'),
    (u'•', u'·'),
    (u'□', u'■'),
    (u'■', u'□'),
    (u'σ', u'ς'),
    (u'ς', u'σ'),
    (u"`", u'′'),
    (u"′", u'″'),
    (u"″", u'‴'),
    (u'"', u'“'),
    (u'“', u'”'),
    (u'”', u'"'),
    (u'↝', u'⇝'),
    (u'⇝', u'↝'),
    (u'↜', u'⇜'),
    (u'⇜', u'↜'),
    (u'≤', u'⇐'),   # because <= goes to ≤ but sometimes you mean ⇐
    (u'⇐', u'≤'),
    (u'\t', u'\t\t'),
)

DESTRUCTIVE_REWRITE_MAP = (
    # four characters
    (u'    ', u''),
)


mimetypes.init()


### functions ###

def get_language_from_mime_type(mime):
    if not SV2:
        return MANAGER.get_language_from_mime_type(mime)

    #print MANAGER.get_search_path()
    lang_ids = MANAGER.get_language_ids()
    for i in lang_ids:
        lang = MANAGER.get_language(i)
        for m in lang.get_mime_types():
            if m == mime:
                return lang
    return None


def get_file_signature(filename):
    item = os.stat(filename)
    return (item.st_mtime, item.st_size)


def allow_tabs_in_entry(entry):
    def key_event(widget, event):
        if event.keyval == KEYVAL_TAB:
            widget.delete_selection()
            widget.set_position(
                widget.insert_text('\t', widget.get_position())
            )
            return True
    entry.connect('key-press-event', key_event)


def get_prefix(lines):
    prefix = lines[0]
    for line in lines[1:]:
        for i in xrange(len(prefix)):
            if (len(line) <= i and prefix[i] in ' \t') or \
               (len(line) > i and line[i] == prefix[i]):
                continue
            prefix = prefix[:i]
            break
    return prefix


def rewrite_text(text, map):
    if text == u'':
        return u'    '
    for (search, replace) in map:
        search = search.encode('UTF-8')
        if text.endswith(search):
            return text[:-len(search)] + replace.encode('UTF-8')
    return text


### classes ###

class Editor(object):
    def __init__(self, filename, mimetype=None):
        self.filename = filename
        if SV2:
            self.buffer = gtksourceview2.Buffer()
            self.buffer.set_highlight_syntax(True)
        else:
            self.buffer = gtksourceview.SourceBuffer()
            self.buffer.set_highlight(True)
        self.buffer.set_max_undo_levels(1000)
        if SV2:
            self.view = gtksourceview2.View(self.buffer)
        else:
            self.view = gtksourceview.SourceView(self.buffer)
        self.view.set_auto_indent(True)
        self.view.modify_font(pango.FontDescription('Ubuntu Mono 12'))

        self.view.connect('key_press_event', self.on_key_press_event)

        self.touch()
        language = self.get_language(mimetype)
        if language:
            self.buffer.set_language(language)

        self.file_signature = None
        self.file_text = ''
        self.sync_from_disk()

    def key(self):
        return '%s(%s)' % (self.__class__.__name__, self.filename)

    def on_key_press_event(self, widget, event):
        end = self.buffer.get_iter_at_offset(
            self.buffer.get_property('cursor-position')
        )
        start = self.buffer.get_iter_at_line(end.get_line())
        if event.keyval == KEYVAL_TAB:
            self.productive_rewrite(start, end)
            return True
        elif event.keyval == KEYVAL_RETURN:
            if event.state & gtk.gdk.CONTROL_MASK:
                self.execute_command(start, end)
                return True
            else:
                self.possibly_indent_new_block(start, end)
                return False
        elif (event.keyval == KEYVAL_BACKSPACE and
              event.state & gtk.gdk.SHIFT_MASK):
            self.destructive_rewrite(start, end)
            return True
        else:
            keyname = gtk.gdk.keyval_name(event.keyval)
            #print "Key %s (%d) was pressed" % (keyname, event.keyval)

    def touch(self):
        if not os.path.exists(self.filename):
            open(self.filename, 'wb').close()

    def get_language(self, mimetype):
        if not mimetype:
            mimetype = mimetypes.guess_type(self.filename)[0]
        if mimetype:
            return get_language_from_mime_type(mimetype)

        if not mimetype and self.filename.endswith('.pyx'):
            return get_language_from_mime_type('text/x-python')

        line = None
        with open(self.filename, 'r') as f:
            for line in f:
                break
        if line is not None and line.startswith('#!'):
            langs = (
                ('python', 'text/x-python'),
                ('ruby', 'text/x-ruby'),
                ('lua', 'text/x-lua'),
                ('bin/sh', 'text/x-sh'),
                ('bash', 'text/x-sh'),
            )
            for (name, mime_type) in langs:
                if name in line:
                    return get_language_from_mime_type(mime_type)

        return None

    def sync_from_disk(self):
        """ Replace text if file modified.

            Note: this needs to be called often or
                  edits may be lost
        """
        sig = get_file_signature(self.filename)
        if sig == self.file_signature:
            return False

        self.file_signature = sig

        text = open(self.filename, 'rb').read()
        if text == self.file_text:
            return False

        self.file_text = text
        self.buffer.begin_not_undoable_action()
        self.buffer.set_text(self.file_text)  # TODO: check utf-8 correctness
        self.buffer.end_not_undoable_action()
        self.buffer.place_cursor(self.buffer.get_start_iter())
        return True

    def save_to_disk(self):
        # Nuke edits if disk file has changed
        if self.sync_from_disk():
            return

        text = self.buffer.get_text(*self.buffer.get_bounds())
        f = open(self.filename, 'rb+')
        f.write(text)
        f.truncate()
        f.close()
        self.file_signature = get_file_signature(self.filename)
        self.file_text = text
        self.buffer.set_modified(False)

    def productive_rewrite(self, start, end):
        self.buffer.begin_user_action()
        text = self.buffer.get_text(start, end, True)
        text = rewrite_text(text, PRODUCTIVE_REWRITE_MAP)
        self.buffer.delete(start, end)
        self.buffer.insert(start, text, len(text))
        self.buffer.end_user_action()

    def destructive_rewrite(self, start, end):
        self.buffer.begin_user_action()
        text = self.buffer.get_text(start, end, True)
        text = rewrite_text(text, DESTRUCTIVE_REWRITE_MAP)
        self.buffer.delete(start, end)
        self.buffer.insert(start, text, len(text))
        self.buffer.end_user_action()

    def possibly_indent_new_block(self, start, end):
        text = self.buffer.get_text(start, end, True)
        if (text.endswith((':', '{', '(', '[')) or
            text.startswith(('*   ', '-   '))):
            # Allow the keystroke, but queue an insert of four spaces
            def insert_four_spaces(widget):
                widget.insert_at_cursor(u'    ', 4)
            gtk.idle_add(insert_four_spaces, self.buffer)

    def execute_command(self, start, end):
        self.buffer.begin_user_action()
        command = self.buffer.get_text(start, end, True)
        if command.startswith('%'):
            command = command[1:]
            command = command.strip()
            pipe = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE)
            output = pipe.communicate()[0]
            output = '\n' + output
            self.buffer.insert(end, output, len(output))
            def insert_prompt(widget):
                widget.insert_at_cursor(u'% ', 2)
            gtk.idle_add(insert_prompt, self.buffer)
        elif command.startswith('|'):
            command = command[1:]
            command = '%s < %s' % (
                command, self.filename
            )
            self.buffer.delete(start, end)
            self.save_to_disk()
            pipe = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE)
            output = pipe.communicate()[0]
            self.buffer.set_text(output)
        elif command.startswith('cd '):
            dirname = command[3:]
            if os.path.isdir(dirname):
                os.chdir(dirname)
                #self.set_window_title(-1, self)
            self.buffer.set_text('')
        else:
            pipe = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE)
            output = pipe.communicate()[0]
            self.buffer.delete(start, end)
            self.buffer.insert(start, output, len(output))
        self.buffer.end_user_action()

    def set_prefix(self, new_prefix):
        buffer = self.buffer
        selection = buffer.get_selection_bounds()
        if not selection:
            return
        line1 = selection[0].get_line()
        line2 = selection[1].get_line()
        if selection[1].starts_line():
            line2 -= 1
        if line1 == line2:
            return
        iter1 = buffer.get_iter_at_line(line1)
        iter2 = buffer.get_iter_at_line(line2)
        if not iter2.ends_line():
            iter2.forward_to_line_end()
        text = buffer.get_text(iter1, iter2)
        lines = text.split('\n')
        prefix = get_prefix(lines)
        
        lines = text.split('\n')
        for i in xrange(len(lines)):
            lines[i] = new_prefix + lines[i][len(prefix):]
        text = '\n'.join(lines)
        
        buffer.begin_user_action()
        buffer.delete(iter1, iter2)
        iter1 = buffer.get_iter_at_line(line1)
        buffer.insert(iter1, text)
        
        iter1 = buffer.get_iter_at_line(line1)
        iter2 = buffer.get_iter_at_line(line2)
        iter2.forward_to_line_end()
        buffer.select_range(iter1, iter2)
        
        buffer.end_user_action()


class Watcher(Editor):
    def __init__(self, command, mimetype=None):
        Editor.__init__(self, command, mimetype=mimetype)
        self.view.set_editable(False)

    def on_key_press_event(self, widget, event):
        return False

    def touch(self):
        pass

    def get_language(self, mimetype):
        return get_language_from_mime_type(mimetype)

    def sync_from_disk(self):
        pipe = subprocess.Popen(self.filename, shell=True, stdout=subprocess.PIPE)
        output = pipe.communicate()[0]
        if output == self.buffer.get_text(*self.buffer.get_bounds()):
            return False
        self.buffer.set_text(output)
        return True

    def save_to_disk(self):
        return


class Tideay(object):
    def __init__(self, dir):
        self.dir = dir
        # instance variables (there are others; they are all gtk controls)
        self.busy = 0
        self.last_active = None
        self.search_required = False
        self.search_matches = []
        self.search_from = 0
        # keys are gtk ScrollViews (what's added to the notebook)
        # values are Editor objects (defined in this source)
        self.editors = weakref.WeakKeyDictionary()
        self.todo = []

        # default dimensions are 820x745 with a little padding.
        # width is contrived to make the text area 80 columns wide.
        window_width = 825
        if 'TIDEAY_WIDTH' in os.environ:
            window_width = int(os.environ['TIDEAY_WIDTH'])
        window_height = 740
        if 'TIDEAY_HEIGHT' in os.environ:
            window_height = int(os.environ['TIDEAY_HEIGHT'])

        # -- Window -- #
        self.window = gtk.Window()
        self.window.resize(window_width, window_height)

        self.accel_group = gtk.AccelGroup()
        self.window.add_accel_group(self.accel_group)

        def delete_event(*etc):
            self.window.hide()
            gobject.timeout_add(CLOSE_TIMEOUT, lambda: self.window.destroy())
            return True
        self.window.connect('delete-event', delete_event)
        self.accel_group.connect_group(ord('Q'), gtk.gdk.CONTROL_MASK, 0,
            lambda *etc: self.window.destroy())

        # -- Notebook -- #
        self.notebook = gtk.Notebook()
        self.notebook.set_tab_pos(gtk.POS_LEFT)
        self.notebook.set_scrollable(True)

        # -- Widgets -- #
        self.create_open_widget()
        self.create_line_find_prefix_widget()
        #self.create_project_widget()

        def on_switch(widget, _, page_number):
            if page_number == self.notebook.page_num(self.empty_page):
                self.notebook.emit_stop_by_name('switch-page')
                return
            self.set_window_title(page_number)

        self.notebook.connect('switch-page', on_switch)

        self.window.add(self.notebook)

        def open_watcher(*etc):
            path = self.dir
            while True:
                if os.path.isdir(os.path.join(path, '.git')):
                    self.open_watcher('git diff', mimetype='text/x-diff')
                    break
                elif os.path.isdir(os.path.join(path, '.hg')):
                    self.open_watcher('hg diff --nodates', mimetype='text/x-diff')
                    break
                elif path == '/' or not path:
                    break
                else:
                    path = os.path.dirname(path)
            return True

        self.accel_group.connect_group(ord('D'), gtk.gdk.CONTROL_MASK, 0,
            open_watcher)

        # TODO: connect this to the sourceview control and have it fakie-send
        # a copy (Ctrl+C) to the sourceview.  Also Ctrl+Shift+V ⇒ paste.
        self.accel_group.connect_group(ord('C'), gtk.gdk.CONTROL_MASK | gtk.gdk.SHIFT_MASK, 0,
            open_watcher)

        def close_editor():
            page = self.notebook.get_nth_page(self.notebook.get_current_page())
            if page in self.editors:
                page.destroy()
        self.accel_group.connect_group(ord('W'), gtk.gdk.CONTROL_MASK, 0,
            lambda *etc: close_editor())

        #self.make_tab_focusers()

        self.window.show_all()
        self.find_hbox.hide()

        self.open_entry.grab_focus()

        def timeout():
            for editor in self.editors.values():
                editor.sync_from_disk()
            return True
        gobject.timeout_add(1000, timeout)

        self.refresh()

    def create_open_widget(self):
        vbox = gtk.VBox(False, 5)
        label = gtk.Label('open')
        label.set_alignment(0.0, 0.0)
        label.show()
        vbox.pack_start(label, False, False)

        self.open_entry, self.open_scroller = \
            self.make_file_completion(self.open_editor)
        vbox.pack_start(self.open_entry, True, True)

        def focusin(*etc):
            self.notebook.set_current_page(
                self.notebook.page_num(self.open_scroller)
            )
            self.open_entry.grab_focus()
        self.open_entry.connect('focus-in-event', focusin)

        self.notebook.append_page(self.open_scroller, vbox)

        self.accel_group.connect_group(ord('O'), gtk.gdk.CONTROL_MASK, 0,
            lambda *etc: self.open_entry.grab_focus())

    def create_line_find_prefix_widget(self):
        vbox = gtk.VBox(False, 5)
        
        # line
        label = gtk.Label('line')
        label.set_alignment(0.0, 0.0)
        vbox.pack_start(label, False, False)

        self.line_entry = gtk.Entry()
        self.line_entry.connect('changed', self.line_edited)
        self.line_entry.connect('activate', self.entry_activate)
        vbox.pack_start(self.line_entry, False, False)

        # find
        label = gtk.Label('find')
        label.set_alignment(0.0, 0.0)
        vbox.pack_start(label, False, False)

        self.find_entry = gtk.Entry()
        self.find_entry.connect('changed', self.find_edited)
        self.find_entry.connect('activate', self.entry_activate)
        allow_tabs_in_entry(self.find_entry)
        vbox.pack_start(self.find_entry, False, False)

        self.find_hbox = gtk.HBox(False, 0)
        vbox.pack_start(self.find_hbox, False, False)

        left = gtk.Button('prev')
        left.connect('clicked', self.find_prev)
        self.find_hbox.pack_start(left)
        right = gtk.Button('next')
        right.connect('clicked', self.find_next)
        self.find_hbox.pack_start(right)

        # prefix
        self.prefix_label = gtk.Label('prefix')
        self.prefix_label.set_alignment(0.0, 0.0)
        vbox.pack_start(self.prefix_label, False, False)

        self.prefix_entry = gtk.Entry()
        self.prefix_entry.connect('changed', self.prefix_edited)
        self.prefix_entry.connect('activate', self.entry_activate)
        allow_tabs_in_entry(self.prefix_entry)

        vbox.pack_start(self.prefix_entry, False, False)

        vbox.show_all()
        
        # for showing the current file when the line find prefix widget is
        # focused. or rather, not focusing it.  honestly, this is a bit hacky.
        # but is there a less hacky alternative...?  shrug
        self.empty_page = gtk.Label('')
        self.notebook.append_page(self.empty_page, vbox)

        self.accel_group.connect_group(ord('I'), gtk.gdk.CONTROL_MASK, 0,
            lambda *etc: self.line_entry.grab_focus())

        self.accel_group.connect_group(ord('F'), gtk.gdk.CONTROL_MASK, 0,
            lambda *etc: self.find_entry.grab_focus())

        def prefix_focuser(*etc):
            settings = self.prefix_entry.get_settings()
            old = settings.get_property('gtk-entry-select-on-focus')
            settings.set_property('gtk-entry-select-on-focus', False)
            self.prefix_entry.grab_focus()
            pos = 0
            for char in self.prefix_entry.get_text():
                if char not in ' \t':
                    break
                pos += 1
            self.prefix_entry.set_position(pos)
            settings.set_property('gtk-entry-select-on-focus', old)
        self.accel_group.connect_group(ord('P'), gtk.gdk.CONTROL_MASK, 0,
            prefix_focuser)

    def create_project_widget(self):
        vbox = gtk.VBox(False, 5)
        label = gtk.Label('project')
        label.set_alignment(0.0, 0.0)
        vbox.pack_start(label, False, False)

        project_entry = gtk.Entry()
        vbox.pack_start(project_entry, True, True)
        vbox.show_all()
        project_page = gtk.Entry()  # ?!?
        self.notebook.append_page(project_page, vbox)

    def make_tab_focusers(self):
        # i never use this -- you have to count & i often have >10 tabs
        def make_tab_focuser(x):
            def focus_tab(*etc):
                countdown = x
                for i in xrange(self.notebook.get_n_pages()):
                    if self.notebook.get_nth_page(i) in self.editors:
                        countdown -= 1
                        if countdown == 0:
                            self.notebook.set_current_page(i)
            return focus_tab
        for i in range(1, 10):
            self.accel_group.connect_group(ord(str(i)), gtk.gdk.MOD1_MASK, 0,
                make_tab_focuser(i))

    def make_file_completion(self, callback):
        entry = gtk.Entry()
        entry.show()
    
        liststore = gtk.ListStore(gobject.TYPE_STRING)
        tree = gtk.TreeView(liststore)
        renderer = gtk.CellRendererText()
        column = gtk.TreeViewColumn(None, renderer, text=0)
        tree.append_column(column)
        tree.set_headers_visible(False)
    
        scroller = gtk.ScrolledWindow()
        scroller.set_policy(gtk.POLICY_AUTOMATIC, gtk.POLICY_AUTOMATIC)
        scroller.add(tree)
        scroller.show_all()
    
        def key_event_entry(widget, event):
            if event.keyval == KEYVAL_TAB:
                tree.grab_focus()
                return True
        entry.connect('key-press-event', key_event_entry)
    
        def key_event_tree(widget, event):
            if event.keyval in (KEYVAL_TAB, KEYVAL_SHIFT_TAB):
                selection = tree.get_selection().get_selected()[1]
                if selection:
                    entry.set_text(liststore.get_value(selection, 0))
                entry.grab_focus()
                return True
        tree.connect('key-press-event', key_event_tree)
    
        def refresh_event(widget, *etc):
            freshen_list()
    
        entry.connect('changed', refresh_event)
        entry.connect('focus-in-event', refresh_event)
    
        def select(filename):
            if os.path.isdir(filename):
                entry.grab_focus()
                entry.set_text(filename)
                entry.select_region(0, -1)
            else:
                entry.set_text('')
                callback(filename)
    
        def freshen_list():
            liststore.clear()
            text = entry.get_text()
            if text.startswith('~') and 'HOME' in os.environ:
                text = os.environ.get('HOME') + text[1:]
            files = glob.glob(text + '*')
            files.sort()
            for filename in files:
                if filename.endswith('~'):
                    continue
                if os.path.split(filename)[1].startswith('.'):
                    continue
                if os.path.isdir(filename):
                    filename += os.path.sep
                liststore.append([filename])
    
        def entry_activate(*etc):
            select(entry.get_text())
        entry.connect('activate', entry_activate)
    
        def move(widget, kind, amount):
            if amount < 0 and tree.get_cursor()[0] == (0,):
                entry.grab_focus()
        tree.connect('move-cursor', move)
    
        def select_row(widget, path, *etc):
            select(liststore.get_value(liststore.get_iter(path), 0))
        tree.connect('row-activated', select_row)
    
        return entry, scroller

    def set_window_title(self, page_number, editor=None):
        if editor is None:
            scrolly = self.notebook.get_nth_page(page_number)
            editor = self.editors.get(scrolly, None)
        if editor:
            self.window.set_title(
                '%s - tideay' % os.path.relpath(editor.filename)
            )
        else:
            self.window.set_title('tideay')

    # ...editing command drivers...

    def prefix_edited(self, *ignore):
        if self.busy:
            return
        self.busy += 1
        try:
            editor = self.active_editor()
            if editor:
                new_prefix = self.prefix_entry.get_text()
                editor.set_prefix(new_prefix)
        finally:
            self.busy -= 1
        self.refresh()

    def line_edited(self, *ignore):
        if self.busy:
            return
        self.busy += 1
        try:
            sourceview = self.active_sourceview()
            if not sourceview:
                return
            buffer = sourceview.get_buffer()

            try:
                line = int(self.line_entry.get_text())
            except ValueError:
                return

            iter1 = buffer.get_iter_at_line(line - 1)
            iter2 = buffer.get_iter_at_line(line - 1)
            if not iter2.ends_line():
                iter2.forward_to_line_end()
            buffer.select_range(iter1, iter2)
            sourceview.scroll_to_mark(buffer.get_mark('insert'), 0.25)
        finally:
            self.busy -= 1
        self.refresh()

    def go_find(self, forward):
        sourceview = self.active_sourceview()
        if not sourceview:
            return
        buffer = sourceview.get_buffer()

        if not self.search_matches:
            start, end = self.search_from, self.search_from
        elif forward:
            for (start, end) in self.search_matches:
                if start <= self.search_from:
                    continue
                break
            else:
                start, end = self.search_matches[0]
        else:
            for (start, end) in self.search_matches[::-1]:
                if end >= self.search_from:
                    continue
                break
            else:
                start, end = self.search_matches[-1]

        buffer.select_range(
            buffer.get_iter_at_offset(start),
            buffer.get_iter_at_offset(end)
        )
        sourceview.scroll_to_mark(buffer.get_mark('insert'), 0.25)

    def find_edited(self, *ignore):
        self.search_required = True
        self.refresh()

        self.go_find(True)

    def find_next(self, *ignore):
        sourceview = self.active_sourceview()
        if not sourceview:
            return
        buffer = sourceview.get_buffer()
        insert = buffer.get_insert()
        self.search_from = buffer.get_iter_at_mark(insert).get_offset()
        self.go_find(True)

    def find_prev(self, *ignore):
        sourceview = self.active_sourceview()
        if not sourceview:
            return
        buffer = sourceview.get_buffer()
        insert = buffer.get_insert()
        self.search_from = buffer.get_iter_at_mark(insert).get_offset()
        self.go_find(False)

    def unfocus(self, sourceview, *ignore):
        buffer = sourceview.get_buffer()
        insert = buffer.get_insert()
        self.search_from = buffer.get_iter_at_mark(insert).get_offset()

    def entry_activate(self, *etc):
        sourceview = self.active_sourceview()
        if not sourceview:
            return
        sourceview.grab_focus()

    def refresh(self, *ignore):
        if self.busy:
            return
        self.busy += 1
        try:
            sourceview = self.active_sourceview()
            if not sourceview:
                return
            buffer = sourceview.get_buffer()
            insert = buffer.get_insert()
            self.line_entry.set_text(
                str(buffer.get_iter_at_mark(insert).get_line() + 1)
            )

            prefix_text = None
            selection = buffer.get_selection_bounds()
            if selection:
                line1 = selection[0].get_line()
                line2 = selection[1].get_line()
                if selection[1].starts_line():
                    line2 -= 1
                if line1 != line2:
                    iter1 = buffer.get_iter_at_line(line1)
                    iter2 = buffer.get_iter_at_line(line2)
                    if not iter2.ends_line():
                        iter2.forward_to_line_end()
                    text = buffer.get_text(iter1, iter2)
                    prefix_text = get_prefix(text.split('\n'))

            if prefix_text is not None:
                self.prefix_entry.set_text(prefix_text)
                self.prefix_label.show()
                self.prefix_entry.show()
            else:
                self.prefix_label.hide()
                self.prefix_entry.hide()

            if sourceview is not self.last_active:
                self.search_required = True

            if self.search_required:
                self.search_required = False
                buffer.remove_tag_by_name(
                    'found', buffer.get_start_iter(), buffer.get_end_iter()
                )
                find_text = self.find_entry.get_text()
                if find_text:
                    text = buffer.get_text(
                        buffer.get_start_iter(), buffer.get_end_iter()
                    ).decode('utf8')
                    self.search_matches = [
                        (match.start(), match.end())
                        for match in
                        re.finditer(re.escape(find_text), text, re.IGNORECASE)
                    ]
                    if len(self.search_matches) < 1000:  # Hmm
                        for start, end in self.search_matches:
                            iter1 = buffer.get_iter_at_offset(start)
                            iter2 = buffer.get_iter_at_offset(end)
                            buffer.apply_tag_by_name('found', iter1, iter2)
                else:
                    self.search_matches = []

                if len(self.search_matches) < 2:
                    self.find_hbox.hide()
                else:
                    self.find_hbox.show()

            self.last_active = sourceview
        finally:
            self.busy -= 1

    def open_editor(self, filename):
        filename = os.path.abspath(filename)
        if filename.endswith(':') and not os.path.exists(filename):
            filename = filename[:-1]
        return self.open_buffer(Editor(filename), os.path.basename(filename))

    def open_watcher(self, command, mimetype=None):
        return self.open_buffer(Watcher(command, mimetype=mimetype), command)

    # TODO: "buffer" needs a better name.  as does "editor"
    def open_buffer(self, editor, label_text):

        i = 0
        while i < self.notebook.get_n_pages():
            item = self.notebook.get_nth_page(i)
            if item not in self.editors:
                break
            if self.editors[item].key() == editor.key():
                print "%s already open" % editor.key()
                self.select_editor(i)
                return
            i += 1

        scrolly = gtk.ScrolledWindow()
        scrolly.set_policy(gtk.POLICY_AUTOMATIC, gtk.POLICY_AUTOMATIC)
        scrolly.add(editor.view)

        def focus_in(*etc):
            if self.busy:
                return
            editor.sync_from_disk()

        editor.view.connect('focus', focus_in)

        def mod_change(widget):
            def mod_change_todo():
                if not editor.buffer.get_modified():
                    return
                editor.save_to_disk()
                self.search_required = True
                self.add_todo(self.refresh)
            self.add_todo(mod_change_todo)
        editor.buffer.set_modified(False)
        editor.buffer.connect('modified-changed', mod_change)

        editor.buffer.connect('mark-set', self.refresh)

        editor.buffer.create_tag('found', background='light blue')

        editor.view.connect('focus-out-event', self.unfocus)

        hbox = gtk.HBox()
        label = gtk.Label(label_text)
        hbox.pack_start(label, False, False)

        def close(widget):
            scrolly.destroy()
            hbox.destroy()

        closer = gtk.Button('x'.encode('utf-8'))
        closer.set_relief(gtk.RELIEF_NONE)
        closer.child.modify_font(pango.FontDescription('7'))
        closer.connect('clicked', close)
        hbox.pack_end(closer, False, False)
        hbox.set_usize(120, 15)

        hbox.show_all()
        scrolly.show_all()

        # TODO does this make sense anymore?
        filenames = []
        i = 0
        while i < self.notebook.get_n_pages():
            item = self.notebook.get_nth_page(i)
            if item not in self.editors:
                break
            filenames.append(self.editors[item].filename)
            i += 1

        best = 0
        best_before = ''
        for i in xrange(1, len(filenames) + 1):
            if filenames[i - 1] > best_before and filename >= filenames[i - 1]:
                best = i
                best_before = filenames[i - 1]
        where = best

        self.notebook.insert_page(scrolly, hbox, where)
        self.select_editor(self.notebook.page_num(scrolly))
        self.notebook.set_tab_reorderable(scrolly, True)
        self.editors[scrolly] = editor

    def active_sourceview(self):
        """Note that this returns a gtksourceview2.View object.

        """
        editor = self.active_editor()
        if editor is None:
            return None
        return editor.view

    def active_editor(self):
        page = self.notebook.get_nth_page(self.notebook.get_current_page())
        if page not in self.editors:
            return None
        return self.editors[page]

    def add_todo(self, callback):
        if callback in self.todo:
            return
        if not self.todo:
            def do_todo(*etc):
                if self.todo:
                    self.todo.pop(0)()
                    return True
            gobject.idle_add(do_todo)
        self.todo.append(callback)

    def select_editor(self, n):
        self.notebook.set_current_page(n)
        self.notebook.get_nth_page(n).child.grab_focus()
        self.set_window_title(n)


def on_receive_message(fh, num, tideay):
    try:
        filenames = fh.readline().strip('\n').split('\v')
        for filename in filenames:
            try:
                tideay.open_editor(filename)
            except Exception as e:
                print filename, repr(e)
                # TODO and maybe backtrace
        # tideay.bring_to_front()
    except Exception as e:
        print repr(e)
        # TODO and maybe backtrace
    return True


if __name__ == '__main__':
    cwd = os.path.realpath(os.getcwd())
    rendezvous = '\0tideay' + cwd
    lock_socket = socket.socket(socket.AF_UNIX, socket.SOCK_DGRAM)
    try:
        lock_socket.bind(rendezvous)
        tideay = Tideay(cwd)
        for filename in sys.argv[1:]:
            tideay.open_editor(filename)
        tideay.select_editor(0)
        tideay.window.connect('destroy', gtk.main_quit)
        gobject.io_add_watch(
            lock_socket.makefile('r'),
            gobject.IO_IN, on_receive_message, tideay
        )
        gtk.main()
    except socket.error:
        lock_socket.connect(rendezvous)
        lock_socket.send('\v'.join(sys.argv[1:]) + '\n')
