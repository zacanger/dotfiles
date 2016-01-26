" Matcher {{{
let s:save_cpo = &cpo
set cpo&vim

let s:matcher = {
      \ 'name' : 'matcher_codesearch',
      \ 'description' : 'codesearch matcher',
      \}

function! unite#filters#matcher_codesearch#define() "{{{
  return s:matcher
endfunction"}}}

function! s:matcher.filter(candidates, context) "{{{
  return a:candidates
endfunction"}}}

function! unite#filters#matcher_codesearch#get() "{{{
  " No-op
  return []
endfunction"}}}

function! unite#filters#matcher_codesearch#use(matchers) "{{{
  " No-op. Don't break me.
endfunction"}}}

let &cpo = s:save_cpo
unlet s:save_cpo

" }}}
" vim: set et fdm=marker fenc=utf-8 ff=unix foldmethod=marker ft=vim sts=0 sw=2 ts=2 :
