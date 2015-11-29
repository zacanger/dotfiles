--[[ Elastic Tabstops module for Textadept, version 2015-05-16

This module has been created by Joshua Krämer based on a C implementation of Elastic tabstops for Scintilla maintained by Nick Gravgaard (https://github.com/nickgravgaard/ElasticTabstopsForScintilla).

Copyright (c) 2007–2015 Nick Gravgaard, David Kinder, Joshua Krämer

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


CHANGELOG
* 2015-03-21: Initial version.
* 2015-04-21: The SCN_MODIFIED event is now used, which substantially improves performance.  This means the module now requires at least Textadept 8.0, because earlier versions do not expose the necessary fields of the event.
* 2015-05-16: Licence added.


TODO
* get rid of global variable global_position
* single function get_nof_tabs for tabs between and before/after, separate function to find boundaries
* fill num_tabs in get_nof_tabs function
]]


local M = {}

-- positions are counted from 0 (first position at the beginning of the buffer)

-- line start
local function line_start(pos)
	local line = buffer:line_from_position(pos)
	return buffer:position_from_line(line)
end

-- line end
local function line_end(pos)
	local line = buffer:line_from_position(pos)
	return buffer.line_end_position[line]
end

-- is position = line end?
local function is_line_end(pos)
	local line = buffer:line_from_position(pos)
	local end_pos = buffer.line_end_position[line]
	return (pos == end_pos)
end

-- table with cell grid, format: cell[line number][tabstop number]
-- keys: width_pix, block_first_line, ends_in_tab
-- block_first_line = number of first line in block, acts as index for the widest_width table
local cell = {}

-- table with number of tabs per line
local num_tabs = {}

-- table with widest tabstop width of a block, format: widest_width[first line number of block][tabstop number]
local widest_width = {}

-- table with all elastic tabstops in the buffer (pixel values), format: elastic_tabstops[buffer][line number][tabstop number]
local elastic_tabstops = {}

-- directions
local dir = {backward = 0, forward = 1}

-- start = position (starting from 0) of first character, stop = position after last character
local function get_text_width(start, stop)
	local text = buffer:text_range(start, stop)
	local style = buffer.style_at[start]
	return buffer:text_width(style, text)
end

local function calc_tab_width(text_width_in_tab)
	if (text_width_in_tab < tab_width_minimum) then
		text_width_in_tab = tab_width_minimum
	end
	return text_width_in_tab + tab_width_padding
end

local function change_line(position, direction)
	-- global_position must be modified globally
	
	-- Returns the line number of the line that contains position pos. Returns 0 if pos is less than 0 or buffer.line_count if pos is greater than buffer.length
	local line = buffer:line_from_position(position)
	if (direction == dir.forward) then
		-- The buffer is ended by \0.  If current_char is 0 (\0), the end of the buffer is reached.
		if (buffer.char_at[position] == 0) then
			return false
		end
		-- position_from_line returns the document position that corresponds with the start of the line. If line is negative, the position of the line holding the start of the selection is returned. If line is greater than the lines in the document, the return value is -1. If line is equal to the number of lines in the document (i.e. 1 line past the last line), the return value is the end of the document.
		global_position = buffer:position_from_line(line + 1)
	else
		if (line <= 0) then
			return false
		end
		global_position = buffer:position_from_line(line - 1)
	end
	return (global_position >= 0)
end

local function get_nof_tabs_between(start, stop)
	local current_position
	local max_tabs = 0

	global_position = line_start(start)
	repeat
		local tabs_on_line = 0

		current_position = global_position
		local current_char = buffer.char_at[current_position]
		local current_char_ends_line = is_line_end(current_position)
		
		while (current_char_ends_line == false) do
			if (current_char == 9) then -- 9 = \t
				tabs_on_line = tabs_on_line + 1
				if (tabs_on_line > max_tabs) then
					max_tabs = tabs_on_line
				end
			end
			current_position = buffer:position_after(current_position)
			current_char = buffer.char_at[current_position]
			current_char_ends_line = is_line_end(current_position)
		end
	until ((current_position >= stop) or (change_line(current_position, dir.forward) == false))
	return max_tabs
end

local function get_block_boundary(position, direction)
	-- global_position must be modified globally
	local current_position
	local max_tabs = 0
	local original_line = true

	global_position = line_start(position)
	repeat
		local tabs_on_line = 0

		current_position = global_position
		local current_char = buffer.char_at[current_position]
		local current_char_ends_line = is_line_end(current_position)

		while (current_char_ends_line == false) do
			if (current_char == 9) then -- 9 = \t
				tabs_on_line = tabs_on_line + 1
				if (tabs_on_line > max_tabs) then
					max_tabs = tabs_on_line
				end
			end
			current_position = buffer:position_after(current_position)
			current_char = buffer.char_at[current_position]
			current_char_ends_line = is_line_end(current_position)
		end
		if (tabs_on_line == 0 and original_line == false) then
			if (direction == dir.forward) then
				boundary_line = buffer:line_from_position(current_position) - 1
			else
				boundary_line = buffer:line_from_position(current_position) + 1
			end
			return boundary_line, max_tabs
		end
		original_line = false
	until (change_line(current_position, direction) == false)
	boundary_line = buffer:line_from_position(current_position)
	return boundary_line, max_tabs
end

local function stretch_tabstops(block_start_linenum, block_nof_lines, max_tabs)
	-- get width of text in cells
	local l = 0
	while (l < block_nof_lines) do -- for each line
		local text_width_in_tab = 0
		local current_line = block_start_linenum + l
		local current_tab_num = 0
		local cell_empty = true

		local current_position = buffer:position_from_line(current_line)
		local cell_start = current_position
		local current_char = buffer.char_at[current_position]
		current_char_ends_line = is_line_end(current_position)
		-- maybe change this to search forward for tabs/newlines

		-- initialization of the cell table
		cell[l] = {}
		local cell_num = 0
		-- cell_num = max_tabs + 1, thus "<="
		while (cell_num <= max_tabs) do
			cell[l][cell_num] = {}
			cell_num = cell_num + 1
		end
		num_tabs[l] = 0

		while (current_char ~= 0) do -- 0 = \0
			if (current_char_ends_line) then
				cell[l][current_tab_num].ends_in_tab = false
				text_width_in_tab = 0
				break
			elseif (current_char == 9) then -- 9 = \t
				if (cell_empty == false) then
					text_width_in_tab = get_text_width(cell_start, current_position)
				end
				cell[l][current_tab_num].ends_in_tab = true
				cell[l][current_tab_num].width_pix = calc_tab_width(text_width_in_tab)
				current_tab_num = current_tab_num + 1
				num_tabs[l] = num_tabs[l] + 1
				text_width_in_tab = 0
				cell_empty = true
			else
				if (cell_empty) then
					cell_start = current_position
					cell_empty = false
				end
			end
			current_position = buffer:position_after(current_position)
			current_char = buffer.char_at[current_position]
			current_char_ends_line = is_line_end(current_position)
		end
		l = l + 1
	end

	-- find columns blocks and stretch to fit the widest cell
	local t = 0
	while (t < max_tabs) do -- for each column
		local starting_new_block = true
		local first_line_in_block = 0
		local max_width = 0
		
		l = 0
		while (l < block_nof_lines) do -- for each line
			if (starting_new_block) then
				starting_new_block = false
				first_line_in_block = l
				max_width = 0

				if (widest_width[first_line_in_block] == nil) then
					widest_width[first_line_in_block] = {}
				end
			end
			if (cell[l][t].ends_in_tab) then
				cell[l][t].block_first_line = first_line_in_block
				if (cell[l][t].width_pix > max_width) then
					max_width = cell[l][t].width_pix
					widest_width[first_line_in_block][t] = max_width
				end
			else -- end column block
				starting_new_block = true
			end
			l = l + 1
		end
		t = t + 1
	end

	-- set tabstops
	l = 0
	while (l < block_nof_lines) do -- for each line
		current_line = block_start_linenum + l
		local acc_tabstop = 0
		
		buffer:clear_tab_stops(current_line)
		if (elastic_tabstops[buffer] == nil) then
			elastic_tabstops[buffer] = {}
		end
		elastic_tabstops[buffer][current_line] = {}

		t = 0
		while (t < num_tabs[l]) do
			if (cell[l][t].block_first_line ~= nil) then
				acc_tabstop = acc_tabstop + widest_width[cell[l][t].block_first_line][t]
				buffer:add_tab_stop(current_line, acc_tabstop)
				-- save the tab stops to restore them after a buffer switch
				elastic_tabstops[buffer][current_line][t] = acc_tabstop
			else
				break
			end
			t = t + 1
		end
		l = l + 1
	end
end

local function reset(start, stop)
	-- default tabstops width and padding
	tab_width_minimum = buffer:text_width(32, 'nn')
	tab_width_padding = buffer:text_width(32, 'nn')

	local max_tabs_between = get_nof_tabs_between(start, stop)
	local first_line, max_tabs_backward = get_block_boundary(start, dir.backward)
	local last_line, max_tabs_forward = get_block_boundary(stop, dir.forward)
	local max_tabs = math.max(max_tabs_between, max_tabs_backward, max_tabs_forward)
	local block_nof_lines = (last_line - first_line) + 1
	
	stretch_tabstops(first_line, block_nof_lines, max_tabs)
end

--function reset_visible(updated)
--	if ((updated ~= nil) and (updated ~= 2) and (buffer._textredux == nil)) then
--		local first = buffer:position_from_line(buffer.first_visible_line)
--		local last = buffer:position_from_line(math.min(buffer.line_count-1, buffer.first_visible_line+buffer.lines_on_screen))
--		reset(first, last)
--	end
--end

local function reset_modified(modification_type, position, length)
	if (buffer._textredux == nil) then
		-- modification_type is a bitmask; bit 1: text has been added, bit 2: text has been deleted
		if (modification_type & 1 == 1) then
			reset(position, position + length)
		elseif (modification_type & 2 == 2) then
			reset(position, position)
		end
	end
end

local function restore_tabstops()
	if (elastic_tabstops[buffer] ~= nil) then
		for line, tabstops in pairs(elastic_tabstops[buffer]) do
			for tabstop, position in pairs (tabstops) do
				buffer:add_tab_stop(line, position)
			end
		end
	end
end

function M.enable()
	events.connect('modified', function(modification_type, position, length)
		reset_modified(modification_type, position, length)
	end)
	events.connect('buffer_after_switch', function()
		restore_tabstops()
	end)
end

return M
