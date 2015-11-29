-- Copyright 2007-2015 Mitchell mitchell.att.foicica.com. See LICENSE.

local M = {}

--[[ This comment is for LuaDoc.
---
-- The html module.
-- It provides utilities for editing HTML code.
module('_M.html')]]

-- Load CSS Autocompletion and documentation.
if not _M.css then _M.css = require('css') end

-- Sets default buffer properties for CSS files.
events.connect(events.LEXER_LOADED, function(lang)
  if lang == 'html' then
    buffer.word_chars =
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-'
  end
end)

-- Autocompletion and documentation.

local completion = '%s'..string.char(buffer.auto_c_type_separator)..'%d'
local XPM = textadept.editing.XPM_IMAGES

-- List of HTML tags available for autocompletion.
local tags = {
  'a', 'abbr', 'acronym', 'address', 'applet', 'area', 'article', 'aside',
  'audio', 'b', 'base', 'basefont', 'bdo', 'big', 'blockquote', 'body', 'br',
  'button', 'canvas', 'caption', 'center', 'cite', 'code', 'col', 'colgroup',
  'dd', 'del', 'dfn', 'dir', 'div', 'dl', 'dt', 'em', 'fieldset', 'figcaption',
  'figure', 'font', 'footer', 'form', 'frame', 'frameset', 'h1', 'h2', 'h3',
  'h4', 'h5', 'h6', 'head', 'header', 'hgroup', 'hr', 'html', 'i', 'iframe',
  'img', 'input', 'ins', 'isindex', 'kbd', 'label', 'legend', 'li', 'link',
  'map', 'menu', 'meta', 'nav', 'noframes', 'noscript', 'object', 'ol',
  'optgroup', 'option', 'p', 'param', 'pre', 'q', 's', 'samp', 'script',
  'section', 'select', 'small', 'span', 'strike', 'strong', 'style', 'sub',
  'sup', 'table', 'tbody', 'td', 'textarea', 'tfoot', 'th', 'thead', 'time',
  'title', 'tr', 'tt', 'u', 'ul', 'var', 'video'
}
for i = 1, #tags do tags[i] = completion:format(tags[i], XPM.CLASS) end

-- Map of attribute sets to their attribute lists.
local attr = {
  core = {'class', 'id', 'style', 'title'},
  lang = {'dir', 'lang', 'xml:lang'},
  key = {'accesskey', 'tabindex'},
}
for _, attrs in pairs(attr) do
  for i = 1, #attrs do attrs[i] = completion:format(attrs[i], XPM.SLOT) end
end

-- Map of events to their attribute lists.
local event = {
  form = {'onblur', 'onchange', 'onfocus', 'onreset', 'onselect', 'onsubmit'},
  key = {'onkeydown', 'onkeypress', 'onkeyup'},
  mouse = {
    'onclick', 'ondblclick', 'onmousedown', 'onmousemove', 'onmouseout',
    'onmouseover', 'onmouseup'
  }
}
for _, events in pairs(event) do
  for i = 1, #events do events[i] = completion:format(events[i], XPM.SIGNAL) end
end

-- Map of tags to attributes available for autocompletion.
local attributes = {
  a = {
    'charset', 'coords', 'href', 'hreflang', 'name', 'rel', 'shape', 'target',
    attr.core, attr.lang, attr.key, event.key, event.mouse, event.form
  },
  abbr = {attr.core, attr.lang, event.key, event.mouse},
  acronym = {attr.core, attr.lang, event.key, event.mouse},
  address = {attr.core, attr.lang, event.key, event.mouse},
  applet = {
    'code', 'object', 'align', 'alt', 'archive', 'codebase', 'height', 'hspace',
    'name', 'vspace', 'width', attr.core
  },
  area = {
    'alt', 'coords', 'href', 'nohref', 'shape', 'target', attr.core, attr.lang,
    attr.key, event.key, event.mouse, event.form
  },
  article = {attr.core, attr.lang, event.key, event.mouse},
  aside = {attr.core, attr.lang, event.key, event.mouse},
  audio = {attr.core, attr.lang, event.key, event.mouse},
  b = {attr.core, attr.lang, event.key, event.mouse},
  base = {'href', 'target'},
  basefont = {'color', 'face', 'size', attr.core, attr.lang},
  bdo = {'dir', attr.core, attr.lang},
  big = {attr.core, attr.lang, event.key, event.mouse},
  blockquote = {'cite', attr.core, attr.lang, event.key, event.mouse},
  body = {
    'onload', 'onunload', 'alink', 'background', 'bgcolor', 'link', 'text',
    'vlink'
  },
  br = {attr.core},
  button = {
    'disabled', 'name', 'type', 'value', attr.core, attr.lang, attr.key,
    event.key, event.mouse, event.form
  },
  canvas = {attr.core, attr.lang, event.key, event.mouse},
  caption = {'align', attr.core, attr.lang, event.key, event.mouse},
  center = {attr.core, attr.lang, event.key, event.mouse},
  cite = {attr.core, attr.lang, event.key, event.mouse},
  code = {attr.core, attr.lang, event.key, event.mouse},
  col = {
    'align', 'char', 'charoff', 'span', 'valign', 'width', attr.core, attr.lang,
    event.key, event.mouse
  },
  colgroup = {
    'align', 'char', 'charoff', 'span', 'valign', 'width', attr.core, attr.lang,
    event.key, event.mouse
  },
  dd = {attr.core, attr.lang, event.key, event.mouse},
  del = {attr.core, attr.lang, event.key, event.mouse},
  dfn = {attr.core, attr.lang, event.key, event.mouse},
  dir = {attr.core, attr.lang, event.key, event.mouse},
  div = {attr.core, attr.lang, event.key, event.mouse},
  dl = {attr.core, attr.lang, event.key, event.mouse},
  dt = {attr.core, attr.lang, event.key, event.mouse},
  em = {attr.core, attr.lang, event.key, event.mouse},
  fieldset = {attr.core, attr.lang, event.key, event.mouse},
  figcaption = {attr.core, attr.lang, event.key, event.mouse},
  figure = {attr.core, attr.lang, event.key, event.mouse},
  font = {'color', 'face', 'size', attr.core, attr.lang},
  footer = {attr.core, attr.lang, event.key, event.mouse},
  form = {
    'action', 'accept', 'accept-charset', 'enctype', 'method', 'name', 'target',
    attr.core, attr.lang, event.key, event.mouse
  },
  frame = {
    'frameborder', 'longdesc', 'marginheight', 'marginwidth', 'name',
    'noresize', 'scrolling', 'src', attr.core
  },
  frameset = {'cols', 'rows', attr.core, attr.lang},
  head = {'profile'},
  h1 = {'align', attr.core, attr.lang, event.key, event.mouse},
  h2 = {'align', attr.core, attr.lang, event.key, event.mouse},
  h3 = {'align', attr.core, attr.lang, event.key, event.mouse},
  h4 = {'align', attr.core, attr.lang, event.key, event.mouse},
  h5 = {'align', attr.core, attr.lang, event.key, event.mouse},
  h6 = {'align', attr.core, attr.lang, event.key, event.mouse},
  head = {attr.lang},
  header = {attr.core, attr.lang, event.key, event.mouse},
  hgroup = {attr.core, attr.lang, event.key, event.mouse},
  hr = {'align', 'noshade', 'size', 'width', attr.core},
  html = {'xmlns', attr.lang},
  i = {attr.core, attr.lang, event.key, event.mouse},
  iframe = {
    'align', 'frameborder', 'height', 'longdesc', 'marginheight', 'marginwidth',
    'name', 'scrolling', 'src', 'width', attr.core
  },
  img = {
    'onabort', 'alt', 'src', 'align', 'border', 'height', 'hspace', 'ismap',
    'longdesc', 'usemap', 'vspace', 'width', attr.core, attr.lang, event.key,
    event.mouse
  },
  input = {
    'accept', 'align', 'alt', 'checked', 'disabled', 'maxlength', 'name',
    'readonly', 'size', 'src', 'type', 'value', attr.core, attr.lang, attr.key,
    event.key, event.mouse, event.form
  },
  ins = {'cite', 'datetime', attr.core, attr.lang, event.key, event.mouse},
  isindex = {attr.core, attr.lang, event.key, event.mouse},
  kbd = {attr.core, attr.lang, event.key, event.mouse},
  label = {
    'for', attr.core, attr.lang, attr.key, event.key, event.mouse, event.form
  },
  legend = {'align', attr.core, attr.lang, attr.key, event.key, event.mouse},
  li = {'type', 'value', attr.core, attr.lang, event.key, event.mouse},
  link = {
    'charset', 'href', 'hreflang', 'media', 'rel', 'rev', 'target', 'type',
    attr.core, attr.lang, event.key, event.mouse
  },
  map = {'name', attr.core, attr.lang, event.key, event.mouse},
  menu = {'compact', attr.core, attr.lang, event.key, event.mouse},
  meta = {'content', 'http-equiv', 'name', 'scheme', attr.lang},
  nav = {attr.core, attr.lang, event.key, event.mouse},
  noframes = {attr.core, attr.lang, event.key, event.mouse},
  noscript = {attr.core, attr.lang, event.key, event.mouse},
  object = {
    'align', 'archive', 'border', 'classid', 'codebase', 'codetype', 'data',
    'declare', 'height', 'hspace', 'name', 'standby', 'type', 'usemap',
    'vspace', 'width', attr.core, attr.lang, attr.key, event.key, event.mouse
  },
  ol = {
    'compact', 'start', 'type', attr.core, attr.lang, event.key, event.mouse
  },
  optgroup = {
    'label', 'disabled', attr.core, attr.lang, event.key, event.mouse
  },
  option = {
    'disabled', 'label', 'selected', 'value', attr.core, attr.lang, event.key,
    event.mouse
  },
  p = {'align', attr.core, attr.lang, event.key, event.mouse},
  param = {'name', 'type', 'value', 'valuetype', 'id'},
  pre = {'width', attr.core, attr.lang, event.key, event.mouse},
  q = {'cite', attr.core, attr.lang, event.key, event.mouse},
  s = {attr.core, attr.lang, event.key, event.mouse},
  samp = {attr.core, attr.lang, event.key, event.mouse},
  script = {'type', 'charset', 'defer', 'src', 'xml:space'},
  section = {attr.core, attr.lang, event.key, event.mouse},
  select = {
    'disabled', 'multiple', 'name', 'size', attr.core, attr.lang, attr.key,
    event.key, event.mouse, event.form
  },
  small = {attr.core, attr.lang, event.key, event.mouse},
  span = {attr.core, attr.lang, event.key, event.mouse},
  strike = {attr.core, attr.lang, event.key, event.mouse},
  strong = {attr.core, attr.lang, event.key, event.mouse},
  style = {'type', 'media', attr.core, attr.lang},
  sub = {attr.core, attr.lang, event.key, event.mouse},
  sup = {attr.core, attr.lang, event.key, event.mouse},
  table = {
    'align', 'bgcolor', 'border', 'cellpadding', 'cellspacing', 'frame',
    'rules', 'summary', 'width', attr.core, attr.lang, event.key, event.mouse
  },
  tbody = {
    'align', 'char', 'charoff', 'valign', attr.core, attr.lang, event.key,
    event.mouse
  },
  td = {
    'abbr', 'align', 'axis', 'bgcolor', 'char', 'charoff', 'colspan', 'headers',
    'height', 'nowrap', 'rowspan', 'scope', 'valign', 'width', attr.core,
    attr.lang, event.key, event.mouse
  },
  textarea = {
    'cols', 'rows', 'disabled', 'name', 'readonly', attr.core, attr.lang,
    attr.key, event.key, event.mouse, event.form
  },
  tfoot = {
    'align', 'char', 'charoff', 'valign', attr.core, attr.lang, event.key,
    event.mouse
  },
  th = {
    'abbr', 'align', 'axis', 'bgcolor', 'char', 'charoff', 'colspan', 'height',
    'nowrap', 'rowspan', 'scope', 'valign', 'width', attr.core, attr.lang,
    event.key, event.mouse
  },
  thead = {
    'align', 'char', 'charoff', 'valign', attr.core, attr.lang, event.key,
    event.mouse
  },
  time = {attr.core, attr.lang, event.key, event.mouse},
  title = {attr.lang},
  tr = {
    'align', 'bgcolor', 'char', 'charoff', 'valign', attr.core, attr.lang,
    event.key, event.mouse
  },
  tt = {attr.core, attr.lang, event.key, event.mouse},
  u = {attr.core, attr.lang, event.key, event.mouse},
  ul = {'compact', 'type', attr.core, attr.lang, event.key, event.mouse},
  var = {attr.core, attr.lang, event.key, event.mouse},
  video = {attr.core, attr.lang, event.key, event.mouse},
}
for _, attrs in pairs(attributes) do
  for i = 1, #attrs do
    if type(attrs[i]) == 'string' then
      attrs[i] = completion:format(attrs[i], XPM.METHOD)
    end
  end
end

textadept.editing.autocompleters.html = function()
  local list = {}
  -- Retrieve the symbol behind the caret and determine whether it is a tag or
  -- a tag attribute.
  local line, pos = buffer:get_cur_line()
  line = line:sub(1, pos)
  if line:find('>[^<]*$') then return nil end -- outside tag
  if line:find('<([%w:]*)$') then
    -- Autocomplete tag.
    local part = line:match('<([%w:]*)$')
    local name = '^'..part
    for i = 1, #tags do
      if tags[i]:find(name) then list[#list + 1] = tags[i] end
    end
    return #part, list
  else
    -- Autocomplete attribute.
    local symbol, part = line:match('<([%w:]+)[^<>]-([%w:]*)$')
    if not symbol and not part then
      -- Look back for an open tag.
      for i = buffer:line_from_position(buffer.current_pos) - 1, 0, -1 do
        local line = buffer:get_line(i)
        if line:find('>[^<]*$') then break end
        symbol = line:match('<(%w+)[^>]*$')
        if symbol then break end
      end
      if not symbol then return nil end
      part = line:match('([%w:]*)$')
    end
    local name, attrs = '^'..part, attributes[symbol]
    if attrs then
      for i = 1, #attrs do
        local attr = attrs[i]
        if type(attr) == 'string' then
          if attr:find(name) then list[#list + 1] = attr end
        else
          for j = 1, #attr do
            if attr[j]:find(name) then list[#list + 1] = attr[j] end
          end
        end
      end
    end
    return #part, list
  end
end

textadept.editing.api_files.html = {_HOME..'/modules/html/api'}

-- Commands.

---
-- Container for HTML-specific key bindings.
-- @class table
-- @name _G.keys.html
keys.html = {}

-- Snippets.

if type(snippets) == 'table' then
---
-- Container for HTML-specific snippets.
-- @class table
-- @name _G.snippets.html
  snippets.html = {
    c = '<!-- %0 -->',
    ['<'] = '<%1(div)>\n\t%0\n</%1>',
    divc = '<div class="%1">\n\t%0\n</div>',
    divi = '<div id="%1">\n\t%0\n</div>',
    br = '<br />\n%0',
    table = '<table class="%1">\n\t<tr>\n\t\t<th>%0</th>\n\t</tr>\n</table>',
    td = '<td>%0</td>',
    tr = '<tr>\n\t%0\n</tr>',
    ulc = '<ul class="%1(list)">\n\t%0\n</ul>',
    ul = '<ul>\n\t%0\n</ul>',
    li = '<li>%0</li>',
  }
end

return M
