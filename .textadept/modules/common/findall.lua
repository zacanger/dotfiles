-- Finds occurences of word under the cursor.<br>
-- Copyright (c) 2010 [Brian Schott (Sir Alaran)](http://caladbolg.net/textadeptwiki/index.php?n=Main.Multiedit).<br>
-- License: [MIT](http://www.opensource.org/licenses/mit-license.php).
local M = {}

-- ## Commands

-- Returns a table consisting of the start and end positions of the occurences
-- of the word at the cursor position
function M.find_all_at_cursor()
  local ret_val = {}
  local position = buffer.current_pos
  -- Grab the word at the current position
  buffer:word_left()
  buffer:word_right_end_extend()
  needle = buffer:get_sel_text()
  -- Trim any whitespace
  needle = needle:gsub('%s', '')
  -- Escape unwanted characters
  needle = needle:gsub('([().*+?^$%%[%]-])', '%%%1')
  -- Don't look for zero-length strings
  if #needle > 0 then
    for i = 0, buffer.line_count do
      local text = buffer:get_line(i)
      if #text>0 then
        local first, last = 0, 0
        while first do
          first, last = text:find("%f[%w]"..needle.."%f[%W]",last)
          if last then
            if (first ~= nil) and (first >0) then
              first = first - 1
            end
            table.insert(ret_val, {buffer:position_from_line(i) + first,
                                  buffer:position_from_line(i) + last})
            last = last + 1
          end
        end
      end
    end
  end
  buffer:set_sel(position, position)
  return ret_val
end

return M
