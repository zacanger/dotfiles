-- This module adds functions for enclosing selections with a single key
-- and for inserting single chars with a short cut.
local M = {}

-- ## Setup
local events = events
local m_editing = textadept.editing
local keys = keys
local string_char = string.char

-- Table with char codes as indices.
braces = { -- () [] {}
  [40] = 1, [91] = 1, [123] = 1,
  [41] = 1, [93] = 1, [125] = 1,
}


-- ## Commands

-- Enclose selected text.<br>
-- Parameters:<br>
-- _left_: char on the left<br>
-- _right_: char on the right
function M.enclose_selection(left, right)
  if buffer:get_sel_text() == '' then
    return false
  else
    m_editing.enclose(left, right)
  end
end

-- Encloses selected text and keeps the selection for another enclosure.
-- If nothing is selected, the char is inserted. Useful to avoid automatically
-- matched braces.<br>
-- Parameters:<br>
-- _left_: char on the left<br>
-- _right_: char on the right
function M.paste_or_grow_enclose (left, right)
  if buffer:get_sel_text() == '' then
    buffer:add_text(left)
    return
  else
    start = buffer.anchor
    stop = buffer.current_pos
    if start > stop then
      start, stop = stop, start
    end
    add_start = #left
    add_stop = #right
    m_editing.enclose(left, right)
    buffer:set_sel(start, stop + add_start + add_stop)
  end
end

return M
