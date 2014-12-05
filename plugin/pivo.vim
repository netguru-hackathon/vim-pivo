" BEGIN
if exists("g:loaded_pivo") || &cp
  finish
endif
let g:loaded_pivo = 1
let s:keepcpo     = &cpo
set cpo&vim

let PivoBufferName = "__Pivotal__"
let PivoProjectId  = 0
let PivoApiToken   = 0

function! s:PivoBufferOpen()
    " Check whether the buffer is already created
    let pivo_bufnum = bufnr(g:PivoBufferName)
    if pivo_bufnum == -1
        " open a new buffer
        exe "new " . g:PivoBufferName
    else
        " Pivo buffer is already created,
        " check whether it is open in one of the windows.
        let pivo_winnum = bufwinnr(pivo_bufnum)
        if pivo_winnum != -1
            " Jump to the window which has the buffer if we are not
            " already in that window
            if winnr() != pivo_winnum
                exe pivo_winnum . "wincmd w"
            endif
        else
            " Create a new Pivo buffer
            exe "split +buffer" . pivo_bufnum
        endif
    endif
endfunction

function! s:SetPivoBuffer()
    nnoremap <buffer> q :quit<CR>
endfunction
autocmd BufNewFile __Pivotal__ call s:SetPivoBuffer()

command! -nargs=0 Pivo call s:PivoBufferOpen()

" END
let &cpo= s:keepcpo
unlet s:keepcpo
