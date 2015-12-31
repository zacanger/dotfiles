#!/usr/bin/env python2

import gtk, webkit, os

class ExampleEditor(gtk.Window):
  def __init__(self):
    gtk.Window.__init__(self)
    self.set_title("editor")
    self.connect("destroy", gtk.main_quit)
    self.resize(500, 500)
    self.filename = None

    self.editor = webkit.WebView()
    self.editor.set_editable(True)
    self.editor.load_html_string("content content oh yeah content", "file:///")

    scroll = gtk.ScrolledWindow()
    scroll.add(self.editor)
    scroll.set_policy(gtk.POLICY_AUTOMATIC, gtk.POLICY_AUTOMATIC)

    self.ui = self.generate_ui()
    self.add_accel_group(self.ui.get_accel_group())
    self.toolbar1 = self.ui.get_widget("/toolbar_main")
    self.toolbar2 = self.ui.get_widget("/toolbar_format")
    self.menubar = self.ui.get_widget("/menubar_main")

    self.layout = gtk.VBox()
    self.layout.pack_start(self.menubar, False)
    self.layout.pack_start(self.toolbar1, False)
    self.layout.pack_start(self.toolbar2, False)
    self.layout.pack_start(scroll, True, True)
    self.add(self.layout)

  def generate_ui(self):
    ui_def = """
    <ui>
      <menubar name="menubar_main">
        <menu action="menuFile">
          <menuitem action="new" />
          <menuitem action="open" />
          <menuitem action="save" />
        </menu>
        <menu action="menuEdit">
          <menuitem action="cut" />
          <menuitem action="copy" />
          <menuitem action="paste" />
        </menu>
        <menu action="menuInsert">
          <menuitem action="insertimage" />
        </menu>
        <menu action="menuFormat">
          <menuitem action="bold" />
          <menuitem action="italic" />
          <menuitem action="underline" />
          <menuitem action="strikethrough" />
          <separator />
          <menuitem action="font" />
          <menuitem action="color" />
          <separator />
          <menuitem action="justifyleft" />
          <menuitem action="justifyright" />
          <menuitem action="justifycenter" />
          <menuitem action="justifyfull" />
        </menu>
      </menubar>
      <toolbar name="toolbar_main">
        <toolitem action="new" />
        <toolitem action="open" />
        <toolitem action="save" />
        <separator />
        <toolitem action="undo" />
        <toolitem action="redo" />
        <separator />
        <toolitem action="cut" />
        <toolitem action="copy" />
        <toolitem action="paste" />
      </toolbar>
      <toolbar name="toolbar_format">
        <toolitem action="bold" />
        <toolitem action="italic" />
        <toolitem action="underline" />
        <toolitem action="strikethrough" />
        <separator />
        <toolitem action="font" />
        <toolitem action="color" />
        <separator />
        <toolitem action="justifyleft" />
        <toolitem action="justifyright" />
        <toolitem action="justifycenter" />
        <toolitem action="justifyfull" />
        <separator />
        <toolitem action="insertimage" />
        <toolitem action="insertlink" />
      </toolbar>
    </ui>
    """

    actions = gtk.ActionGroup("Actions")
    actions.add_actions([
      ("menuFile", None, "_File"),
      ("menuEdit", None, "_Edit"),
      ("menuInsert", None, "_Insert"),
      ("menuFormat", None, "_Format"),

      ("new", gtk.STOCK_NEW, "_New", None, None, self.on_new),
      ("open", gtk.STOCK_OPEN, "_Open", None, None, self.on_open),
      ("save", gtk.STOCK_SAVE, "_Save", None, None, self.on_save),

      ("undo", gtk.STOCK_UNDO, "_Undo", None, None, self.on_action),
      ("redo", gtk.STOCK_REDO, "_Redo", None, None, self.on_action),

      ("cut", gtk.STOCK_CUT, "_Cut", None, None, self.on_action),
      ("copy", gtk.STOCK_COPY, "_Copy", None, None, self.on_action),
      ("paste", gtk.STOCK_PASTE, "_Paste", None, None, self.on_paste),

      ("bold", gtk.STOCK_BOLD, "_Bold", "<ctrl>B", None, self.on_action),
      ("italic", gtk.STOCK_ITALIC, "_Italic", "<ctrl>I", None, self.on_action),
      ("underline", gtk.STOCK_UNDERLINE, "_Underline", "<ctrl>U", None, self.on_action),
      ("strikethrough", gtk.STOCK_STRIKETHROUGH, "_Strike", "<ctrl>T", None, self.on_action),
      ("font", gtk.STOCK_SELECT_FONT, "Select _Font", "<ctrl>F", None, self.on_select_font),
      ("color", gtk.STOCK_SELECT_COLOR, "Select _Color", None, None, self.on_select_color),

      ("justifyleft", gtk.STOCK_JUSTIFY_LEFT, "Justify _Left", None, None, self.on_action),
      ("justifyright", gtk.STOCK_JUSTIFY_RIGHT, "Justify _Right", None, None, self.on_action),
      ("justifycenter", gtk.STOCK_JUSTIFY_CENTER, "Justify _Center", None, None, self.on_action),
      ("justifyfull", gtk.STOCK_JUSTIFY_FILL, "Justify _Full", None, None, self.on_action),

      ("insertimage", "insert-image", "Insert _Image", None, None, self.on_insert_image),
      ("insertlink", "insert-link", "Insert _Link", None, None, self.on_insert_link),
    ])

    actions.get_action("insertimage").set_property("icon-name", "insert-image")
    actions.get_action("insertlink").set_property("icon-name", "insert-link")

    ui = gtk.UIManager()
    ui.insert_action_group(actions)
    ui.add_ui_from_string(ui_def)
    return ui

  def on_action(self, action):
    self.editor.execute_script(
      "document.execCommand('%s', false, false);" % action.get_name())

  def on_paste(self, action):
    self.editor.paste_clipboard()

  def on_new(self, action):
    self.editor.load_html_string("", "file:///")

  def on_select_font(self, action):
    dialog = gtk.FontSelectionDialog("Select a font")
    if dialog.run() == gtk.RESPONSE_OK:
      fname, fsize = dialog.fontsel.get_family().get_name(), dialog.fontsel.get_size()
      self.editor.execute_script("document.execCommand('fontname', null, '%s');" % fname)
      self.editor.execute_script("document.execCommand('fontsize', null, '%s');" % fsize)
    dialog.destroy()

  def on_select_color(self, action):
    dialog = gtk.ColorSelectionDialog("Select Color")
    if dialog.run() == gtk.RESPONSE_OK:
      gc = str(dialog.colorsel.get_current_color())
      color = "#" + "".join([gc[1:3], gc[5:7], gc[9:11]])
      self.editor.execute_script("document.execCommand('forecolor', null, '%s');" % color)
    dialog.destroy()

  def on_insert_link(self, action):
    dialog = gtk.Dialog("Enter a URL:", self, 0,
      (gtk.STOCK_CANCEL, gtk.RESPONSE_CANCEL, gtk.STOCK_OK, gtk.RESPONSE_OK))

    entry = gtk.Entry()
    dialog.vbox.pack_start(entry)
    dialog.show_all()

    if dialog.run() == gtk.RESPONSE_OK:
      self.editor.execute_script(
        "document.execCommand('createLink', true, '%s');" % entry.get_text())
    dialog.destroy()

  def on_insert_image(self, action):
    dialog = gtk.FileChooserDialog("Select an image file", self, gtk.FILE_CHOOSER_ACTION_OPEN,
      (gtk.STOCK_CANCEL, gtk.RESPONSE_CANCEL, gtk.STOCK_OPEN, gtk.RESPONSE_OK))

    if dialog.run() == gtk.RESPONSE_OK:
      fn = dialog.get_filename()
      if os.path.exists(fn):
        self.editor.execute_script(
          "document.execCommand('insertImage', null, '%s');" % fn)
    dialog.destroy()

  def on_open(self, action):
    dialog = gtk.FileChooserDialog("Select an HTML file", self, gtk.FILE_CHOOSER_ACTION_OPEN,
      (gtk.STOCK_CANCEL, gtk.RESPONSE_CANCEL, gtk.STOCK_OPEN, gtk.RESPONSE_OK))

    if dialog.run() == gtk.RESPONSE_OK:
      fn = dialog.get_filename()
      if os.path.exists(fn):
        self.filename = fn
        with open(fn) as fd:
          self.editor.load_html_string(fd.read(), "file:///")
    dialog.destroy()

  def on_save(self, action):
    if self.filename:
      with open(self.filename) as fd: fd.write(self.get_html())
    else:
      dialog = gtk.FileChooserDialog("Select an HTML file", self, gtk.FILE_CHOOSER_ACTION_SAVE,
        (gtk.STOCK_CANCEL, gtk.RESPONSE_CANCEL, gtk.STOCK_SAVE, gtk.RESPONSE_OK))

      if dialog.run() == gtk.RESPONSE_OK:
        self.filename = dialog.get_filename()
        with open(self.filename, "w+") as fd: fd.write(self.get_html())
      dialog.destroy()

  def get_html(self):
    self.editor.execute_script("document.title=document.documentElement.innerHTML;")
    return self.editor.get_main_frame().get_title()

e = ExampleEditor()
e.show_all()
gtk.main()
