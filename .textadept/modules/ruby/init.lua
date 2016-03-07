-- Copyright 2007-2016 Mitchell mitchell.att.foicica.com. See LICENSE.

local M = {}

--[[ This comment is for LuaDoc.
---
-- The ruby module.
-- It provides utilities for editing Ruby code.
--
-- ## Key Bindings
--
-- + `Shift+Enter` (`⇧↩` | `S-Enter`)
--   Try to autocomplete an `if`, `while`, `for`, etc. control structure with
--   `end`.
module('_M.ruby')]]

-- Sets default buffer properties for Ruby files.
events.connect(events.LEXER_LOADED, function(lang)
  if lang == 'ruby' then
    buffer.word_chars =
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_?!'
  end
end)

-- Autocompletion and documentation.

---
-- List of "fake" ctags files to use for autocompletion.
-- In addition to the normal ctags kinds for Ruby, the kind 'C' is recognized as
-- a constant and 'a' as an attribute.
-- @class table
-- @name tags
M.tags = {_HOME..'/modules/ruby/tags', _USERHOME..'/modules/ruby/tags'}

---
-- Map of expression patterns to their types.
-- Expressions are expected to match after the '=' sign of a statement.
-- @class table
-- @name expr_types
M.expr_types = {
  ['^[\'"]'] = 'String',
  ['^%['] = 'Array',
  ['^{'] = 'Hash',
  ['^/'] = 'Regexp',
  ['^:'] = 'Symbol',
  ['^%d+%f[^%d%.]'] = 'Integer',
  ['^%d+%.%d+'] = 'Float',
  ['^%d+%.%.%.?%d+'] = 'Range'
}

local XPM = textadept.editing.XPM_IMAGES
local xpms = {
  c = XPM.CLASS, f = XPM.METHOD, m = XPM.STRUCT, F = XPM.SLOT, C = XPM.VARIABLE,
  a = XPM.VARIABLE
}

textadept.editing.autocompleters.ruby = function()
  local list = {}
  -- Retrieve the symbol behind the caret.
  local line, pos = buffer:get_cur_line()
  local symbol, op, part = line:sub(1, pos):match('([%w_%.]-)([%.:]*)([%w_]*)$')
  if symbol == '' and part == '' and op ~= '' then return nil end -- lone ., ::
  if op ~= '' and op ~= '.' and op ~= '::' then return nil end
  -- Attempt to identify the symbol type.
  -- TODO: identify literals like "'foo'." and "[1, 2, 3].".
  local buffer = buffer
  local assignment = '%f[%w_]'..symbol:gsub('(%p)', '%%%1')..'%s*=%s*(.*)$'
  for i = buffer:line_from_position(buffer.current_pos) - 1, 0, -1 do
    local expr = buffer:get_line(i):match(assignment)
    if expr then
      for patt, type in pairs(M.expr_types) do
        if expr:find(patt) then symbol = type break end
      end
      if expr:find('^[%w_:]+%.new') then
        symbol = expr:match('^([%w_:]+).new') -- e.g. a = Foo.new
        break
      end
    end
  end
  -- Search through ctags for completions for that symbol.
  local name_patt = '^'..part
  local symbol_patt = '%f[%w]'..symbol..'%f[^%w_]'
  local sep = string.char(buffer.auto_c_type_separator)
  for i = 1, #M.tags do
    if lfs.attributes(M.tags[i]) then
      for line in io.lines(M.tags[i]) do
        local name = line:match('^%S+')
        if name:find(name_patt) and not list[name] then
          local fields = line:match(';"\t(.*)$')
          local k, class = fields:sub(1, 1), fields:match('class:(%S+)') or ''
          if class:find(symbol_patt) and (op ~= ':' or k == 'f') then
            list[#list + 1] = ("%s%s%d"):format(name, sep, xpms[k])
            list[name] = true
          end
        end
      end
    end
  end
  return #part, list
end

textadept.editing.api_files.ruby = {
  _HOME..'/modules/ruby/api', _USERHOME..'/modules/ruby/api'
}

-- Commands.

---
-- Patterns for auto `end` completion for control structures.
-- @class table
-- @name control_structure_patterns
-- @see try_to_autocomplete_end
local control_structure_patterns = {
  '^%s*begin', '^%s*case', '^%s*class', '^%s*def', '^%s*for', '^%s*if',
  '^%s*module', '^%s*unless', '^%s*until', '^%s*while', 'do%s*|?.-|?%s*$'
}

---
-- Tries to autocomplete Ruby's `end` keyword for control structures like `if`,
-- `while`, `for`, etc.
-- @see control_structure_patterns
-- @name try_to_autocomplete_end
function M.try_to_autocomplete_end()
  local line_num = buffer:line_from_position(buffer.current_pos)
  local line = buffer:get_line(line_num)
  local line_indentation = buffer.line_indentation
  for _, patt in ipairs(control_structure_patterns) do
    if line:find(patt) then
      local indent = line_indentation[line_num]
      buffer:begin_undo_action()
      buffer:new_line()
      buffer:new_line()
      buffer:add_text('end')
      line_indentation[line_num + 1] = indent + buffer.tab_width
      buffer:line_up()
      buffer:line_end()
      buffer:end_undo_action()
      return true
    end
  end
  return false
end

-- Contains newline sequences for buffer.eol_mode.
-- This table is used by toggle_block().
-- @class table
-- @name newlines
local newlines = {[0] = '\r\n', '\r', '\n'}

---
-- Toggles between `{ ... }` and `do ... end` Ruby blocks.
-- If the caret is inside a `{ ... }` single-line block, that block is converted
-- to a multiple-line `do .. end` block. If the caret is on a line that contains
-- single-line `do ... end` block, that block is converted to a single-line
-- `{ ... }` block. If the caret is inside a multiple-line `do ... end` block,
-- that block is converted to a single-line `{ ... }` block with all newlines
-- replaced by a space. Indentation is important. The `do` and `end` keywords
-- must be on lines with the same level of indentation to toggle correctly.
-- @name toggle_block
function M.toggle_block()
  local buffer = buffer
  local pos = buffer.current_pos
  local line = buffer:line_from_position(pos)
  local e = buffer.line_end_position[line]
  local line_indentation = buffer.line_indentation

  -- Try to toggle from { ... } to do ... end.
  local char_at = buffer.char_at
  local p = pos
  while p < e do
    if char_at[p] == 125 then -- '}'
      local s = buffer:brace_match(p)
      if s >= 0 then
        local block = buffer:text_range(s + 1, p)
        local hash = false
        local s2, e2 = block:find('%b{}')
        if not s2 and not e2 then s2, e2 = #block, #block end
        local part1, part2 = block:sub(1, s2), block:sub(e2 + 1)
        hash = part1:find('=>') or part1:find('[%w_]:') or
               part2:find('=>') or part2:find('[%w_]:')
        if not hash then
          local newline = newlines[buffer.eol_mode]
          local block, r = block:gsub('^(%s*|[^|]*|)', '%1'..newline)
          if r == 0 then block = newline..block end
          buffer:begin_undo_action()
          buffer:set_target_range(s, p + 1)
          buffer:replace_target('do'..block..newline..'end')
          local indent = line_indentation[line]
          line_indentation[line + 1] = indent + buffer.tab_width
          line_indentation[line + 2] = indent
          buffer:end_undo_action()
          return
        end
      end
    end
    p = p + 1
  end

  -- Try to toggle from do ... end to { ... }.
  local block, r = buffer:get_cur_line():gsub('do([^%w_]+.-)end$', '{%1}')
  if r > 0 then
    -- Single-line do ... end block.
    buffer:begin_undo_action()
    buffer:set_target_range(buffer:position_from_line(line), e)
    buffer:replace_target(block)
    buffer:goto_pos(pos - 1)
    buffer:end_undo_action()
    return
  end
  local do_patt, end_patt = 'do%s*|?[^|]*|?%s*$', '^%s*end'
  local s = line
  while s >= 0 and not buffer:get_line(s):find(do_patt) do s = s - 1 end
  if s < 0 then return end -- no block start found
  local indent = line_indentation[s]
  e = s + 1
  while e < buffer.line_count and (not buffer:get_line(e):find(end_patt) or
                                   line_indentation[e] ~= indent) do
    e = e + 1
  end
  if e >= buffer.line_count then return end -- no block end found
  local s2 = buffer:position_from_line(s) + buffer:get_line(s):find(do_patt) - 1
  local _, e2 = buffer:get_line(e):find(end_patt)
  e2 = buffer:position_from_line(e) + e2
  if e2 < pos then return end -- the caret is outside the block found
  block = buffer:text_range(s2, e2):match('^do(.+)end$')
  block = block:gsub('[\r\n]+', ' '):gsub(' +', ' ')
  buffer:begin_undo_action()
  buffer:set_target_range(s2, e2)
  buffer:replace_target('{'..block..'}')
  buffer:end_undo_action()
end

---
-- Container for Ruby-specific key bindings.
-- @class table
-- @name _G.keys.ruby
keys.ruby = {
  ['s\n'] = M.try_to_autocomplete_end,
  ['c{'] = M.toggle_block,
}

-- Snippets.

if type(snippets) == 'table' then
---
-- Container for Ruby-specific snippets.
-- @class table
-- @name _G.snippets.ruby
  snippets.ruby = {
    rb = '#!%[which ruby]',
    forin = 'for %1(element) in %2(collection)\n\t%1.%0\nend',
    ife = 'if %1(condition)\n\t%2\nelse\n\t%3\nend',
    ['if'] = 'if %1(condition)\n\t%0\nend',
    case = 'case %1(object)\nwhen %2(condition)\n\t%0\nend',
    Dir = 'Dir.glob(%1(pattern)) do |%2(file)|\n\t%0\nend',
    File = 'File.foreach(%1(\'path/to/file\')) do |%2(line)|\n\t%0\nend',
    am = 'alias_method :%1(new_name), :%2(old_name)',
    all = 'all? { |%1(e)| %0 }',
    any = 'any? { |%1(e)| %0 }',
    app = 'if __FILE__ == $PROGRAM_NAME\n\t%0\nend',
    as = 'assert(%1(test), \'%2(Failure message.)\')',
    ase = 'assert_equal(%1(expected), %2(actual))',
    asid = 'assert_in_delta(%1(expected_float), %2(actual_float), %3(2 ** -20))',
    asio = 'assert_instance_of(%1(ExpectedClass), %2(actual_instance))',
    asko = 'assert_kind_of(%1(ExpectedKind), %2(actual_instance))',
    asm = 'assert_match(/%1(expected_pattern)/, %2(actual_string))',
    asn = 'assert_nil(%1(instance))',
    asnm = 'assert_no_match(/%1(unexpected_pattern)/, %2(actual_string))',
    asne = 'assert_not_equal(%1(unexpected), %2(actual))',
    asnn = 'assert_not_nil(%1(instance))',
    asns = 'assert_not_same(%1(unexpected), %2(actual))',
    asnr = 'assert_nothing_raised(%1(Exception)) { %0 }',
    asnt = 'assert_nothing_thrown { %0 }',
    aso = 'assert_operator(%1(left), :%2(operator), %3(right))',
    asr = 'assert_raise(%1(Exception)) { %0 }',
    asrt = 'assert_respond_to(%1(object), :%2(method))',
    assa = 'assert_same(%1(expected), %2(actual))',
    asse = 'assert_send([%1(object), :%2(message), %3(args)])',
    ast = 'assert_throws(:%1(expected)) { %0 }',
    rw = 'attr_accessor :%1(attr_names)',
    r = 'attr_reader :%1(attr_names)',
    w = 'attr_writer :%1(attr_names)',
    cla = 'class %1(ClassName)\n\t%0\nend',
    cl = 'classify { |%1(e)| %0 }',
    col = 'collect { |%1(e)| %0 }',
    collect = 'collect { |%1(element)| %1.%0 }',
    def = 'def %1(method_name)\n\t%0\nend',
    mm = 'def method_missing(meth, *args, &block)\n\t%0\nend',
    defs = 'def self.%1(class_method_name)\n\t%0\nend',
    deft = 'def test_%1(case_name)\n\t%0\nend',
    deli = 'delete_if { |%1(e)| %0 }',
    det = 'detect { |%1(e)| %0 }',
    ['do'] = 'do\n\t%0\nend',
    doo = 'do |%1(object)|\n\t%0\nend',
    each = 'each { |%1(e)| %0 }',
    eab = 'each_byte { |%1(byte)| %0 }',
    eac = 'each_char { |%1(chr)| %0 }',
    eaco = 'each_cons(%1(2)) { |%2(group)| %0 }',
    eai = 'each_index { |%1(i)| %0 }',
    eak = 'each_key { |%1(key)| %0 }',
    eal = 'each_line%1 { |%2(line)| %0 }',
    eap = 'each_pair { |%1(name), %2(val)| %0 }',
    eas = 'each_slice(%1(2)) { |%2(group)| %0 }',
    eav = 'each_value { |%1(val)| %0 }',
    eawi = 'each_with_index { |%1(e), %2(i)| %0 }',
    fin = 'find { |%1(e)| %0 }',
    fina = 'find_all { |%1(e)| %0 }',
    flao = 'inject(Array.new) { |%1(arr), %2(a)| %1.push(*%2) }',
    grep = 'grep(%1(pattern)) { |%2(match)| %0 }',
    gsu = 'gsub(/%1(pattern)/) { |%2(match)| %0 }',
    [':'] = ':%1(key) => \'%2(value)\',',
    is = '=> ',
    inj = 'inject(%1(init)) { |%2(mem), %3(var)| %0 }',
    lam = 'lambda { |%1(args)| %0 }',
    map = 'map { |%1(e)| %0 }',
    mapwi = 'enum_with_index.map { |%1(e), %2(i)| %0 }',
    max = 'max { |a, b| %0 }',
    min = 'min { |a, b| %0 }',
    mod = 'module %1(ModuleName)\n\t%0\nend',
    par = 'partition { |%1(e)| %0 }',
    ran = 'sort_by { rand }',
    rej = 'reject { |%1(e)| %0 }',
    req = 'require \'%0\'',
    rea = 'reverse_each { |%1(e)| %0 }',
    sca = 'scan(/%1(pattern)/) { |%2(match)| %0 }',
    sel = 'select { |%1(e)| %0 }',
    sor = 'sort { |a, b| %0 }',
    sorb = 'sort_by { |%1(e)| %0 }',
    ste = 'step(%1(2)) { |%2(n)| %0 }',
    sub = 'sub(/%1(pattern)/) { |%2(match)| %0 }',
    tim = 'times { %1(n) %0 }',
    uni = 'ARGF.each_line%1 do |%2(line)|\n\t%0\nend',
    unless = 'unless %1(condition)\n\t%0\nend',
    upt = 'upto(%1(2)) { |%2(n)| %0 }',
    dow = 'downto(%1(2)) { |%2(n)| %0 }',
    when = 'when %1(condition)\n\t',
    zip = 'zip(%1(enums)) { |%2(row)| %0 }',
    tc = [[
require 'test/unit'
require '%1(library_file_name)'

class Test%2(NameOfTestCases) < Test::Unit::TestCase
	def test_%3(case_name)
		%0
	end
end]],
  }
end

return M
