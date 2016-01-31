"
" cduan.vim
"
" Color scheme--for me!!!
"

set background=dark
hi clear
if exists("syntax_on")
  syntax reset
endif
let g:colors_name = "cduan"
hi Comment	term=none	ctermfg=gray	guifg=Gray
hi Constant	term=underline	ctermfg=cyan	guifg=Cyan
hi Identifier	term=underline	ctermfg=green	guifg=Yellow
hi Statement	term=bold	ctermfg=white	guifg=White
hi PreProc	term=underline	ctermfg=magenta	guifg=Magenta
hi Type		term=underline	ctermfg=white	guifg=White
hi Special	term=bold	ctermfg=blue	guifg=#7f7fff
hi Nontext	term=bold	ctermfg=red	guifg=Red
hi Normal	guifg=Yellow	guibg=#00005F
hi Normal	ctermfg=darkgreen


hi Comment      cterm=none	gui=none
hi Constant     cterm=bold	gui=none
hi Identifier   cterm=none	gui=none
hi Statement    cterm=bold	gui=bold
hi PreProc      cterm=bold	gui=bold
hi Type         cterm=bold	gui=bold
hi Special      cterm=bold	gui=none
hi NonText	cterm=bold	gui=none

