
require('textredux').hijack()
require('elastic_tabstops').enable()
require 'common'

local ta_regex = require 'ta-regex'
ta_regex.install()
_M.file_browser = require 'file_browser'
    if not CURSES then ui.set_theme('base16-solarized-light') end
ui.set_theme('base16-chalk-dark', {font = 'Hasklig', fontsize = 10})
local distraction_free = false
local margin_widths = {}
local update_ui_hook
keys.cf11 = function()
  local buffer = buffer
  if not distraction_free then
    ui.menubar = {}
    for i = 0, 4 do
      margin_widths[i] = buffer.margin_width_n[i]
      buffer.margin_width_n[i] = 0
    end
    buffer.h_scroll_bar = false
    buffer.v_scroll_bar = false
    update_ui_hook = events.connect(events.UPDATE_UI,
                                    function()
      ui.statusbar_text, ui.bufstatusbar_text = '', ''
    end)
    events.emit(events.UPDATE_UI)
  else
    dofile(_HOME..'/modules/textadept/menu.lua') -- reset menu
    for i = 0, 4 do
      buffer.margin_width_n[i] = margin_widths[i]
    end
    buffer.h_scroll_bar = true
    buffer.v_scroll_bar = true
    events.disconnect(update_ui_hook)
  end
  distraction_free = not distraction_free
end

function stats()
    local n_lines = buffer.line_count
    local _, n_words = string.gsub(buffer:get_text(), "%S+", "")
    local n_chars = buffer:count_characters(0, buffer.length)
    if buffer.selection_empty then
        ui.dialogs.msgbox {title = 'Statistics',
            text = string.format("Buffer:\n\n%d lines\n%d words\n%d characters",
                n_lines, n_words, n_chars),
            icon = 'gtk-dialog-info'}
    else
        local n_lines_s = buffer:line_from_position(buffer.selection_end) - buffer:line_from_position(buffer.selection_start) + 1
        local _, n_words_s = string.gsub(buffer:text_range(buffer.selection_start, buffer.selection_end), "%S+", "")
        local n_chars_s = buffer:count_characters(buffer.selection_start, buffer.selection_end)
        ui.dialogs.msgbox {title = 'Statistics',
            text = string.format("Selection / Buffer:\n\n%d / %d lines\n%d / %d words\n%d / %d characters",
                n_lines_s, n_lines, n_words_s, n_words, n_chars_s, n_chars),
            icon = 'gtk-dialog-info'}
    end
end

keys.cI = stats
buffer.tab_width = 2

keys.hypertext = {
    cr = function ()
      local url
      local sel = buffer:get_sel_text()
      if #sel == 0 then
        url = buffer.filename
      else
        url = sel
      end
      local cmd
      if WIN32 then
        cmd = string.format('start "" "%s"', url)
        local p = io.popen(cmd)
        if not p then error(l.MENU_BROWSER_ERROR..url) end
      else
        cmd = string.format(OSX and 'open "file://%s"' or 'xdg-open "%s" &', url)
        if os.execute(cmd) ~= 0 then error(_L['Error loading webpage:']..url) end
      end
    end,
}

-- Deletes the lines spanned by the selection or delete current line if no selection.
function delete_lines()
  buffer:begin_undo_action()
  if buffer.selection_empty then
    buffer:line_delete()
  else
    local start_line = buffer:line_from_position(buffer.selection_start)
    local end_line = buffer:line_from_position(buffer.selection_end)
    local start_pos = buffer:position_from_line(start_line)
    local end_pos = buffer:position_from_line(end_line + 1)
    buffer:delete_range(start_pos, end_pos - start_pos)
  end
  buffer:end_undo_action()
end

function goto_nearest_occurrence(reverse)
        local buffer = buffer
        local s, e = buffer.selection_start, buffer.selection_end
        if s == e then
                s, e = buffer:word_start_position(s), buffer:word_end_position(s)
        end
        local word = buffer:text_range(s, e)
        if word == '' then return end
        buffer.search_flags = buffer.FIND_WHOLEWORD + buffer.FIND_MATCHCASE
        if reverse then
                buffer.target_start = s - 1
                buffer.target_end = 0
        else
                buffer.target_start = e + 1
                buffer.target_end = buffer.length
        end
        if buffer:search_in_target(word) == -1 then
                if reverse then
                        buffer.target_start = buffer.length
                        buffer.target_end = e + 1
                else
                        buffer.target_start = 0
                        buffer.target_end = s - 1
                end
                if buffer:search_in_target(word) == -1 then return end
        end
        buffer:set_sel(buffer.target_start, buffer.target_end)
end

keys.ck = {goto_nearest_occurrence, false}
keys.cK = {goto_nearest_occurrence, true}

package.path = '/home/z/.textadept/modules/textadept-vi/?.lua;' .. package.path
package.cpath = '/home/z/.textadept/modules/textadept-vi/?.so;' .. package.cpath
_G.vi_mode = require 'vi_mode'

