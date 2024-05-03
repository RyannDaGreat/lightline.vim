let s:suite = themis#suite('tabline')
let s:assert = themis#helper('assert')

function! s:suite.before_each()
  let g:lightryanline = {}
  call lightryanline#init()
  tabnew
  tabonly
endfunction

function! s:suite.tabline()
  call s:assert.equals(&tabline, '%!lightryanline#tabline()')
endfunction

function! s:suite.enabled()
  let g:lightryanline = { 'enable': { 'tabline': 1 } }
  call lightryanline#init()
  call s:assert.equals(&tabline, '%!lightryanline#tabline()')
endfunction

function! s:suite.disabled()
  let g:lightryanline = { 'enable': { 'tabline': 0 } }
  call lightryanline#init()
  call s:assert.equals(&tabline, '')
endfunction

function! s:suite.tabnew()
  let tabline = lightryanline#tabline()
  tabnew
  call s:assert.not_equals(lightryanline#tabline(), tabline)
endfunction

function! s:suite.tabnew_first()
  let tabline = lightryanline#tabline()
  0tabnew
  call s:assert.not_equals(lightryanline#tabline(), tabline)
endfunction

function! s:suite.tabnext()
  tabnew
  let tabline = lightryanline#tabline()
  tabnext
  call s:assert.not_equals(lightryanline#tabline(), tabline)
endfunction

function! s:suite.tabonly()
  tabnew
  tabfirst
  let tabline = lightryanline#tabline()
  tabonly
  call s:assert.not_equals(lightryanline#tabline(), tabline)
endfunction

function! s:suite.tabclose()
  tabnew
  let tabline = lightryanline#tabline()
  tabclose
  call s:assert.not_equals(lightryanline#tabline(), tabline)
endfunction

function! s:suite.tabclose_last()
  tabnew
  tabfirst
  let tabline = lightryanline#tabline()
  $tabclose
  call s:assert.not_equals(lightryanline#tabline(), tabline)
endfunction
