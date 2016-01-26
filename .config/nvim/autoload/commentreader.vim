" import vim
python import vim

" import oauth2
let libpath = substitute(expand('<sfile>:p:r'), 'commentreader$', 'lib', '')
python sys.path.append(vim.eval('libpath'))
python module = __import__('oauth2')
python del sys.path[-1]

" load commentreader.py
let pyfile = expand('<sfile>:r') . '.py'
exe 'pyfile' pyfile

" define functions
function! commentreader#CRopenbook(path)
    python CRopen(vim.eval("bufnr('')"), 'Book', vim.eval('a:path'))
endfunction

function! commentreader#CRopenweibo(auth_code)
    python CRopen(vim.eval("bufnr('')"), 'Weibo', vim.eval('a:auth_code'))
endfunction

function! commentreader#CRopendouban()
    python CRopen(vim.eval("bufnr('')"), 'Douban')
endfunction

function! commentreader#CRopentwitter(PIN)
    python CRopen(vim.eval("bufnr('')"), 'Twitter', vim.eval('a:PIN'))
endfunction

function! commentreader#CRclose()
    python CRclose(vim.eval("bufnr('')"))
endfunction

function! commentreader#CRtoggle()
    python CRoperation(vim.eval("bufnr('')"), 'toggle')
endfunction

function! commentreader#CRshow()
    python CRoperation(vim.eval("bufnr('')"), 'show')
endfunction

function! commentreader#CRhide()
    python CRoperation(vim.eval("bufnr('')"), 'hide')
endfunction

function! commentreader#CRforward()
    python CRoperation(vim.eval("bufnr('')"), 'forward')
endfunction

function! commentreader#CRbackward()
    python CRoperation(vim.eval("bufnr('')"), 'backward')
endfunction

function! commentreader#CRnext()
    python CRoperation(vim.eval("bufnr('')"), 'next')
endfunction

function! commentreader#CRprevious()
    python CRoperation(vim.eval("bufnr('')"), 'previous')
endfunction

function! commentreader#CRrefresh()
    python CRoperation(vim.eval("bufnr('')"), 'refresh')
endfunction

function! commentreader#CRsavesession()
    python CRoperation(vim.eval("bufnr('')"), 'saveSession')
endfunction
