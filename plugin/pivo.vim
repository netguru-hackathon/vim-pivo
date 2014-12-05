" BEGIN
if exists("g:loaded_VimPivo") || &cp
  finish
endif
let g:loaded_VimPivo = 1
let s:keepcpo        = &cpo
set cpo&vim

" END
let &cpo= s:keepcpo
unlet s:keepcpo
