" =============================================================================
" Filename: plugin/lightryanline.vim
" Author: itchyny
" License: MIT License
" Last Change: 2021/11/21 22:54:41.
" =============================================================================

if exists('g:loaded_lightryanline') || v:version < 703
  finish
endif
let g:loaded_lightryanline = 1

let s:save_cpo = &cpo
set cpo&vim

augroup lightryanline
  autocmd!
  autocmd WinEnter,BufEnter,SessionLoadPost,FileChangedShellPost * call lightryanline#update()
  if !has('patch-8.1.1715')
    autocmd FileType qf call lightryanline#update()
  endif
  autocmd SessionLoadPost * call lightryanline#highlight()
  autocmd ColorScheme * if !has('vim_starting') || expand('<amatch>') !=# 'macvim'
        \ | call lightryanline#update() | call lightryanline#highlight() | endif
augroup END

" This quickfix option was introduced at Vim 85850f3a5ef9, which is the commit
" just before 8.1.1715. Before this patch, autocmd FileType is required to
" overwrite the statusline of the quickfix and location windows.
let g:qf_disable_statusline = 1

let &cpo = s:save_cpo
unlet s:save_cpo
