-- Inserts a filename with a (if possible) relative path
-- from a file select dialog.
local M = {}

-- ## Commands

-- Opens a file select dialog and inserts filename in the buffer.
function M.insert_filename()
  local current_dir = (buffer.filename or ''):match('.+[/\\]')
  if not current_dir then
    current_dir = _HOME
  end
  filename =
      ui.dialog('fileselect',
                 '--title', "Insert filename",
                 '--select-multiple',
                 '--with-directory', current_dir)
  if filename then
    filename = filename:gsub('\n', '')
    filename = filename:gsub(current_dir, '')
    if buffer:get_sel_text() == '' then
      buffer:add_text(filename)
    else
      buffer:replace_sel(filename)
    end
  end
end

return M
