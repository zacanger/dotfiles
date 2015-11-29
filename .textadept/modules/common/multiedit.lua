-- Keyboard short cuts for adding multiple cursors.<br>
-- Copyright (c) 2010 [Brian Schott (Sir Alaran)](http://caladbolg.net/textadeptwiki/index.php?n=Main.Multiedit).<br>
-- License: [MIT](http://www.opensource.org/licenses/mit-license.php).
--
-- The following buffer settings are required:
--     buffer.multiple_selection = true
--     buffer.additional_selection_typing = true
--     buffer.additional_carets_visible = true
local M = {}

local findall = require 'common.findall'

-- ## Setup

local positions = {}
local restore = false

-- ## Commands

-- Adds a single mark.
function M.add_position()
  table.insert(positions, buffer.current_pos)
  buffer:add_selection(buffer.current_pos, buffer.current_pos)
  restore = true
end

-- Resets the cursor positions according to the positions table. This function
-- exists because Scintilla is grouchy and likes to kill the multi-selection.
local function set_cursor_positions()
  local prev_pos = buffer.current_pos
  for key, pos in ipairs(positions) do
    if pos ~= prev_pos then
      if key == 1 then
        buffer:clear_selections()
        buffer:set_selection(pos, pos)
      else
        buffer:add_selection(pos, pos, 0)
      end
    end
  end
  if buffer.current_pos ~= prev_pos then
    buffer:add_selection(prev_pos, prev_pos, 0)
  end
end

-- Multi-select all occurences of the word at the cursor position. This acts as
-- a very fast find-replace function. Use with caution, as this selects all
-- occurences of the word at the cursor.
function M.select_all()
  local start_position = buffer.current_pos
  local occurences = findall.find_all_at_cursor()
  local main_sel = 0
  if #occurences > 1 then
    for i, j in ipairs(occurences) do
      if j[1] > start_position or j[2] < start_position then
        buffer:add_selection(j[1], j[2])
      else
        main_sel = i
      end
    end
    buffer:add_selection(occurences[main_sel][1], occurences[main_sel][2])
    while buffer.selection_start > start_position
        or buffer.selection_end < start_position do
      buffer:rotate_selection()
    end
  elseif #occurences == 1 then
    buffer:set_selection(occurences[1][1], occurences[1][2])
  end
end

-- Cancel selections on `Esc` key press.
events.connect('keypress',
  function(code, shift, control, alt)
    if code == 0xff1b then -- Escape key
      local prev_pos = buffer.current_pos
      buffer:clear_selections()
      buffer:set_selection(prev_pos, prev_pos)
      positions = {}
    elseif restore == true then
      set_cursor_positions()
      if code == 0xff08 or code == 0xff9f or code == 0xffff then
        restore = false
        positions = {}
      end
    end
  end
)

events.connect('char_added',
  function()
    restore = false
    positions = {}
    return
  end
)

return M
