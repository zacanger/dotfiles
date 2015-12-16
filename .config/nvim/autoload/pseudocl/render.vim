" Copyright (c) 2014 Junegunn Choi
"
" MIT License
"
" Permission is hereby granted, free of charge, to any person obtaining
" a copy of this software and associated documentation files (the
" "Software"), to deal in the Software without restriction, including
" without limitation the rights to use, copy, modify, merge, publish,
" distribute, sublicense, and/or sell copies of the Software, and to
" permit persons to whom the Software is furnished to do so, subject to
" the following conditions:
"
" The above copyright notice and this permission notice shall be
" included in all copies or substantial portions of the Software.
"
" THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
" EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
" MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
" NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
" LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
" OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
" WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

let s:cpo_save = &cpo
set cpo&vim

if exists("*strwidth")
  function! s:strwidth(str)
    return strwidth(a:str)
  endfunction
else
  function! s:strwidth(str)
    return len(split(a:str, '\zs'))
  endfunction
endif

function! pseudocl#render#loop(opts)
  let s:highlight = a:opts.highlight
  let s:yanked = ''
  let s:noremap = 0
  let xy = [&ruler, &showcmd]
  try
    set noruler noshowcmd
    call s:hide_cursor()
    let shortmess = &shortmess
    set shortmess+=T

    let old           = a:opts.input
    let history       = copy(a:opts.history)
    let s:matches     = []
    let s:history_idx = len(history)
    let s:keystrokes  = []
    let s:prev_time   = 0
    let s:remap       = a:opts.remap
    let s:use_maps    = a:opts.map
    call add(history, old)

    let valid_codes  = [g:pseudocl#CONTINUE, g:pseudocl#RETURN, g:pseudocl#EXIT, g:pseudocl#MAP]
    let valid_events = [g:pseudocl#CTRL_F]
    while 1
      call a:opts.renderer(pseudocl#get_prompt(), old, a:opts.cursor)
      let [code, new, a:opts.cursor] =
            \ s:process_char(old, a:opts.cursor, a:opts.words, history)

      " Event
      if index(valid_events, code) >= 0
        let [code, new, a:opts.cursor] = a:opts.on_event(code, new, a:opts.cursor)
      endif

      while index(valid_codes, code) < 0
        let [code, new, a:opts.cursor] = a:opts.on_unknown_key(code, new, a:opts.cursor)
      endwhile

      if code == g:pseudocl#MAP
        continue
      elseif code == g:pseudocl#CONTINUE
        if new != old
          call a:opts.on_change(new, old, a:opts.cursor)
        endif
        let old = new
        continue
      elseif code == g:pseudocl#RETURN
        call a:opts.renderer(pseudocl#get_prompt(), new, -1)
        return new
      elseif code == g:pseudocl#EXIT
        call a:opts.renderer(pseudocl#get_prompt(), new, -1)
        throw 'exit'
      endif
    endwhile
  finally
    call s:show_cursor()
    let &shortmess = shortmess
    let [&ruler, &showcmd] = xy
  endtry
endfunction

function! pseudocl#render#echo(prompt, line, cursor)
  if exists('s:force_echo') || getchar(1) == 0
    call pseudocl#render#clear()
    let plen = pseudocl#render#echo_prompt(a:prompt)
    call pseudocl#render#echo_line(a:line, a:cursor, plen)
    unlet! s:force_echo
  endif
endfunction

function! pseudocl#render#clear()
  echon "\r\r"
  echon ''
endfunction

function! s:strtrans(str)
  return substitute(a:str, "\n", '^M', 'g')
endfunction

function! s:trim(str, margin, left)
  let str = a:str
  let mod = 0
  let ww  = winwidth(winnr()) - a:margin - 2
  let sw  = s:strwidth(str)
  let pat = a:left ? '^.' : '.$'
  while sw >= ww
    let sw -= s:strwidth(matchstr(str, pat))
    let str = substitute(str, pat, '', '')
    let mod = 1
  endwhile
  if mod
    let str = substitute(str, a:left ? '^..' : '..$', '', '')
  endif
  return [str, mod ? '..' : '', sw]
endfunction

function! s:trim_left(str, margin)
  return s:trim(a:str, a:margin, 1)
endfunction

function! s:trim_right(str, margin)
  return s:trim(a:str, a:margin, 0)
endfunction

function! pseudocl#render#echo_line(str, cursor, prompt_width)
  hi PseudoCLCursor term=inverse cterm=inverse gui=inverse
  try
    if a:cursor < 0
      let [str, ellipsis, _] = s:trim_left(s:strtrans(a:str), a:prompt_width + 2)
      if !empty(ellipsis)
        echohl NonText
        echon ellipsis
      endif

      execute 'echohl '.s:highlight
      echon str
    elseif a:cursor == len(a:str)
      let [str, ellipsis, _] = s:trim_left(s:strtrans(a:str), a:prompt_width + 2)
      if !empty(ellipsis)
        echohl NonText
        echon ellipsis
      endif

      execute 'echohl '.s:highlight
      echon str

      echohl PseudoCLCursor
      echon ' '
    else
      let prefix = s:strtrans(strpart(a:str, 0, a:cursor))
      let m = matchlist(strpart(a:str, a:cursor), '^\(.\)\(.*\)')
      let cursor = s:strtrans(m[1])
      let suffix = s:strtrans(m[2])

      let [prefix, ellipsis, pwidth] = s:trim_left(prefix,  a:prompt_width + 1 + 2)

      if !empty(ellipsis)
        echohl NonText
        echon ellipsis
      endif

      execute 'echohl '.s:highlight
      echon prefix

      echohl PseudoCLCursor
      echon cursor

      let [suffix, ellipsis, _] = s:trim_right(suffix, a:prompt_width + pwidth - 1 + 2)
      execute 'echohl '.s:highlight
      echon suffix
      if !empty(ellipsis)
        echohl NonText
        echon ellipsis
      endif
    endif
  finally
    echohl None
  endtry
endfunction

function! s:hide_cursor()
  if !exists('s:t_ve')
    let s:t_ve = &t_ve
    set t_ve=
  endif

  if hlID('Cursor') != 0
    redir => hi_cursor
    silent hi Cursor
    redir END
    let link = matchstr(hi_cursor, 'links to \zs.*')
    let s:hi_cursor = empty(link) ?
          \ ('highlight ' . substitute(hi_cursor, 'xxx\|\n', '', 'g'))
          \ : ('highlight link Cursor '.link)
    hi Cursor guibg=bg
  endif
endfunction

function! s:show_cursor()
  if exists('s:t_ve')
    let &t_ve = s:t_ve
    unlet s:t_ve
  endif

  if exists('s:hi_cursor')
    hi clear Cursor
    if s:hi_cursor !~ 'cleared'
      execute s:hi_cursor
    endif
  endif
endfunction

function! pseudocl#render#echo_prompt(prompt)
  let type = type(a:prompt)
  if type == 1
    let len = s:prompt_in_str(a:prompt)
  elseif type == 3
    let len = s:prompt_in_list(a:prompt)
  else
    echoerr "Invalid type"
  endif
  return len
endfunction

function! s:prompt_in_str(str)
  execute 'echohl '.s:highlight
  echon a:str
  echohl None
  return s:strwidth(a:str)
endfunction

function! s:prompt_in_list(list)
  let list = copy(a:list)
  let len = 0
  while !empty(list)
    let hl = remove(list, 0)
    let str = remove(list, 0)
    execute 'echohl ' . hl
    echon str
    let len += s:strwidth(str)
  endwhile
  echohl None
  return len
endfunction

function! s:input(prompt, default)
  try
    call s:show_cursor()
    redraw
    return input(a:prompt, a:default)
  finally
    call s:hide_cursor()
    redraw
  endtry
endfunction

function! s:evaluate_keyseq(seq)
  return substitute(a:seq, '<[^> ]\+>', '\=eval("\"\\".submatch(0)."\"")', 'g')
endfunction

function! s:evaluate_keymap(arg)
  if a:arg.expr
    return eval(s:evaluate_keyseq(substitute(a:arg.rhs, '\c<sid>', '<snr>'.a:arg.sid.'_', '')))
  else
    return s:evaluate_keyseq(a:arg.rhs)
  endif
endfunction

function! s:process_char(str, cursor, words, history)
  try
    let c = s:getchar()
  catch /^Vim:Interrupt$/
    let c = "\<C-c>"
  endtry
  if c == g:pseudocl#MAP
    return [g:pseudocl#MAP, a:str, a:cursor]
  else
    return s:decode_char(c, a:str, a:cursor, a:words, a:history)
  endif
endfunction

function! s:timed_getchar(time)
  if a:time == 0
    let c = getchar()
    let ch = nr2char(c)
    return empty(ch) ? c : ch
  else
    for _ in range(0, a:time, 10)
      let c = getchar(0)
      if !empty(c)
        let ch = nr2char(c)
        return empty(ch) ? c : ch
      endif
      sleep 10m
    endfor
    return ''
  endif
endfunction

function! s:gettime()
  let [s, us] = reltime()
  return s * 1000 + us / 1000
endfunction

function! s:cancel_map()
  let first = remove(s:keystrokes, 0)
  call feedkeys(substitute(join(s:keystrokes, ''), "\n", "\r", 'g'))
  let s:prev_time = 0
  let s:keystrokes = []
  let s:force_echo = 1
  return first
endfunction

function! s:for_args(func, first, arglists)
  for arglist in a:arglists
    let ret = call(a:func, insert(arglist, a:first, 0))
    if !empty(ret)
      break
    endif
  endfor
  return ret
endfunction

if v:version > 703 || v:version == 703 && has('patch32')
  function! s:cmaparg(combo, opts)
    for opt in a:opts
      call add(opt, 1)
    endfor
    return s:for_args('maparg', a:combo, a:opts)
  endfunction
else
  " FIXME: Unable to check if it's <expr> mapping
  function! s:cmaparg(combo, opts)
    let arg = s:for_args('maparg', a:combo, a:opts)
    let dict = { 'rhs': arg, 'expr': 0, 'noremap': 1 }
    return empty(arg) ? {} : dict
  endfunction
endif

function! s:mapcheck(str)
  return s:for_args('mapcheck', a:str, [['c', 0], ['l', 0]])
endfunction

function! s:getchar()
  let timeout = 0
  while 1
    let c = s:timed_getchar(timeout)
    if !s:use_maps || s:noremap > 0
      let s:noremap = max([0, s:noremap - len(c)])
      return c
    endif

    call add(s:keystrokes, c)
    let maparg = s:cmaparg(join(s:keystrokes, ''), [['c', 0], ['l', 0]])

    " FIXME: For now, let's just assume that we don't have multiple mappings
    " with the same prefix
    " e.g.
    "      cnoremap x X
    "      cnoremap xy XY
    "
    "      In this case, xy should evaluate to XY, but this is not correctly
    "      implemented since it doesn't seem possible to check at the time we
    "      have 'x' if there is any mapping that starts with 'x'.
    "
    "      We could look through the output of 'cmap' command, but it's just
    "      too hacky.
    if !empty(maparg)
      let s:keystrokes = []
      let s:prev_time = 0

      let keys = s:evaluate_keymap(maparg)
      if maparg.noremap || stridx(keys, s:evaluate_keyseq(maparg.lhs)) == 0
        let s:noremap = len(keys)
      endif
      call feedkeys(keys)
      return g:pseudocl#MAP
    elseif !empty(s:mapcheck(join(s:keystrokes, '')))
      if s:prev_time == 0
        let s:prev_time = s:gettime()
      elseif s:gettime() - s:prev_time > timeout
        return s:cancel_map()
      endif
      let timeout = &timeoutlen
    else
      return s:cancel_map()
    endif
  endwhile
endfunction

function! s:k(ok)
  return get(s:remap, a:ok, a:ok)
endfunction

" Return:
"   - code
"   - cursor
"   - str
function! s:decode_char(c, str, cursor, words, history)
  let c       = a:c
  let str     = a:str
  let cursor  = a:cursor
  let matches = []

  try
    if c == s:k("\<S-Left>")
      let prefix = substitute(strpart(str, 0, cursor), '\s*$', '', '')
      let pos = match(prefix, '\S*$')
      if pos >= 0
        return [g:pseudocl#CONTINUE, str, pos]
      endif
    elseif c == s:k("\<S-Right>")
      let begins = len(matchstr(strpart(str, cursor), '^\s*'))
      let pos = match(str, '\s', cursor + begins + 1)
      return [g:pseudocl#CONTINUE, str, pos == -1 ? len(str) : pos]
    elseif c == s:k("\<C-C>") || c == s:k("\<Esc>")
      return [g:pseudocl#EXIT, str, cursor]
    elseif c == s:k("\<C-A>") || c == s:k("\<Home>")
      let cursor = 0
    elseif c == s:k("\<C-E>") || c == s:k("\<End>")
      let cursor = len(str)
    elseif c == s:k("\<Return>")
      return [g:pseudocl#RETURN, str, cursor]
    elseif c == s:k("\<C-U>")
      let s:yanked = strpart(str, 0, cursor)
      let str = strpart(str, cursor)
      let cursor = 0
    elseif c == s:k("\<C-W>")
      let ostr = strpart(str, 0, cursor)
      let prefix = substitute(substitute(strpart(str, 0, cursor), '\s*$', '', ''), '\S*$', '', '')
      let s:yanked = strpart(ostr, len(prefix))
      let str = prefix . strpart(str, cursor)
      let cursor = len(prefix)
    elseif c == s:k("\<C-D>") || c == s:k("\<Del>")
      let prefix = strpart(str, 0, cursor)
      let suffix = substitute(strpart(str, cursor), '^.', '', '')
      let str = prefix . suffix
    elseif c == s:k("\<C-K>")
      let s:yanked = strpart(str, cursor)
      let str = strpart(str, 0, cursor)
    elseif c == s:k("\<C-Y>")
      let str = strpart(str, 0, cursor) . s:yanked . strpart(str, cursor)
      let cursor += len(s:yanked)
    elseif c == s:k("\<C-H>") || c  == s:k("\<BS>")
      if cursor == 0 && empty(str)
        return [g:pseudocl#EXIT, str, cursor]
      endif
      let prefix = substitute(strpart(str, 0, cursor), '.$', '', '')
      let str = prefix . strpart(str, cursor)
      let cursor = len(prefix)
    elseif c == s:k("\<C-B>") || c == s:k("\<Left>")
      let cursor = len(substitute(strpart(str, 0, cursor), '.$', '', ''))
    elseif c == s:k("\<C-F>") || c == s:k("\<Right>")
      if cursor == len(str)
        return [g:pseudocl#CTRL_F, str, cursor]
      endif
      let cursor += len(matchstr(strpart(str, cursor), '^.'))
    elseif len(a:history) > 1 && (
         \ c == s:k("\<C-N>")    || c == s:k("\<C-P>")      ||
         \ c == s:k("\<Up>")     || c == s:k("\<Down>")     ||
         \ c == s:k("\<PageUp>") || c == s:k("\<PageDown>") ||
         \ c == s:k("\<S-Up>")   || c == s:k("\<S-Down>"))
      let s:history_idx = (c == s:k("\<C-N>")    || c == s:k("\<PageDown>") ||
                         \ c == s:k("\<S-Down>") || c == s:k("\<Down>")) ?
            \ min([s:history_idx + 1, len(a:history) - 1]) :
            \ max([s:history_idx - 1, 0])
      if s:history_idx < len(a:history)
        let line = a:history[s:history_idx]
        return [g:pseudocl#CONTINUE, line, len(line)]
      end
    elseif !empty(a:words) && (c == s:k("\<Tab>") || c == s:k("\<S-Tab>"))
      let before  = strpart(str, 0, cursor)
      let matches = get(s:, 'matches', pseudocl#complete#match(before, a:words))

      if !empty(matches)
        if c == s:k("\<Tab>")
          let matches = extend(copy(matches[1:-1]), matches[0:0])
        else
          let matches = extend(copy(matches[-1:-1]), matches[0:-2])
        endif
        let item   = matches[0]
        let str    = item . strpart(str, cursor)
        let cursor = len(item)
      endif
    elseif c == s:k("\<C-R>")
      let reg = nr2char(getchar())

      let text = ''
      if reg == s:k("\<C-W>")
        let text = expand('<cword>')
      elseif reg == s:k("\<C-A>")
        let text = expand('<cWORD>')
      elseif reg == "="
        let text = eval(s:input('=', ''))
      elseif reg =~ '[a-zA-Z0-9"/%#*+:.-]'
        let text = getreg(reg)
      end
      if !empty(text)
        let str = strpart(str, 0, cursor) . text . strpart(str, cursor)
        let cursor += len(text)
      endif
    elseif c == s:k("\<C-V>") || c =~ '[[:print:]]' && c[0] !~ nr2char(128)
      if c == s:k("\<C-V>")
        let c = nr2char(getchar())
      endif
      let str = strpart(str, 0, cursor) . c . strpart(str, cursor)
      let cursor += len(c)
    else
      return [c, str, cursor]
    endif

    call remove(a:history, -1)
    call add(a:history, str)
    let s:history_idx = len(a:history) - 1
    return [g:pseudocl#CONTINUE, str, cursor]
  finally
    if empty(matches)
      unlet! s:matches
    else
      let s:matches = matches
    endif
  endtry
endfunction

let &cpo = s:cpo_save
unlet s:cpo_save

