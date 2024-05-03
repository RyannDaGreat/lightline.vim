let s:suite = themis#suite('mode')
let s:assert = themis#helper('assert')

function! s:suite.mode()
  let g:lightryanline = {}
  call lightryanline#init()
  call s:assert.equals(lightryanline#mode(), 'NORMAL')
endfunction

function! s:suite.mode_map()
  let g:lightryanline = { 'mode_map': { 'n': 'N' } }
  call lightryanline#init()
  call s:assert.equals(lightryanline#mode(), 'N')
endfunction
