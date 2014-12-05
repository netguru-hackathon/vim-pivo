" BEGIN
if exists("g:loaded_pivo") || &cp
  finish
endif
let g:loaded_pivo = 1
let s:keepcpo     = &cpo
set cpo&vim

let PivoBufferName = "__Pivotal__"

let currentDir = expand('<sfile>:p:h')
let cmdListStories = 'ruby ' . shellescape(currentDir) . '/pivo.rb print_stories ' . shellescape(PivoApiToken) . ' ' . shellescape(PivoProjectId)
let cmdPivoId = "cat /tmp/current_pivo.id | tr -d '\n'"

" PUBLIC

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

command! -nargs=0 Pivo call s:PivoBufferOpen()

" PRIVATE

function! s:SetPivoConnection()
	let storiesOutput = system(g:cmdListStories)
	call append(line('$'), split(storiesOutput, "\n"))
endfunction

function! s:SetPivoBuffer()
    nnoremap <buffer> q :quit<CR>
    setlocal nowrap
    setlocal nonumber
    setlocal readonly
    setlocal buftype=nofile
    setlocal bufhidden=hide
    setlocal noswapfile
endfunction

function! s:GetPivoId()
    let g:PivoId = system(g:cmdPivoId)
    /g:PivoId
    execute "%s/  /\* /g"
endfunction

function! s:SetupPivo()
    call s:SetPivoConnection()
    call s:GetPivoId()
    call s:SetPivoBuffer()
endfunction
autocmd BufNewFile __Pivotal__ call s:SetupPivo()

function! s:pivotal_settings_set()
    if g:PivoProjectId != 0 && g:PivoApiToken != 0
        return 1
    else
        return 0
    endif
endfunction

" END
let &cpo= s:keepcpo
unlet s:keepcpo
