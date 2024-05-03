let s:suite = themis#suite('toggle')
let s:assert = themis#helper('assert')

function! s:suite.before_each()
  let g:lightryanline = {}
  call lightryanline#init()
  tabnew
  tabonly
endfunction

function! s:suite.default()
  call s:assert.equals(exists('#lightryanline'), 1)
  call s:assert.equals(exists('#lightryanline-disable'), 0)
  call s:assert.not_equals(&statusline, '')
  call s:assert.not_equals(&tabline, '')
endfunction

function! s:suite.disable_enable()
  call lightryanline#disable()
  call s:assert.equals(exists('#lightryanline'), 0)
  call s:assert.equals(exists('#lightryanline-disable'), 1)
  call s:assert.equals(&statusline, '')
  call s:assert.equals(&tabline, '')
  call lightryanline#update()
  call s:assert.equals(&statusline, '')
  call s:assert.equals(&tabline, '')
  call lightryanline#enable()
  call s:assert.equals(exists('#lightryanline'), 1)
  call s:assert.equals(exists('#lightryanline-disable'), 0)
  call s:assert.not_equals(&statusline, '')
  call s:assert.not_equals(&tabline, '')
  call lightryanline#disable()
  call lightryanline#disable()
  call lightryanline#enable()
  call lightryanline#enable()
  call s:assert.equals(exists('#lightryanline'), 1)
  call s:assert.equals(exists('#lightryanline-disable'), 0)
endfunction

function! s:suite.toggle()
  call lightryanline#toggle()
  call s:assert.equals(exists('#lightryanline'), 0)
  call s:assert.equals(exists('#lightryanline-disable'), 1)
  call s:assert.equals(&statusline, '')
  call s:assert.equals(&tabline, '')
  call lightryanline#toggle()
  call s:assert.equals(exists('#lightryanline'), 1)
  call s:assert.equals(exists('#lightryanline-disable'), 0)
  call s:assert.not_equals(&statusline, '')
  call s:assert.not_equals(&tabline, '')
endfunction
