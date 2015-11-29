-- Copyright 2015 Mitchell mitchell.att.foicica.com. See LICENSE.

local M = {}

--[[ This comment is for LuaDoc.
---
-- Spell checking for Textadept.
-- Any dictionaries placed in `~/.textadept/dictionaries/` are loaded
-- automatically. The first line in a dictionary file contains the approximate
-- number of words contained within. Each subsequent line contains a word.
-- @field CHECK_SPELLING (bool)
--   Check spelling after saving files.
--   The default value is `true`.
-- @field INDIC_SPELLING (number)
--   The spelling error indicator number.
-- @field spellchecker (userdata)
--   The Hunspell spellchecker object.
module('textadept.spellcheck')]]

M.CHECK_SPELLING = true
M.INDIC_SPELLING = _SCINTILLA.next_indic_number()

-- Localizations.
local _L = _L
if _L['Spe_lling']:find('^No Localization') then
  -- Menu.
  _L['Spe_lling'] = 'Spe_lling'
  _L['_Check Spelling...'] = '_Check Spelling...'
  _L['_Mark Misspelled Words'] = '_Mark Misspelled Words'
  _L['_Open User Dictionary'] = '_Open User Dictionary'
  -- Other.
  _L['No Suggestions'] = 'No Suggestions'
  _L['Add'] = 'Add'
  _L['Ignore'] = 'Ignore'
  _L['No misspelled words.'] = 'No misspelled words.'
end

local lib = 'spellcheck.spell'
if WIN32 then
  if jit then lib = lib..'jit' end
elseif OSX then
  lib = lib..'osx'
else
  local p = io.popen('uname -i')
  if p:read('*a'):find('64') then lib = lib..'64' end
  p:close()
end
M.spell = require(lib)

if jit then bit32.btest = function(...) return bit32.band(...) > 0 end end

---
-- Table of spellcheck-able style names.
-- Text with either of these styles is eligible for spellchecking.
-- The style name keys are assigned non-`nil` values. The default styles are
-- `default`, `comment`, and `string`.
-- @class table
-- @name spellcheckable_styles
M.spellcheckable_styles = {default = true, comment = true, string = true}

local SPELLING_ID = _SCINTILLA.next_user_list_type()

local hunspell_paths = {
  '/usr/share/hunspell/', '/usr/local/share/hunspell/',
  'C:\\Program Files (x86)\\hunspell\\', 'C:\\Program Files\\hunspell\\',
  _USERHOME..'/modules/spellcheck/' -- default
}
local lang = (os.getenv('LANG') or ''):match('^[^.@]+') or 'en_US'
local aff, dic = lang..'.aff', lang..'.dic'
for i = 1, #hunspell_paths do
  local aff_path, dic_path = hunspell_paths[i]..aff, hunspell_paths[i]..dic
  if lfs.attributes(aff_path) and lfs.attributes(dic_path) then
    M.spellchecker = M.spell(aff_path, dic_path)
    break
  end
end
local user_dicts = _USERHOME..(not WIN32 and '/' or '\\')..'dictionaries'
if lfs.attributes(user_dicts) then
  for dic in lfs.dir(user_dicts) do
    if not dic:find('^%.%.?$') then
      M.spellchecker:add_dic(user_dicts..(not WIN32 and '/' or '\\')..dic)
    end
  end
end

-- Shows suggestions for string *word* at the current position.
-- @param word The word to show suggestions for.
local function show_suggestions(word)
  local suggestions = M.spellchecker:suggest(word)
  if #suggestions == 0 then suggestions[1] = '('.._L['No Suggestions']..')' end
  suggestions[#suggestions + 1] = '('.._L['Add']..')'
  suggestions[#suggestions + 1] = '('.._L['Ignore']..')'
  local separator = buffer.auto_c_separator
  buffer.auto_c_separator = string.byte('\n')
  buffer:user_list_show(SPELLING_ID, table.concat(suggestions, '\n'))
  buffer.auto_c_separator = separator
end
-- Either correct the misspelled word, add it to the user's dictionary, or
-- ignore it (based on the selected item).
events.connect(events.USER_LIST_SELECTION, function(id, text, position)
  if id ~= SPELLING_ID then return end
  local s = buffer:indicator_start(M.INDIC_SPELLING, position)
  local e = buffer:indicator_end(M.INDIC_SPELLING, position)
  if not text:find('^%(') then
    buffer:set_sel(s, e)
    buffer:replace_sel(text)
    buffer:goto_pos(position)
  else
    if text:find(_L['Add']) then
      if not lfs.attributes(user_dicts) then lfs.mkdir(user_dicts) end
      local words = {}
      local f = io.open(user_dicts..'/user.dic', 'rb')
      if f then for word in f:lines() do words[#words + 1] = word end end
      words[1] = tonumber(words[1] or 0) + 1
      words[#words + 1] = buffer:text_range(s, e)
      f = io.open(user_dicts..'/user.dic', 'wb')
      f:write(table.concat(words, '\n'))
      f:close()
    end
    M.spellchecker:add_word(buffer:text_range(s, e))
    M.check_spelling()
  end
end)

-- LPeg grammar that matches spellcheck-able words.
local word_patt = {
  lpeg.Cp() * lpeg.C(lpeg.V('word')) * lpeg.Cp() + lpeg.V('skip') * lpeg.V(1),
  word_char = lpeg.R('AZ', 'az', '09', '\127\255') + '_',
  word_part = lpeg.R('az', '\127\255')^1 * -lpeg.V('word_char') +
              lpeg.R('AZ') * lpeg.R('az', '\127\255')^0 * -lpeg.V('word_char') +
              lpeg.R('AZ', '\127\255')^1 * -lpeg.V('word_char'),
  word = lpeg.V('word_part') * (lpeg.S("-'") * lpeg.V('word_part'))^-1 *
         -(lpeg.V('word_char') + lpeg.S("-'.") * lpeg.V('word_char')),
  skip = lpeg.V('word_char')^1 * (lpeg.S("-'.") * lpeg.V('word_char')^1)^0 +
         (1 - lpeg.V('word_char'))^1,
}

-- Returns a generator that acts like string.gmatch, but for LPeg patterns.
-- @param pattern LPeg pattern.
-- @param subject String subject.
local function lpeg_gmatch(pattern, subject)
  return function(subject, i)
    local s, word, e = lpeg.match(pattern, subject, i)
    if word then return e, s, word end
  end, subject, 1
end

---
-- Checks the buffer for spelling errors, marks misspelled words, and optionally
-- shows suggestions for the next misspelled word if *interactive* is `true`.
-- @param interactive Flag indicating whether or not to display suggestions for
--   the next misspelled word. The default value is `false`.
-- @param wrapped Utility flag indicating whether or not the spellchecker has
--   wrapped for displaying useful statusbar information. This flag is used and
--   set internally, and should not be set otherwise.
function M.check_spelling(interactive, wrapped)
  -- Show suggestions for the misspelled word under the caret if necessary.
  if interactive and
     bit32.btest(buffer:indicator_all_on_for(buffer.current_pos),
                 2^M.INDIC_SPELLING) then
    local s = buffer:indicator_start(M.INDIC_SPELLING, buffer.current_pos)
    local e = buffer:indicator_end(M.INDIC_SPELLING, buffer.current_pos)
    show_suggestions(buffer:text_range(s, e))
    return
  end
  -- Clear existing spellcheck indicators.
  buffer.indicator_current = M.INDIC_SPELLING
  if not interactive then buffer:indicator_clear_range(0, buffer.length) end
  -- Iterate over spellcheck-able text ranges, checking words in them, and
  -- marking misspellings.
  local spellcheckable_styles = {} -- cache
  local buffer, style_at = buffer, buffer.style_at
  local i = (not interactive or wrapped) and 0 or
            buffer:word_start_position(buffer.current_pos, false)
  while i < buffer.length do
    -- Ensure at least the next page of text is styled since spellcheck-able
    -- ranges depend on accurate styling.
    if i > buffer.end_styled then
      local next_page = buffer:line_from_position(i) + buffer.lines_on_screen
      buffer:colourise(buffer.end_styled, buffer.line_end_position[next_page])
    end
    local style = style_at[i]
    if spellcheckable_styles[style] == nil then
      -- Update the cache.
      local style_name = buffer.style_name[style]
      spellcheckable_styles[style] = M.spellcheckable_styles[style_name] == true
    end
    if spellcheckable_styles[style] then
      local j = i + 1
      while j < buffer.length and style_at[j] == style do j = j + 1 end
      for e, s, word in lpeg_gmatch(word_patt, buffer:text_range(i, j)) do
        if not M.spellchecker:spell(word) then
          buffer:indicator_fill_range(i + s - 1, e - s)
          if interactive then
            buffer:goto_pos(i + s - 1)
            show_suggestions(word)
            return
          end
        end
      end
      i = j
    else
      i = i + 1
    end
  end
  if interactive then
    if not wrapped then M.check_spelling(true, true) return end -- wrap
    ui.statusbar_text = _L['No misspelled words.']
  end
end
-- Check spelling upon saving files.
events.connect(events.FILE_AFTER_SAVE,
               function() if M.CHECK_SPELLING then M.check_spelling() end end)
-- Show spelling suggestions when clicking on misspelled words.
events.connect(events.INDICATOR_CLICK, function(position)
  if bit32.btest(buffer:indicator_all_on_for(position), 2^M.INDIC_SPELLING) then
    buffer:goto_pos(position)
    M.check_spelling(true)
  end
end)

-- Set up indicators, add a menu, and configure key bindings.
local function set_properties()
  buffer.indic_style[M.INDIC_SPELLING] = buffer.INDIC_DIAGONAL -- TODO: curses
  buffer.indic_fore[M.INDIC_SPELLING] = buffer.property_int['color.yellow']
end
events.connect(events.VIEW_NEW, set_properties)
events.connect(events.BUFFER_NEW, set_properties)
if textadept.menu then
  local tools = textadept.menu.menubar[4]
  table.insert(tools, 14, {
    title = _L['Spe_lling'],
    {_L['_Check Spelling...'], {M.check_spelling, true}},
    {_L['_Mark Misspelled Words'], M.check_spelling},
    {''},
    {_L['_Open User Dictionary'], function()
      if not lfs.attributes(user_dicts) then lfs.mkdir(user_dicts) end
      io.open_file(user_dicts..'user.dic')
    end}
  })
end
keys.f7 = {M.check_spelling, true}
keys.sf7 = M.check_spelling

return M
