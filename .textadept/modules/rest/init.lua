-- Copyright 2007-2015 Mitchell mitchell.att.foicica.com. See LICENSE.

local M = {}

--[[ This comment is for LuaDoc.
---
-- The reST module.
-- It provides utilities for editing reST and Sphinx documents.
--
-- ## Key Bindings
--
-- + `Ctrl+Alt+J` (`^⌘J` | `M-S-J`)
--   Jump to the selected section.
-- + `Shift+Enter` (`⇧↩` | `S-Enter`)
--   Open the image specified by the directive on the current line.
--
-- @field DOCUTILS_PATH (string)
--   The absolute path to the directory that contains the Python [Docutils][]
--   library if it is not in the environment's `PYTHONPATH`.
--   The default value is `nil`, which indicates Docutils is installed.
--
--   [Docutils]: http://docutils.sourceforge.net/
module('_M.rest')]]

M.DOCUTILS_PATH = nil

-- Autocompletion and documentation.

local sep = string.char(buffer.auto_c_type_separator)
local XPM = textadept.editing.XPM_IMAGES

local dirs = {
  'admonition', 'attention', 'caution', 'citations', 'class', 'code',
  'compound', 'container', 'contents', 'csv-table', 'danger', 'date',
  'default-role', 'epigraph', 'error', 'figure', 'footer', 'footnotes',
  'header', 'highlights', 'hint', 'image', 'important', 'include', 'line-block',
  'list-table', 'math', 'meta', 'note', 'parsed-literal', 'pull-quote', 'raw',
  'replace', 'restructuredtext-test-directive', 'role', 'rubric',
  'section-autonumbering', 'sectnum', 'sidebar', 'table', 'target-notes', 'tip',
  'title', 'topic', 'unicode', 'warning',
}
for i = 1, #dirs do
  dirs[i] = ("%s::%s%d"):format(dirs[i], sep, XPM.METHOD)
end

local sphinx_dirs = {
  'centered', 'code-block', 'deprecated', 'glossary', 'highlight', 'hlist',
  'index', 'literalinclude', 'note', 'only', 'productionlist', 'rubric',
  'sectionauthor', 'seealso', 'tabularcolumns', 'toctree', 'versionadded',
  'versionchanged', 'warning',
}
for i = 1, #sphinx_dirs do
  dirs[#dirs + 1] = ("%s::%s%d"):format(sphinx_dirs[i], sep, XPM.SLOT)
end

local options = {
  image = {'alt', 'height', 'width', 'scale', 'align', 'target'},
  figure = {
    'alt', 'height', 'width', 'scale', 'align', 'target', 'figwidth', 'figclass'
  },
  sidebar = {'subtitle'}, code = {'number-lines'},
  ['csv-table'] = {
    'widths', 'header-rows', 'stub-columns', 'header', 'file', 'url',
    'encoding', 'delim', 'quote', 'keepspace', 'escape'
  },
  ['list-table'] = {'widths', 'header-rows', 'stub-columns'},
  contents = {'depth', 'local', 'backlinks'},
  sectnum = {'depth', 'prefix', 'suffix', 'start'},
  ['section-autonumbering'] = {'depth', 'prefix', 'suffix', 'start'},
  unicode = {'ltrim', 'rtrim', 'trim'},
  include = {
    'start-line', 'end-line', 'start-after', 'end-before', 'literal', 'code',
    'number-lines', 'encoding', 'tab-width'
  },
  raw = {'file', 'url', 'encoding'}, role = {'class'},
  toctree = {
    'maxdepth', 'numbered', 'titlesonly', 'glob', 'hidden', 'includehidden'
  },
  hlist = {'columns'}, glossary = {'sorted'}, highlight = {'linenothreshold'},
  ['code-block'] = {'linenos', 'emphasize-lines'},
  sourcecode = {'linenos', 'emphasize-lines'},
  ['literal-include'] = {
    'tab-width', 'linenos', 'emphasize-lines', 'language', 'encoding',
    'pyobject', 'lines', 'start-after', 'end-before', 'prepend', 'append'
  },
}
for _, v in pairs(options) do
  v[#v + 1], v[#v + 2] = 'name', 'class' -- global options
  for i = 1, #v do v[i] = ("%s:%s%d"):format(v[i], sep, XPM.VARIABLE) end
end

local roles = {
  'emphasis', 'literal', 'code', 'math', 'pep-reference', 'PEP',
  'rfc-reference', 'RFC', 'string', 'subscript', 'sub', 'superscript', 'sup',
  'title-reference', 'title', 't', 'raw'
}
for i = 1, #roles do
  roles[i] = ("%s:%s%d"):format(roles[i], sep, XPM.METHOD)
end

local sphinx_roles = {
  'ref', 'doc', 'download', 'envvar', 'token', 'keyword', 'option', 'term',
  'abbr', 'command', 'dfn', 'file', 'guilabel', 'kbd', 'mailheader', 'makevar',
  'manpage', 'menuselection', 'mimetype', 'newsgroup', 'program', 'regexp',
  'samp', 'index', 'pep', 'rfc'
}
for i = 1, #sphinx_roles do
  roles[#roles + 1] = ("%s:%s%d"):format(sphinx_roles[i], sep, XPM.SLOT)
end

textadept.editing.autocompleters.rest = function()
  local list = {}
  -- Retrieve the symbol behind the caret.
  local line, pos = buffer:get_cur_line()
  local line_part = line:sub(1, pos)
  local part = line_part:match('[%w-]*$')
  local name = '^'..part
  -- Determine whether or not the symbol is a directive, parameter, or role, and
  -- autocomplete as appropriate.
  if line_part:find('^%s*%.%. [%w-]*$') then
    -- Autocomplete directive.
    for i = 1, #dirs do
      if dirs[i]:find(name) then list[#list + 1] = dirs[i] end
    end
  elseif line_part:find('^%s*:[%w-]*$') then
    -- Autocomplete parameter or role.
    for i = buffer:line_from_position(buffer.current_pos) - 1, 0, -1 do
      line = buffer:get_line(i)
      local dir_options = options[line:match('^%s*%.%. ([%w-]+)::[ \r\n]')]
      if dir_options then
        -- Autocomplete parameter.
        for i = 1, #dir_options do
          if dir_options[i]:find(name) then list[#list + 1] = dir_options[i] end
        end
        break
      end
      if not line:find('^%s*:') then
        -- Autocomplete role.
        for i = 1, #roles do
          if roles[i]:find(name) then list[#list + 1] = roles[i] end
        end
        break
      end
    end
  elseif line_part:find('%s+:[%w-]*$') then
    -- Autocomplete role.
    for i = 1, #roles do
      if roles[i]:find(name) then list[#list + 1] = roles[i] end
    end
  end
  return #part, list
end

textadept.editing.api_files.rest = {_HOME..'/modules/rest/api'}

-- Commands.

-- Add '`' to autopaired and typeover characters.
textadept.editing.char_matches.rest = {
  [40] = ')', [91] = ']', [123] = '}', [39] = "'", [34] = '"', [96] = '`'
}
textadept.editing.typeover_chars = {
  [41] = 1, [93] = 1, [125] = 1, [39] = 1, [34] = 1, [96] = 1
}

-- Enable folding by the Sphinx convention for detected Sphinx files:
-- # > * > = > - > ^ > ".
events.connect(events.LEXER_LOADED, function(lexer)
  if lexer == 'rest' and buffer:get_line(0):find('^%s*%.%. .-sphinx') then
    buffer.property['fold.by.sphinx.convention'] = '1'
    buffer:colourise(0, buffer.end_styled)
  end
end)

local cmd = 'python "'.._HOME..'/modules/rest/rst2pseudoxml.py" '..
            '--report=2 --halt=5 "%s"'
-- Show syntax errors as annotations.
events.connect(events.FILE_AFTER_SAVE, function()
  if buffer:get_lexer() ~= 'rest' then return end
  buffer:annotation_clear_all()
  buffer.annotation_visible = buffer.ANNOTATION_BOXED
  local jumped = false
  local filename = buffer.filename:iconv(_CHARSET, 'UTF-8')
  spawn(cmd:format(filename), M.DOCUTILS_PATH, nil, function(chunk)
    for line in chunk:gmatch('[^\r\n]+') do
      local line_num, msg = line:match('^[^:]+:(%d+):%s*(.+)$')
      if line_num and msg and
         (msg:find('WARNING') or msg:find('ERROR') or msg:find('SEVERE')) then
        if msg:find('Unknown interpreted text role') then
          -- Ignore role errors when it comes to Sphinx roles.
          -- TODO: determine if the document is Sphinx or not?
          for i = 1, #sphinx_roles do
            if msg:find('"'..sphinx_roles[i]..'"') then goto continue end
          end
        end
        buffer.annotation_text[line_num - 1] = msg
        buffer.annotation_style[line_num - 1] = 8 -- error style number
        if not jumped then
          buffer:goto_line(line_num - 1)
          jumped = true
        end
        ::continue::
      end
    end
  end)
end)

---
-- Prompts the user to select a section title to jump to.
-- Requires the entire document to be styled.
-- @name goto_section
function M.goto_section()
  if buffer.end_styled < buffer.length - 1 then
    buffer:colourise(0, buffer.length - 1)
  end
  local items = {}
  for i = 0, buffer.line_count - 2 do
    if bit32.band(buffer.fold_level[i + 1], buffer.FOLDLEVELHEADERFLAG) > 0 then
      local name = buffer:get_line(i + 1):match('^.')..
                   buffer:get_line(i):match('^[^\r\n]*')
      if name then items[#items + 1], items[#items + 2] = i + 1, name end
    end
  end
  local button, i = ui.dialogs.filteredlist{
    title = 'Goto Section', columns = {'Line', 'Name'}, items = items,
    search_column = 2, string_output = true
  }
  if button ~= _L['_OK'] then return end
  textadept.editing.goto_line(tonumber(i))
end

---
-- Opens the image specified in an "image" or "figure" directive on the current
-- line.
-- @name open_image
function M.open_image()
  local line = buffer:get_cur_line()
  local file = line:match('^%s*%.%. image::%s+(%S+)') or
               line:match('^%s*%.%. figure::%s+(%S+)')
  if not file or not buffer.filename then return end
  local cmd = 'xdg-open "%s"'
  if WIN32 then
    cmd = 'start "" "%s"'
  elseif OSX then
    cmd = 'open "file://%s"'
  end
  spawn(cmd:format(buffer.filename:match('^.+[/\\]')..file))
end

---
-- Container for reST-specific key bindings.
-- @class table
-- @name _G.keys.rest
keys.rest = {
  [not OSX and 'cag' or 'cmg'] = M.goto_section,
  ['s\n'] = M.open_image,
}

-- Snippets.

if type(snippets) == 'table' then
---
-- Container for reST-specific snippets.
-- @class table
-- @name _G.snippets.rest
  snippets.rest = {
    attention = [[
.. attention::
   %0
]],
    danger = [[
.. danger::
   %0
]],
    error = [[
.. error::
   %0
]],
    hint = [[
.. hint::
   %0
]],
    important = [[
.. important::
   %0
]],
    note = [[
.. note::
   %0
]],
    tip = [[
.. tip::
   %0
]],
    warning = [[
.. warning::
   %0
]],
    admonition = [[
.. admonition:: %1(title)
   %0
]],
    image = [[
.. image:: %1(picture.jpg)
   :height: %2(100px)
   :width: %3(200px)
   :scale: %4(50%%)
   :alt: %5(alternate text)
   :align: %6(right)
]],

    figure = [[
.. figure:: %1(picture.jpg)
   :height: %2(100px)
   :width: %3(200px)
   :scale: %4(50%%)
   :alt: %5(alternate text)
   :align: %6(right)
   :figwidth: %7(figure width)
   :figclass: %8(figure class)

   %9(caption)

   %10(legend)

]],

    codeblock = [[
.. code-block:: %1(language)
   %2(:linenos:

   )%0
]],
    footnote = [[[#f%1(number)]_


.. rubric:: %2(Footnotes)

.. [#f1] Text of the first footnote.
.. [#f2] Text of the second footnote.

]],

    replace = [[
.. |%1(name)| replace:: %2(replacement *text*)

]],

    repeatingimage = [[
.. |%1(caution)| image:: %2(warning.png)
   :height: %3(100px)
   :width: %4(200px)
   :scale: %5(50%%)
   :alt: %6(warning)
   :align: %7(right)
]],

    comment = ".. %0",

    anchor = [[
.. _`%1(anchor)`: ]],

    reference = [[:ref:`%1(anchor)`]],

    emphasis = [[*%1(text)*]],
    strong_emphasis = [[**%1(text)**]],
    code = [[``%1(text)``]],
    external_link_together = [[`%1(link text) <%2(http://example.com/)>`_]],
    external_link_separated = [[`%1(link text)`_

.. _`%1`: %2(http://example.com/)]],
  }
end

return M
