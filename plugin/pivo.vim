" BEGIN
if exists("g:loaded_pivo") || &cp
  finish
endif
let g:loaded_pivo = 1
let s:keepcpo     = &cpo
set cpo&vim

let PivoBufferName = "__Pivotal__"

function! s:PivoBufferOpen()
    " Check whether the scratch buffer is already created
    let scr_bufnum = bufnr(g:PivoBufferName)
    if scr_bufnum == -1
        " open a new scratch buffer
        exe "new " . g:PivoBufferName
    else
        " Pivo buffer is already created,
        " check whether it is open in one of the windows.
        let scr_winnum = bufwinnr(scr_bufnum)
        if scr_winnum != -1
            " Jump to the window which has the scratch buffer if we are not
            " already in that window
            if winnr() != scr_winnum
                exe scr_winnum . "wincmd w"
            endif
        else
            " Create a new scratch buffer
            exe "split +buffer" . scr_bufnum
        endif
    endif
endfunction

command! -nargs=0 Pivo call s:PivoBufferOpen()

" END
let &cpo= s:keepcpo
unlet s:keepcpo
