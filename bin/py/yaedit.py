#!/usr/bin/env python

try:
    import gtksourceview2
    SV2 = True
except:
    import gtksourceview
    SV2 = False

import os, sys, gtk, gobject, pango, \
       mimetypes, re, glob, weakref

TIP_TIMEOUT = 400

mimetypes.init()

if SV2:
    MANAGER = gtksourceview2.language_manager_get_default()
else:
    MANAGER = gtksourceview.SourceLanguagesManager()

def get_language_from_mime_type(mime):
    if not SV2:
        return MANAGER.get_language_from_mime_type(mime)

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
        if event.keyval == 65289:
            widget.delete_selection()
            widget.set_position(widget.insert_text('\t', widget.get_position()))
            return True
    entry.connect('key-press-event', key_event)

def make_file_completion(callback):
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

    def key_event(widget, event):
        if event.keyval == 65289: #Tab
            tree.grab_focus()
            return True
    entry.connect('key-press-event', key_event)

    def key_event(widget, event):
        if event.keyval == 65289 or event.keyval == 65056: #Tab / Shift-Tab
            selection = tree.get_selection().get_selected()[1]
            if selection:
                entry.set_text(liststore.get_value(selection, 0))
            entry.grab_focus()
            return True
    tree.connect('key-press-event', key_event)

    def refresh_event(widget, *etc):
        freshen_list()

    entry.connect('changed', refresh_event)
    entry.connect('focus-in-event', refresh_event)

    def select(filename):
        if os.path.isdir(filename):
            entry.grab_focus()
            entry.set_text(filename)
            entry.select_region(0,-1)
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
            if filename.endswith('~'): continue
            if os.path.split(filename)[1].startswith('.'): continue
            if os.path.isdir(filename): filename += os.path.sep
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


class Tip:
    def __init__(self):
        self.window = gtk.Window()
        self.window.set_decorated(False)
        self.window.set_type_hint(gtk.gdk.WINDOW_TYPE_HINT_MENU)
        self.window.set_property('accept-focus', False)
        self.label = gtk.Label('hello')
        self.label.show()
        self.window.add(self.label)

        self.window.add_events(gtk.gdk.ENTER_NOTIFY)
        self.window.connect('enter-notify-event', lambda *etc: self.window.hide())

    def show(self, tip):
        self.label.set_text(tip)
        x,y = self.window.get_display().get_pointer()[1:3]
        width, height = self.window.get_size()
        self.window.move(x-width//2,y-height-10)
        self.window.show()

        gobject.timeout_add(TIP_TIMEOUT, lambda *etc: self.window.hide())

    def add_click_tip(self, widget, tip):
        def on_press(widget, event):
            if widget.is_focus() or event.button != 1: return
            self.show(tip)
        widget.connect('button-press-event', on_press)

class Editor:
    def __init__(self, filename):
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
        self.view.modify_font(pango.FontDescription('monospace'))

        mimetype = mimetypes.guess_type(filename)[0]
        if mimetype:
            self.buffer.set_language(get_language_from_mime_type(mimetype))

        if not os.path.exists(filename):
            open(filename, 'wb').close()

        self.file_signature = None
        self.file_text = ''
        self.sync_from_disk()

    def sync_from_disk(self):
        """ Replace text if file modified.

            Note: this needs to be called often or
                  edits may be lost
        """
        sig = get_file_signature(self.filename)
        if sig == self.file_signature: return False

        self.file_signature = sig

        text = open(self.filename,'rb').read()
        if text == self.file_text: return False

        self.file_text = text
        self.buffer.begin_not_undoable_action()
        self.buffer.set_text(self.file_text) #TODO: check utf-8 correctness
        self.buffer.end_not_undoable_action()
        return True

    def save_to_disk(self):
        #Nuke edits if disk file has changed
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

class Yaedit:
    def prefix_edited(self, *ignore):
        if self.busy: return
        self.busy += 1
        try:
            editor = self.active_editor()
            if not editor: return
            buffer = editor.get_buffer()

            new_prefix = self.prefix_entry.get_text()

            selection = buffer.get_selection_bounds()
            if not selection: return
            line1 = selection[0].get_line()
            line2 = selection[1].get_line()
            if selection[1].starts_line(): line2 -= 1
            if line1 == line2: return
            iter1 = buffer.get_iter_at_line(line1)
            iter2 = buffer.get_iter_at_line(line2)
            if not iter2.ends_line(): iter2.forward_to_line_end()
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
        finally:
            self.busy -= 1
        self.refresh()

    def line_edited(self, *ignore):
        if self.busy: return
        self.busy += 1
        try:
            editor = self.active_editor()
            if not editor: return
            buffer = editor.get_buffer()

            try:
                line = int(self.line_entry.get_text())
            except ValueError:
                return

            iter1 = buffer.get_iter_at_line(line-1)
            iter2 = buffer.get_iter_at_line(line-1)
            if not iter2.ends_line(): iter2.forward_to_line_end()
            buffer.select_range(iter1, iter2)
            editor.scroll_to_mark(buffer.get_mark('insert'), 0.25)
        finally:
            self.busy -= 1
        self.refresh()

    def go_find(self, forward):
        editor = self.active_editor()
        if not editor: return
        buffer = editor.get_buffer()

        if not self.search_matches:
            start, end = self.search_from, self.search_from

        elif forward:
            for (start, end) in self.search_matches:
                if start <= self.search_from: continue
                break
            else:
                start, end = self.search_matches[0]
        else:
            for (start, end) in self.search_matches[::-1]:
                if end >= self.search_from: continue
                break
            else:
                start, end = self.search_matches[-1]

        buffer.select_range(
            buffer.get_iter_at_offset(start),
            buffer.get_iter_at_offset(end)
        )
        editor.scroll_to_mark(buffer.get_mark('insert'), 0.25)

    def find_edited(self, *ignore):
        self.search_required = True
        self.refresh()

        self.go_find(True)

    def find_next(self, *ignore):
        editor = self.active_editor()
        if not editor: return
        buffer = editor.get_buffer()
        self.search_from = buffer.get_iter_at_mark(buffer.get_insert()).get_offset()
        self.go_find(True)

    def find_prev(self, *ignore):
        editor = self.active_editor()
        if not editor: return
        buffer = editor.get_buffer()
        self.search_from = buffer.get_iter_at_mark(buffer.get_insert()).get_offset()
        self.go_find(False)

    def unfocus(self, editor, *ignore):
        buffer = editor.get_buffer()
        self.search_from = buffer.get_iter_at_mark(buffer.get_insert()).get_offset()

    def entry_activate(self, *etc):
        editor = self.active_editor()
        if not editor: return
        editor.grab_focus()

    def refresh(self, *ignore):
        if self.busy: return
        self.busy += 1
        try:
            editor = self.active_editor()
            if not editor: return
            buffer = editor.get_buffer()
            insert = buffer.get_insert()
            self.line_entry.set_text( str(buffer.get_iter_at_mark(insert).get_line() + 1) )

            prefix_text = None
            selection = buffer.get_selection_bounds()
            if selection:
                line1 = selection[0].get_line()
                line2 = selection[1].get_line()
                if selection[1].starts_line(): line2 -= 1
                if line1 != line2:
                    iter1 = buffer.get_iter_at_line(line1)
                    iter2 = buffer.get_iter_at_line(line2)
                    if not iter2.ends_line(): iter2.forward_to_line_end()
                    text = buffer.get_text(iter1, iter2)
                    prefix_text = get_prefix(text.split('\n'))

            if prefix_text is not None:
                self.prefix_entry.set_text(prefix_text)
                self.prefix_label.show()
                self.prefix_entry.show()
            else:
                self.prefix_label.hide()
                self.prefix_entry.hide()

            if editor is not self.last_active:
                self.search_required = True

            if self.search_required:
                self.search_required = False
                buffer.remove_tag_by_name('found', buffer.get_start_iter(), buffer.get_end_iter())
                find_text = self.find_entry.get_text()
                if find_text:
                    text = buffer.get_text(buffer.get_start_iter(),buffer.get_end_iter()).decode('utf8')
                    self.search_matches = [
                        (match.start(), match.end()) for match in re.finditer(re.escape(find_text), text, re.IGNORECASE)
                    ]
                    if len(self.search_matches) < 1000: #Hmm
                        for start, end in self.search_matches:
                            iter1 = buffer.get_iter_at_offset(start)
                            iter2 = buffer.get_iter_at_offset(end)
                            buffer.apply_tag_by_name('found', iter1, iter2)
                else:
                    self.search_matches = [ ]

                if len(self.search_matches) < 2:
                    self.find_hbox.hide()
                else:
                    self.find_hbox.show()

            self.last_active = editor
        finally:
            self.busy -= 1

    def open_editor(self, filename):
        editor = Editor(filename)

        scrolly = gtk.ScrolledWindow()
        scrolly.set_policy(gtk.POLICY_AUTOMATIC, gtk.POLICY_AUTOMATIC)
        scrolly.add(editor.view)

        def focus_in(*etc):
            if self.busy: return

            editor.sync_from_disk()

            n = 0
            for i in xrange(self.notebook.get_n_pages()):
                if self.notebook.get_nth_page(i) in self.editors:
                    n += 1
                if self.notebook.get_nth_page(i) is scrolly:
                    if n < 10:
                        self.tip.show('Alt-%d' % n)
                        break
        editor.view.connect('focus', focus_in)

        def mod_change(widget):
            def mod_change_todo():
                if not editor.buffer.get_modified(): return
                editor.save_to_disk()
                self.search_required = True
                self.add_todo(self.refresh)
            self.add_todo(mod_change_todo)
        editor.buffer.set_modified(False)
        editor.buffer.connect('modified-changed',
                              mod_change)

        editor.buffer.connect('mark-set', self.refresh)

        editor.buffer.create_tag('found', background='light blue')

        editor.view.connect('focus-out-event', self.unfocus)

        hbox = gtk.HBox()
        label = gtk.Label(filename)
        hbox.pack_start(label, False, False)

        def close(widget):
            scrolly.destroy()
            hbox.destroy()

        closer = gtk.Button(unichr(10005).encode('utf-8'))
        closer.set_relief(gtk.RELIEF_NONE)
        closer.child.modify_font(pango.FontDescription('7'))
        closer.connect('clicked', close)
        self.tip.add_click_tip(closer, 'Ctrl-W')
        hbox.pack_end(closer, False, False)

        hbox.show_all()
        scrolly.show_all()

        filenames = [ ]
        i = 0
        while i < self.notebook.get_n_pages():
            item = self.notebook.get_nth_page(i)
            if item not in self.editors:
                break
            filenames.append(self.editors[item].filename)
            i += 1

        best = 0
        best_before = ''
        for i in xrange(1,len(filenames)+1):
            if filenames[i-1] > best_before and filename >= filenames[i-1]:
                best = i
                best_before = filenames[i-1]
        where = best

        self.notebook.insert_page(scrolly, hbox, where)
        self.notebook.set_current_page(self.notebook.page_num(scrolly))
        self.notebook.set_tab_reorderable(scrolly, True)

        self.editors[scrolly] = editor

    def active_editor(self):
        page = self.notebook.get_nth_page(self.notebook.get_current_page())
        if page not in self.editors: return None
        return page.child

    def add_todo(self, callback):
        if callback in self.todo: return
        if not self.todo:
            def do_todo(*etc):
                if self.todo:
                    self.todo.pop(0)()
                    return True
            gobject.idle_add(do_todo)
        self.todo.append(callback)

    def __init__(self, filenames):
        self.editors = weakref.WeakKeyDictionary()
        self.todo = [ ]

        self.tip = Tip()

        self.notebook = gtk.Notebook()
        self.notebook.set_tab_pos(gtk.POS_LEFT)
        self.notebook.set_scrollable(True)

        open_vbox = gtk.VBox(False, 5)
        label = gtk.Label('open')
        label.set_alignment(0.0,0.0)
        label.show()
        open_vbox.pack_start(label, False,False)

        open_entry, scroller = make_file_completion(self.open_editor)
        open_vbox.pack_start(open_entry, True,True)
        self.notebook.append_page(scroller, open_vbox)
        def focusin(*etc):
            self.notebook.set_current_page(self.notebook.page_num(scroller))
            open_entry.grab_focus()
        open_entry.connect('focus-in-event', focusin)

        vbox = gtk.VBox(False, 5)

        label = gtk.Label('line')
        label.set_alignment(0.0,0.0)
        vbox.pack_start(label, False,False)

        self.line_entry = gtk.Entry()
        self.line_entry.connect('changed', self.line_edited)
        self.line_entry.connect('activate', self.entry_activate)
        vbox.pack_start(self.line_entry, False,False)

        label = gtk.Label('find')
        label.set_alignment(0.0,0.0)
        vbox.pack_start(label, False,False)

        self.find_entry = gtk.Entry()
        self.find_entry.connect('changed', self.find_edited)
        self.find_entry.connect('activate', self.entry_activate)
        allow_tabs_in_entry(self.find_entry)
        vbox.pack_start(self.find_entry, False,False)

        self.find_hbox = gtk.HBox(False, 0)
        vbox.pack_start(self.find_hbox, False,False)

        left = gtk.Button('prev')
        left.connect('clicked', self.find_prev)
        self.find_hbox.pack_start(left)
        right = gtk.Button('next')
        right.connect('clicked', self.find_next)
        self.find_hbox.pack_start(right)


        self.prefix_label = gtk.Label('prefix')
        self.prefix_label.set_alignment(0.0,0.0)
        vbox.pack_start(self.prefix_label, False,False)

        self.prefix_entry = gtk.Entry()
        self.prefix_entry.connect('changed', self.prefix_edited)
        self.prefix_entry.connect('activate', self.entry_activate)
        allow_tabs_in_entry(self.prefix_entry) #!

        vbox.pack_start(self.prefix_entry, False,False)

        vbox.show_all()

        page = gtk.Label('')
        self.notebook.append_page(page, vbox)

        def on_switch(widget, _, page_number):
            if page_number > 0 and page_number == self.notebook.page_num(page):
                self.notebook.emit_stop_by_name('switch-page')
        self.notebook.connect('switch-page', on_switch)

        #TODO:
        #toolbox = gtk.Label('')
        #label = gtk.Label('tools')
        #label.set_alignment(0.0,0.0)
        #self.notebook.append_page(toolbox, label)

        self.window = gtk.Window()
        self.window.resize(900,700)
        self.window.set_title('yaedit')
        self.window.add(self.notebook)

        def delete_event(*etc):
            self.window.hide()
            self.tip.show('Ctrl-Q')
            gobject.timeout_add(TIP_TIMEOUT, lambda: self.window.destroy())
            return True
        self.window.connect('delete-event', delete_event)

        self.accel_group = gtk.AccelGroup()
        self.window.add_accel_group(self.accel_group)

        self.accel_group.connect_group(ord('Q'), gtk.gdk.CONTROL_MASK, 0,
            lambda *etc: self.window.destroy())

        self.accel_group.connect_group(ord('I'), gtk.gdk.CONTROL_MASK, 0,
            lambda *etc: self.line_entry.grab_focus())
        self.tip.add_click_tip(self.line_entry, 'Ctrl-I')

        self.accel_group.connect_group(ord('F'), gtk.gdk.CONTROL_MASK, 0,
            lambda *etc: self.find_entry.grab_focus())
        self.tip.add_click_tip(self.find_entry, 'Ctrl-F')

        self.accel_group.connect_group(ord('O'), gtk.gdk.CONTROL_MASK, 0,
            lambda *etc: open_entry.grab_focus())
        self.tip.add_click_tip(open_entry, 'Ctrl-O')

        def close_editor():
            page = self.notebook.get_nth_page(self.notebook.get_current_page())
            if page in self.editors:
                page.destroy()
        self.accel_group.connect_group(ord('W'), gtk.gdk.CONTROL_MASK, 0,
            lambda *etc: close_editor())

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

        def prefix_focuser(*etc):
            settings = self.prefix_entry.get_settings()
            old = settings.get_property('gtk-entry-select-on-focus')
            settings.set_property('gtk-entry-select-on-focus', False)
            self.prefix_entry.grab_focus()
            pos = 0
            for char in self.prefix_entry.get_text():
                if char not in ' \t': break
                pos += 1
            self.prefix_entry.set_position(pos)
            settings.set_property('gtk-entry-select-on-focus', old)
        self.accel_group.connect_group(ord('P'), gtk.gdk.CONTROL_MASK, 0,
            prefix_focuser)
        self.tip.add_click_tip(self.prefix_entry, 'Ctrl-P')

        self.window.show_all()
        self.find_hbox.hide()

        self.busy = 0
        self.last_active = None
        self.search_required = False
        self.search_matches = [ ]
        self.search_from = 0

        for filename in filenames:
            self.open_editor(filename)

        if not filenames:
            open_entry.grab_focus()
        else:
            self.notebook.set_current_page(0)
            self.notebook.get_nth_page(0).child.grab_focus()

        def timeout():
            for editor in self.editors.values():
                editor.sync_from_disk()
            return True

        gobject.timeout_add(1000, timeout)

        self.refresh()



if __name__ == '__main__':
    yaedit = Yaedit(sys.argv[1:])
    yaedit.window.connect('destroy', gtk.main_quit)

    gtk.main()


