-- By default Textadept's strips off trailing whitespace from all lines.
-- This is a good thing, especially if you are using version control.
-- To avoid moving the caret when you have just carefully found your
-- position in some deeply nested code, this extension saves your
-- position and by enabling virtual space keeps the cursor's
-- position. If another key is pressed the necessary spaces
-- are inserted again. To see what is going on enable
-- view whitespace.

-- Variable to save the current column.
local saved_col

-- Save position before saving.
events.connect('file_before_save',
  function()
    local buffer = buffer
    saved_col = buffer.column[buffer.current_pos]
  end, 1)

-- Go in virtual space to position the cursor was at before saving.
events.connect('file_after_save',
  function()
    local buffer = buffer
    if saved_col > 0 then
      virtual_space = buffer.virtual_space_options
      buffer.virtual_space_options = 2
      local col = buffer.column[buffer.current_pos]
      local diff = saved_col - col
      if diff > 0 then
        for i=1, diff do
          buffer:char_right()
        end
      end
      buffer.virtual_space_options = virtual_space
    end
  end)
