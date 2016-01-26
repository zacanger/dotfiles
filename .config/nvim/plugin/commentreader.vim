if exists('g:commentreader_loaded') || !has('python')
    finish
endif
let g:commentreader_loaded = 1

" parser user-define options
if !exists('g:creader_chars_per_line')
    let g:creader_chars_per_line = 20
endif
if !exists('g:creader_lines_per_block')
    let g:creader_lines_per_block = 5
endif
if !exists('g:creader_debug_mode')
    let g:creader_debug_mode = 0
endif
if !exists('g:creader_log_file')
    let g:creader_log_file = '/var/tmp/creader.log'
endif
if !exists('g:creader_session_file')
    let g:creader_session_file = $HOME.'/.vim_creader_session'
endif
if !exists('g:creader_auto_save')
    let g:creader_auto_save = 1
endif

" define commands
command! -nargs=? -complete=file CRopenbook    call commentreader#CRopenbook('<args>')
command! -nargs=?                CRopenweibo   call commentreader#CRopenweibo('<args>')
command! -nargs=?                CRopentwitter call commentreader#CRopentwitter('<args>')
command! -nargs=0                CRtoggle      call commentreader#CRtoggle()
command! -nargs=0                CRrefresh     call commentreader#CRrefresh()
command! -nargs=0                CRshow        call commentreader#CRshow()
command! -nargs=0                CRhide        call commentreader#CRhide()
command! -nargs=0                CRclose       call commentreader#CRclose()
command! -nargs=0                CRforward     call commentreader#CRforward()
command! -nargs=0                CRbackward    call commentreader#CRbackward()
command! -nargs=0                CRnext        call commentreader#CRnext()
command! -nargs=0                CRprevious    call commentreader#CRprevious()
command! -nargs=0                CRsave        call commentreader#CRsavesession()

" define autocommands
augroup CommentReader
    autocmd!
    if g:creader_auto_save == 1
        autocmd VimLeavePre * nested CRsave
    endif
augroup END
