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

function! pseudocl#complete#extract_words(content)
  let dict = {}
  for word in split(a:content, '\W\+')
    let dict[word] = 1
  endfor
  return sort(keys(dict))
endfunction

function! pseudocl#complete#match(prefix, words)
  let started = 0
  let matches = [a:prefix]
  let tokens = matchlist(a:prefix, '^\(.\{-}\)\(\w*\)$')
  let [prefix, suffix] = tokens[1 : 2]
  for word in a:words
    if stridx(word, suffix) == 0 && len(word) > len(suffix)
      call add(matches, prefix . word)
      let started = 1
    elseif started
      break
    end
  endfor
  return matches
endfunction

let &cpo = s:cpo_save
unlet s:cpo_save
