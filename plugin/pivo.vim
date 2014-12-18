if exists("g:loaded_pivo") || &cp
  finish
endif
let g:loaded_pivo = 1
let s:keepcpo   = &cpo
set cpo&vim

let PivoBufferName = "__Pivotal__"

let current_dir = expand('<sfile>:p:h')

let cmd_begin         = 'ruby ' . current_dir . '/pivo.rb '
let cmd_end           = ' ' . shellescape(PivoApiToken) . ' ' . shellescape(PivoProjectId) . ' '
let cmd_print_stories = cmd_begin . 'print_stories' . cmd_end
let cmd_start         = cmd_begin . 'start' . cmd_end
let cmd_finish        = cmd_begin . 'finish' . cmd_end
let cmd_deliver       = cmd_begin . 'deliver' . cmd_end
let cmd_accept        = cmd_begin . 'accept' . cmd_end
let cmd_reject        = cmd_begin . 'reject' . cmd_end

let cmdPivoId = "cat /tmp/current_pivo.id | tr -d '\n'"

function! s:GetPivoId()
  let g:PivoId = system(g:cmdPivoId)
endfunction

function! g:PivoStart()
  let current_id = g:GetIdFromCurrentLineWithoutHash()
  let cmd_start = g:cmd_start . "'" . current_id . "'"

  s/\[...]/\[ f ]/e
  Dispatch! cmd_start
endfunction

function! g:PivoFinish()
  let current_id = g:GetIdFromCurrentLineWithoutHash()
  let cmd_finish = g:cmd_finish . "'" . current_id . "'"

  s/\[...]/\[ d ]/e
  Dispatch! cmd_finish
endfunction

function! g:PivoDeliver()
  let current_id = g:GetIdFromCurrentLineWithoutHash()
  let cmd_deliver = g:cmd_deliver . "'" . current_id . "'"

  s/\[...]/\[a\/r]/e
  Dispatch! cmd_deliver
endfunction

function! g:PivoAccept()
  let current_id = g:GetIdFromCurrentLineWithoutHash()
  let cmd_accept = g:cmd_accept . "'" . current_id . "'"

  s/\[...]/\[ \+ ]/e
  Dispatch! cmd_accept
endfunction

function! g:PivoReject()
  let current_id = g:GetIdFromCurrentLineWithoutHash()
  let cmd_reject = g:cmd_reject . "'" . current_id . "'"

  s/\[...]/\[\-s\-/e
  Dispatch! cmd_reject
endfunction

function! g:GetIdFromCurrentLineWithoutHash()
  let line = getline(".")
  let line2 = substitute(line, '^.*[#', '', 'g')
  let repl = substitute(line2, '].*$', '', 'g')
  setlocal noreadonly
  execute "%s/*/ /ge"
  call search(repl)
  execute "s/  /\* /e"
  setlocal readonly
  return repl
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
  "TODO: make it work? and maybe use the Vim way?
  if finddir('.git', '.') != '.git'
    echo 'Could not find .git directory'
    return 1
  endif
  let cmdIndiana = "cp " . g:current_dir . "/pv-prepare-commit-msg.rb .git/hooks/prepare-commit-msg"
  call system(cmdIndiana)
  call system('chmod 0755 .git/hooks/prepare-commit-msg')
  echo 'Git hook attached'
endfunction

function! s:PivoDetach()
  if finddir('.git', '.') != '.git'
    echo 'Cound not find .git directory'
    return 1
  endif
  call system('rm .git/hooks/prepare-commit-msg')
  echo 'Git hook removed'
endfunction

function! s:PivoInsert()
  " Insert current PivoId to the current buffer
  call s:GetPivoId()
  " Put without newline!
  put =g:PivoId
endfunction

command! -nargs=0 Pivo call s:PivoBufferOpen()
command! -nargs=0 PivoInsert call s:PivoInsert()
"TODO: better name for Indiana
command! -nargs=0 PivoIndianaJones call s:PivoIndianaJohnes()
command! -nargs=0 PivoDetach call s:PivoDetach()

" PRIVATE

function! s:SetPivoConnection()
  let storiesOutput = system(g:cmd_print_stories)
  call append(line('$'), split(storiesOutput, "\n"))
endfunction

function! s:UpdateCurrentPivoIdDisplay()
  call s:GetPivoId()
  call search(g:PivoId)
  execute "s/  /\* /e"
endfunction

function! g:SetCurrentPivoId()
  let line = getline(".")
  let line2 = substitute(line, '^.*[', '', 'g')
  let repl = substitute(line2, '].*$', '', 'g')
  setlocal noreadonly
  execute "%s/*/ /ge"
  call search(repl)
  execute "s/  /\* /e"
  setlocal readonly
  let cmd1 = "echo \[" . shellescape(repl) . "\] > /tmp/current_pivo.id"
  Dispatch! cmd1
endfunction

function! s:SetPivoBuffer()
  nnoremap <buffer> q :quit<CR>

  "TODO: Change 'c' to '-' -> fugitive way
  nnoremap <buffer> c :call g:SetCurrentPivoId()<CR>

  nnoremap <buffer> s :call g:PivoStart()<CR>
  nnoremap <buffer> f :call g:PivoFinish()<CR>
  nnoremap <buffer> d :call g:PivoDeliver()<CR>
  nnoremap <buffer> a :call g:PivoAccept()<CR>
  nnoremap <buffer> r :call g:PivoReject()<CR>
  setlocal nowrap
  setlocal nonumber
  setlocal buftype=nofile
  setlocal bufhidden=hide
  setlocal noswapfile
  call s:set_buffer_uneditable()
endfunction

function! s:set_buffer_editable()
  " setlocal modifiable
  setlocal noreadonly
endfunction

function! s:set_buffer_uneditable()
  " setlocal nomodifiable
  setlocal readonly
endfunction

function! s:SetupPivo()
  call s:SetPivoConnection()
  call s:UpdateCurrentPivoIdDisplay()
  call s:SetPivoBuffer()
endfunction
autocmd BufNewFile __Pivotal__ call s:SetupPivo()

"TODO: Fix and use in Connection
function! s:pivotal_settings_set()
  if g:PivoProjectId != 0 && g:PivoApiToken != 0
    return 1
  else
    return 0
  endif
endfunction

let &cpo= s:keepcpo
unlet s:keepcpo
