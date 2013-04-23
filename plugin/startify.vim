" Plugin:      https://github.com/mhinz/vim-startify
" Description: Start screen displaying recently used stuff.
" Maintainer:  Marco Hinz <http://github.com/mhinz>
" Version:     0.5

if exists('g:loaded_startify') || &cp
  finish
endif
let g:loaded_startify = 1

" Init {{{1
let g:startify_session_dir = resolve(expand(get(g:, 'startify_session_dir', '~/.vim/session')))

command! -nargs=? -bar SSave call startify#save_session(<args>)
command! -nargs=? -bar SLoad call startify#load_session(<args>)

augroup startify
  autocmd!
  autocmd VimEnter *
        \ if !argc() && (line2byte('$') == -1) |
        \   call s:start() |
        \   call cursor(6, 5) |
        \endif
augroup END

" Function: s:start {{{1
function! s:start() abort
  setfiletype startify

  setlocal nonumber norelativenumber nobuflisted buftype=nofile

  let numfiles = get(g:, 'startify_show_files_number', 10)
  let cnt = 0

  call append('$', ['   startify>', '', '   [e]  <empty buffer>'])

  if get(g:, 'startify_show_files', 1) && !empty(v:oldfiles)
    call append('$', '')
    for fname in v:oldfiles
      if !filereadable(expand(fname)) || (fname =~# $VIMRUNTIME .'/doc') || (fname =~# 'bundle/.*/doc')
        continue
      endif
      call append('$', '   ['. cnt .']'. repeat(' ', 3 - strlen(string(cnt))) . fname)
      execute 'nnoremap <buffer> '. cnt .' :edit '. fname .'<cr>'
      let cnt += 1
      if cnt == numfiles
        break
      endif
    endfor
  endif

  let sfiles = split(globpath(g:startify_session_dir, '*'), '\n')

  if get(g:, 'startify_show_sessions', 1) && !empty(sfiles)
    call append('$', '')
    for i in range(len(sfiles))
      let idx = i + cnt
      call append('$', '   ['. idx .']'. repeat(' ', 3 - strlen(string(idx))) . fnamemodify(sfiles[i], ':t:r'))
      execute 'nnoremap <buffer> '. idx .' :source '. sfiles[i] .'<cr>'
    endfor
  endif

  call append('$', ['', '   [q]  quit'])

  setlocal nomodifiable

  nnoremap <buffer> q :quit<cr>
  nnoremap <buffer><silent> e :enew<cr>
  nnoremap <buffer><silent> <cr> :execute 'normal '. <c-r><c-w><cr>

  autocmd! startify *
  autocmd startify CursorMoved <buffer> call cursor(line('.') < 4 ? 4 : 0, 5)
  autocmd startify BufLeave <buffer> autocmd! startify *
endfunction

" vim: et sw=2 sts=2