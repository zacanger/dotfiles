-- Toggle between two buffers with a key shortcut.
local M = {}

-- ## Commands

-- Save the buffer index before switching.
events.connect(events.BUFFER_BEFORE_SWITCH, function()
    for index, b in ipairs(_BUFFERS) do
      if b == buffer then
        last_buffer = b
        break
      end
    end
  end)

-- Switch to last buffer.
function M.last_buffer()
  if last_buffer and _BUFFERS[last_buffer] then
    view:goto_buffer(_BUFFERS[last_buffer])
  end
end

return M
