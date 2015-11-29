-- Copyright 2007-2015 Mitchell mitchell.att.foicica.com. See LICENSE.

local M = {}

--[[ This comment is for LuaDoc.
---
-- The css module.
-- It provides utilities for editing CSS code.
module('_M.css')]]

-- Sets default buffer properties for CSS files.
events.connect(events.LEXER_LOADED, function(lang)
  if lang == 'css' then
    buffer.word_chars =
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-'
  end
end)

-- Autocompletion and documentation.

local completion = '%s'..string.char(buffer.auto_c_type_separator)..'%d'
local XPM = textadept.editing.XPM_IMAGES

-- List of selectors available for autocompletion.
local selectors = {
  'a', 'abbr', 'acronym', 'address', 'area', 'b', 'base', 'big', 'blockquote',
  'body', 'br', 'button', 'caption', 'cite', 'code', 'col', 'colgroup', 'dd',
  'del', 'dfn', 'div', 'dl', 'dt', 'em', 'fieldset', 'form', 'frame',
  'frameset', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'head', 'hr', 'html', 'i',
  'iframe', 'img', 'input', 'ins', 'kbd', 'label', 'legend', 'li', 'link',
  'map', 'meta', 'noframes', 'noscript', 'object', 'ol', 'optgroup', 'option',
  'p', 'param', 'pre', 'q', 'samp', 'script', 'select', 'small', 'span',
  'strike', 'strong', 'style', 'sub', 'sup', 'table', 'tbody', 'td', 'textarea',
  'tfoot', 'th', 'thead', 'title', 'tr', 'tt', 'ul', 'var'
}
for i = 1, #selectors do
  selectors[i] = completion:format(selectors[i], XPM.CLASS)
end

-- List of properties available for autocompletion.
local properties = {
  'azimuth', 'background', 'background-attachment', 'background-color',
  'background-image', 'background-position', 'background-repeat', 'border',
  'border-bottom', 'border-bottom-color', 'border-bottom-style',
  'border-bottom-width', 'border-collapse', 'border-color', 'border-left',
  'border-left-color', 'border-left-style', 'border-left-width', 'border-right',
  'border-right-color', 'border-right-style', 'border-right-width',
  'border-spacing', 'border-style', 'border-top', 'border-top-color',
  'border-top-style', 'border-top-width', 'border-width', 'bottom',
  'caption-side', 'clear', 'clip', 'color', 'content', 'counter-increment',
  'counter-reset', 'cue', 'cue-after', 'cue-before', 'cursor', 'direction',
  'display', 'elevation', 'empty-cells', 'float', 'font', 'font-family',
  'font-size', 'font-size-adjust', 'font-stretch', 'font-style', 'font-variant',
  'font-weight', 'height', 'left', 'letter-spacing', 'line-height',
  'list-style', 'list-style-image', 'list-style-position', 'list-style-type',
  'margin', 'margin-bottom', 'margin-left', 'margin-right', 'margin-top',
  'max-height', 'max-width', 'min-height', 'min-width', 'opacity', 'orphans',
  'outline', 'outline-color', 'outline-style', 'outline-width', 'overflow',
  'padding', 'padding-bottom', 'padding-left', 'padding-right', 'padding-top',
  'page-break-after', 'page-break-before', 'page-break-inside', 'pause',
  'pause-after', 'pause-before', 'pitch', 'pitch-range', 'play-during',
  'position', 'quotes', 'richness', 'right', 'speak', 'speak-header',
  'speak-numeral', 'speak-punctuation', 'speech-rate', 'stress', 'table-layout',
  'text-align', 'text-decoration', 'text-indent', 'text-shadow',
  'text-transform', 'top', 'unicode-bidi', 'vertical', 'vertical-align',
  'visibility', 'voice-family', 'volume', 'white-space', 'widows', 'width',
  'word-spacing', 'z-index'
}
for i = 1, #properties do
  properties[i] = completion:format(properties[i], XPM.METHOD)
end

-- List of pseudoclasses available for autocompletion.
local pseudoclasses = {
  'active', 'first-child', 'focus', 'hover', 'lang', 'link', 'visited',
}
for i = 1, #pseudoclasses do
  pseudoclasses[i] = completion:format(pseudoclasses[i], XPM.SIGNAL)
end

-- List of pseudoelements available for autocompletion.
local pseudoelements = {'after', 'before', 'first-letter', 'first-line'}
for i = 1, #pseudoelements do
  pseudoelements[i] = completion:format(pseudoelements[i], XPM.SLOT)
end

-- List of media types available for autocompletion.
local medias = {
  'all', 'aural', 'braille', 'embossed', 'handheld', 'print', 'projection',
  'screen', 'tty', 'tv'
}
for i = 1, #medias do medias[i] = completion:format(medias[i], XPM.TYPEDEF) end

-- Map of properties to their value lists.
-- Most of the properties that are commented out are defined later, and in terms
-- of other properties. For example, "border" is defined in terms of
-- "border-color", "border-style", and "border-width".
local values = {
  azimuth = {
    'left-side', 'far-left', 'left', 'center-left', 'center', 'center-right',
    'right', 'far-right', 'right-side', 'behind', 'leftwards', 'rightwards'
  },
  --background =
  ['background-attachment'] = {'fixed', 'scroll'},
  ['background-color'] = {'transparent', 'rgb('},
  ['background-image'] = {'url(', 'none'},
  ['background-position'] = {'left', 'top', 'center', 'bottom', 'right'},
  ['background-repeat'] = {'repeat', 'repeat-x', 'repeat-y', 'no-repeat'},
  --border =
  --['border-bottom'] =
  --['border-bottom-color'] =
  --['border-bottom-style'] =
  --['border-bottom-width'] =
  ['border-collapse'] = {'collapse', 'separate'},
  ['border-color'] = {'transparent', 'rgb('},
  --['border-left'] =
  --['border-left-color'] =
  --['border-left-style'] =
  --['border-left-width'] =
  --['border-right'] =
  --['border-right-color'] =
  --['border-right-style'] =
  --['border-right-width'] =
  --['border-spacing'] = nil,
  ['border-style'] = {
    'none', 'hidden', 'dotted', 'dashed', 'solid', 'double', 'groove', 'ridge',
    'inset', 'outset'
  },
  --['border-top'] =
  --['border-top-color'] =
  --['border-top-style'] =
  --['border-top-width'] =
  ['border-width'] = {'thin', 'medium', 'thick'},
  bottom = {'auto'},
  ['caption-side'] = {'top', 'bottom'},
  clear = {'left', 'right', 'both', 'none'},
  clip = {'auto', 'rect('},
  color = {'rgb('},
  content = {
    'none', 'normal', 'counter', 'attr(', 'open-quote', 'close-quote',
    'no-open-quote', 'no-close-quote', 'url('
  },
  ['counter-increment'] = {'none'},
  ['counter-reset'] = {'none'},
  cue = {'none', 'url('},
  --['cue-after'] =
  --['cue-before'] =
  cursor = {
    'url(', 'auto', 'crosshair', 'default', 'pointer', 'move', 'e-resize',
    'ne-resize', 'nw-resize', 'n-resize', 'se-resize', 'sw-resize', 's-resize',
    'w-resize', 'text', 'wait', 'help', 'progress'
  },
  direction = {'ltr', 'rtl'},
  display = {
    'none', 'block', 'inline', 'inline-block', 'inline-table', 'list-item',
    'run-in', 'table', 'table-caption', 'table-cell', 'table-column',
    'table-column-group', 'table-footer-group', 'table-header-group',
    'table-row', 'table-row-group'
  },
  elevation = {'below', 'level', 'above', 'higher', 'lower'},
  ['empty-cells'] = {'hide', 'show'},
  float = {'left', 'right', 'none'},
  font = { -- font-family, font-size, etc. added later
    'caption', 'icon', 'menu', 'message-box', 'small-caption', 'status-bar'
  },
  ['font-family'] = {'sans-serif', 'serif', 'monospace', 'cursive', 'fantasy'},
  ['font-size'] = {
    'xx-small', 'x-small', 'small', 'medium', 'large', 'x-large', 'xx-large',
    'smaller', 'larger'
  },
  ['font-size-adjust'] = {'none'},
  --['font-stretch'] = nil,
  ['font-style'] = {'normal', 'italic', 'oblique'},
  ['font-variant'] = {'normal', 'small-caps'},
  ['font-weight'] = {
    'normal', 'bold', 'bolder', 'lighter', '100', '200', '300', '400', '500',
    '600', '700', '800', '900',
  },
  height = {'auto'},
  left = {'auto'},
  ['letter-spacing'] = {'normal'},
  ['line-height'] = {'normal'},
  --['list-style'] = nil,
  ['list-style-image'] = {'url(', 'none'},
  ['list-style-position'] = {'inside', 'outside'},
  ['list-style-type'] = {
    'none', 'disc', 'circle', 'square', 'decimal', 'decimal-leading-zero',
    'armenian', 'georgian', 'lower-alpha', 'lower-greek', 'lower-latin',
    'upper-latin', 'lower-roman', 'upper-roman'
  },
  margin = {'auto'},
  ['margin-bottom'] = {'auto'},
  ['margin-left'] = {'auto'},
  ['margin-right'] = {'auto'},
  ['margin-top'] = {'auto'},
  ['max-height'] = {'auto'},
  ['max-width'] = {'none'},
  ['min-height'] = {'none'},
  ['min-width'] = {'none'},
  --opacity = nil,
  --orphans = nil,
  --outline =
  ['outline-color'] = {'invert', 'rgb('},
  ['outline-style'] = {
    'none', 'dotted', 'dashed', 'solid', 'double', 'groove', 'ridge', 'inset',
    'outset'
  },
  ['outline-width'] = {'thin', 'medium', 'thick'},
  overflow = {'auto', 'hidden', 'scroll', 'visible'},
  --padding = nil,
  --['padding-bottom'] = nil,
  --['padding-left'] = nil,
  --['padding-right'] = nil,
  --['padding-top'] = nil,
  ['page-break-after'] = {'auto', 'always', 'avoid', 'left', 'right'},
  --['page-break-before'] =
  ['page-break-inside'] = {'auto', 'avoid'},
  --pause = nil,
  --['pause-after'] = nil,
  --['pause-before'] = nil,
  pitch = {'x-low', 'low', 'medium', 'high', 'x-high'},
  --['pitch-range'] = nil,
  ['play-during'] = {'url(', 'mix', 'repeat', 'auto', 'none'},
  position = {'absolute', 'fixed', 'relative', 'static'},
  quotes = {'none'},
  --richness = nil,
  right = {'auto'},
  speak = {'normal', 'none', 'spell-out'},
  ['speak-header'] = {'always', 'once'},
  ['speak-numeral'] = {'digits', 'continuous'},
  ['speak-punctuation'] = {'code', 'none'},
  ['speech-rate'] = {
    'x-slow', 'slow', 'medium', 'fast', 'x-fast', 'faster', 'slower'
  },
  --stress = nil,
  ['table-layout'] = {'auto', 'fixed'},
  ['text-align'] = {'left', 'right', 'center', 'justify'},
  ['text-decoration'] = {
    'none', 'underline', 'overline', 'line-through', 'blink'
  },
  --['text-indent'] = nil,
  ['text-shadow'] = {'none'},
  ['text-transform'] = {'none', 'capitalize', 'uppercase', 'lowercase'},
  top = {'auto'},
  ['unicode-bidi'] = {'normal', 'embed', 'bidi-override'},
  ['vertical-align'] = {
    'baseline', 'sub', 'super', 'top', 'text-top', 'middle', 'bottom',
    'text-bottom'
  },
  visibility = {'visible', 'hidden', 'collapse'},
  --['voice-family'] = nil,
  volume = {'silent', 'x-soft', 'soft', 'medium', 'loud', 'x-loud'},
  ['white-space'] = {'normal', 'pre', 'nowrap', 'pre-wrap', 'pre-line'},
  --widows = nil,
  width = {'auto'},
  ['word-spacing'] = {'normal'},
  ['z-index'] = {'auto'}
}
for _, values in pairs(values) do
  for i = 1, #values do
    values[i] = completion:format(values[i], XPM.VARIABLE)
  end
end
local initial = completion:format('initial', XPM.VARIABLE)
local inherit = completion:format('inherit', XPM.VARIABLE)
-- Define some properties in terms of others.
values.background = {}
for _, kind in ipairs{'attachment', 'color', 'image', 'position', 'repeat'} do
  values.background[#values.background + 1] = values['background-'..kind]
end
values.border = {
  values['border-color'], values['border-style'], values['border-width']
}
for _, direction in ipairs{'bottom', 'left', 'right', 'top'} do
  values['border-'..direction] = values.border
  values['border-'..direction..'-color'] = values['border-color']
  values['border-'..direction..'-style'] = values['border-style']
  values['border-'..direction..'-width'] = values['border-width']
end
values['cue-after'], values['cue-before'] = values.cue, values.cue
for _, kind in ipairs{'family', 'size', 'style', 'variant', 'weight'} do
  values.font[#values.font + 1] = values['font-'..kind]
end
values.outline = {
  values['outline-color'], values['outline-style'], values['outline-width']
}
values['page-break-before'] = values['page-break-after']

textadept.editing.autocompleters.css = function()
  local list = {}
  -- Retrieve the symbol behind the caret and determine whether it is a
  -- selector, property, media type, etc.
  local line, pos = buffer:get_cur_line()
  line = line:sub(1, pos)
  local symbol, op, part = line:match('([%w-]-)(:?:?)%s*([%w-]*)$')
  if symbol == '' and part == '' and op ~= '' then return nil end -- lone :, ::
  local name = '^'..part
  local in_selector = line:find('{[^}]*$')
  local completions
  if not line:find('@media[^{]*$') then
    -- Autocomplete selector, pseudoclass, pseudoelement, property, or value,
    -- depending on context.
    if not in_selector then
      for i = buffer:line_from_position(buffer.current_pos) - 1, 0, -1 do
        local line = buffer:get_line(i)
        if line:find('{[^}]*$') then in_selector = true break end
        if line:find('}[^{]*$') then break end -- not in selector
      end
    end
    if not in_selector then
      if op == '' then
        completions = selectors -- autocomplete selector name
      elseif op == ':' then
        completions = pseudoclasses -- autocomplete pseudoclass
      else
        completions = pseudoelements -- autocomplete pseudoelement
      end
    else
      if symbol == '' then
        completions = properties -- autocomplete property
      elseif op == ':' then
        completions = values[symbol] -- autocomplete value.
        if not completions then return nil end
      else
        return nil
      end
    end
  else
    completions = medias -- autocomplete media type
  end
  -- Extract potential completions.
  for i = 1, #completions do
    local completion = completions[i]
    if type(completion) == 'string' then
      if completion:find(name) then list[#list + 1] = completion end
    else
      for j = 1, #completion do
        if completion[j]:find(name) then list[#list + 1] = completion[j] end
      end
    end
  end
  -- Include the omnipresent "initial" and "inherit" values, if applicable.
  if in_selector and symbol ~= '' then
    if initial:find(name) then list[#list + 1] = initial end
    if inherit:find(name) then list[#list + 1] = inherit end
  end
  return #part, list
end

textadept.editing.api_files.css = {_HOME..'/modules/css/api'}

-- Commands.

---
-- Container for CSS-specific key bindings.
-- @class table
-- @name _G.keys.css
keys.css = {}

-- Snippets.

if type(snippets) == 'table' then
---
-- Container for CSS-specific snippets.
-- @class table
-- @name _G.snippets.css
  snippets.css = {

  }
end

return M
