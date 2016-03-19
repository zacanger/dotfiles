atom.commands.add 'atom-workspace', 'dot-atom:close-all-panes', ->
  atom.workspace.getPanes().forEach (pane) ->
    pane.destroy()

atom.commands.add('atom-workspace', 'custom:make-active-editor-readonly', () =>
  editor = atom.workspace.getActiveTextEditor()
  editor.onDidChange(() =>
    atom.commands.dispatch(atom.views.getView(editor), 'core:undo')
  )
)

atom.commands.add 'atom-workspace', 'dot-atom:save-all', ->
  atom.workspace.getPanes().forEach (pane) ->
    pane.saveItem(item) for item in pane.getItems()

SymbolRegex = /\s*[(){}<>[\]/'"]/
atom.commands.add 'atom-text-editor', 'custom:jump-over-symbol': (event) ->
  editor = atom.workspace.getActiveTextEditor()
  cursorMoved = false
  for cursor in editor.getCursors()
    range = cursor.getCurrentWordBufferRange(wordRegex: SymbolRegex)
    unless range.isEmpty()
      cursor.setBufferPosition(range.end)
      cursorMoved = true
  event.abortKeyBinding() unless cursorMoved

atom.packages.onDidActivatePackage (pack) ->
  if pack.name == 'ex-mode'
    Ex = pack.mainModule.provideEx()
    Ex.registerAlias 'W', 'w'
    Ex.registerAlias 'Wq', 'wq'
    Ex.registerAlias 'WQ', 'wq'
    Ex.registerAlias 'wQ', 'wq'
    Ex.registerAlias 'Q', 'q'

