-- Shorten display filenames in buffer title and switch buffer dialog.
-- On Windows
--     C:\Documents and Settings\username\Desktop\...
-- is replaced with
--     Desktop\...,
-- on Max OS X and Linux
--     /home/username/..
-- or
--     /Users/username/...
-- with
--     ~/...
--
-- Modified from Textadept's `core.ui. module.

-- ## Fields

local pattern, replacement

-- Read environment variable.
if WIN32 then
  pattern = os.getenv('USERPROFILE')..'\\'
  replacement = ''
else
  pattern = '^'..os.getenv('HOME')
  replacement = '~'
end

-- ## Commands

-- Sets the title of the Textadept window to the buffer's filename.
-- Parameter:<br>
-- _buffer_: The currently focused buffer.
local function set_title(buffer)
  local buffer = buffer
  local filename = buffer.filename or buffer._type or _L['Untitled']
  local dirty = buffer.dirty and '*' or '-'
  ui.title = string.format('%s %s Textadept (%s)', filename:match('[^/\\]+$'),
                            dirty, filename:gsub(pattern, replacement))
end

-- Connect to events that change the title.
events.connect('save_point_reached',
  function() -- changes Textadept title to show 'clean' buffer
    buffer.dirty = false
    set_title(buffer)
  end)

events.connect('save_point_left',
  function() -- changes Textadept title to show 'dirty' buffer
    buffer.dirty = true
    set_title(buffer)
  end)

events.connect('buffer_after_switch',
  function() -- updates titlebar and statusbar
    set_title(buffer)
    events.emit('update_ui')
  end)

events.connect('view_after_switch',
  function() -- updates titlebar and statusbar
    set_title(buffer)
    events.emit('update_ui')
  end)
