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

let g:pseudocl#MAP      = -1
let g:pseudocl#RETURN   = -2
let g:pseudocl#CONTINUE = -3
let g:pseudocl#UNKNOWN  = -4
let g:pseudocl#EXIT     = -5
let g:pseudocl#CTRL_F   = -6

function! pseudocl#nop(...)
  return extend([g:pseudocl#CONTINUE], a:000[1:])
endfunction

let s:default_opts = {
  \ 'prompt':         ':',
  \ 'history':        [],
  \ 'words':          [],
  \ 'input':          '',
  \ 'highlight':      'None',
  \ 'remap':          {},
  \ 'map':            1,
  \ 'renderer':       function('pseudocl#render#echo'),
  \ 'on_change':      function('pseudocl#nop'),
  \ 'on_event':       function('pseudocl#nop'),
  \ 'on_unknown_key': function('pseudocl#nop')
  \ }

function! pseudocl#start(opts) range
  let s:current = extend(copy(s:default_opts), a:opts)
  let s:current.cursor = len(s:current.input)
  return pseudocl#render#loop(s:current)
endfunction

function! pseudocl#get_prompt()
  return s:current.prompt
endfunction

function! pseudocl#set_prompt(new_prompt)
  let s:current.prompt = a:new_prompt
endfunction

if !s:default_opts.renderer
  function! pseudocl#default_renderer(...)
    return call('pseudocl#render#echo', a:000)
  endfunction

  let s:default_opts.renderer = function('pseudocl#default_renderer')
endif

let &cpo = s:cpo_save
unlet s:cpo_save
