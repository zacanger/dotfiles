if exists('g:commentreader_loaded') || !has('python')
    finish
endif
let g:commentreader_loaded = 1

" TODO
" need to verify python runtime enviroment?
" load Python script
let pyfile = expand('<sfile>:r') . '.py'
exe 'pyfile' pyfile

if !exists('g:creader_chars_per_line')
    let g:creader_chars_per_line = 20
endif
if !exists('g:creader_lines_per_block')
    let g:creader_lines_per_block = 5
endif

function! s:CRopen(path)
    python CRopen(vim.eval('a:path'))
endfunction

function! s:CRnextpage()
    python CRnextpage()
endfunction

function! s:CRprepage()
    python CRprepage()
endfunction

function! s:CRclear()
    python CRclear()
endfunction

function! s:CRnextblock()
    python CRnextblock()
endfunction

function! s:CRpreblock()
    python CRpreblock()
endfunction

command! -nargs=1 -complete=file CRopen      call s:CRopen('<args>')
command! -nargs=0                CRnextpage  call s:CRnextpage()
command! -nargs=0                CRprepage   call s:CRprepage()
command! -nargs=0                CRclear     call s:CRclear()
command! -nargs=0                CRnextblock call s:CRnextblock()
command! -nargs=0                CRpreblock  call s:CRpreblock()

nnoremap <silent> <leader>d :CRnextpage<CR>
nnoremap <silent> <leader>a :CRprepage<CR>
nnoremap <silent> <leader>w :CRpreblock<CR>
nnoremap <silent> <leader>s :CRnextblock<CR>
