" =============================================================================
" Filename: autoload/lightryanline/tab.vim
" Author: itchyny
" License: MIT License
" Last Change: 2016/05/07 22:31:02.
" =============================================================================

let s:save_cpo = &cpo
set cpo&vim

function! lightryanline#tab#filename(n) abort
  let buflist = tabpagebuflist(a:n)
  let winnr = tabpagewinnr(a:n)
  let _ = expand('#'.buflist[winnr - 1].':t')
  return _ !=# '' ? _ : '[No Name]'
endfunction

function! lightryanline#tab#modified(n) abort
  let winnr = tabpagewinnr(a:n)
  return gettabwinvar(a:n, winnr, '&modified') ? '+' : gettabwinvar(a:n, winnr, '&modifiable') ? '' : '-'
endfunction

function! lightryanline#tab#readonly(n) abort
  let winnr = tabpagewinnr(a:n)
  return gettabwinvar(a:n, winnr, '&readonly') ? 'RO' : ''
endfunction

function! lightryanline#tab#tabnum(n) abort
  return a:n
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
