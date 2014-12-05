" BEGIN
if exists("g:loaded_pivo") || &cp
  finish
endif
let g:loaded_pivo = 1
let s:keepcpo     = &cpo
set cpo&vim

let PivoBufferName = "__Pivotal__"

let currentDir = expand('<sfile>:p:h')
"let cmdListStories = 'ruby ' . shellescape(currentDir) . '/pivo.rb print_stories ' . shellescape(PivoApiToken) . ' ' . shellescape(PivoProjectId)
let cmdListStories = "cat ~/netguru/vim_pivo/pivo_mock"
let cmdPivoId = "cat /tmp/current_pivo.id | tr -d '\n'"

" PUBLIC
"
function! s:GetPivoId()
    let g:PivoId = system(g:cmdPivoId)
endfunction

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

function! s:PivoIndianaJohnes()
	let cmdIndiana = "cp " . g:currentDir . "/pivo_on.sh ~/netguru/vim_pivo/.git/hooks/prepare-commit-msg"
	echo cmdIndiana
	let ret = system(cmdIndiana)
endfunction

function! s:PivoDetach()
	let ret = system("rm ~/netguru/vim_pivo/.git/hooks/prepare-commit-msg")
endfunction

function! s:PivoInsert()
    " Insert current PivoId to the current buffer
    call s:GetPivoId()
    put =g:PivoId
endfunction

command! -nargs=0 Pivo call s:PivoBufferOpen()
command! -nargs=0 PivoInsert call s:PivoInsert()
command! -nargs=0 PivoIndianaJones call s:PivoIndianaJohnes()
command! -nargs=0 PivoDetach call s:PivoDetach()

" PRIVATE

function! s:SetPivoConnection()
	let storiesOutput = system(g:cmdListStories)
	call append(line('$'), split(storiesOutput, "\n"))
endfunction

function! s:UpdateCurrentPivoIdDisplay()
    call s:GetPivoId()
    call search(g:PivoId)
    execute "s/  /\* /"
endfunction

function! g:SetCurrentPivoId()
    let line = getline(".")
    let line2 = substitute(line, '^.*[', '', 'g')
    let repl = substitute(line2, '].*$', '', 'g')
    setlocal modifiable
    execute "%s/*/ /g"
    call search(repl)
    execute "s/  /\* /"
    setlocal readonly
    let cmd1 = "echo \[" . shellescape(repl) . "\] > /tmp/current_pivo.id"
    call system(cmd1)
endfunction

function! s:SetPivoBuffer()
    nnoremap <buffer> q :quit<CR>
    nnoremap <buffer> c :call g:SetCurrentPivoId()<CR>
    setlocal nowrap
    setlocal nonumber
    setlocal readonly
    setlocal buftype=nofile
    setlocal bufhidden=hide
    setlocal noswapfile
endfunction

function! s:SetupPivo()
    call s:SetPivoConnection()
    call s:UpdateCurrentPivoIdDisplay()
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
