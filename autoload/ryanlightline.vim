" =============================================================================
" Filename: autoload/lightryanline.vim
" Author: itchyny
" License: MIT License
" Last Change: 2021/11/21 22:54:46.
" =============================================================================

let s:save_cpo = &cpo
set cpo&vim

let s:_ = 1 " 1: uninitialized, 2: disabled

function! lightryanline#update() abort
  if s:skip() | return | endif
  if s:_
    if s:_ == 2 | return | endif
    call lightryanline#init()
    call lightryanline#colorscheme()
  endif
  if s:lightryanline.enable.statusline
    let w = winnr()
    let s = winnr('$') == 1 && w > 0 ? [lightryanline#statusline(0)] : [lightryanline#statusline(0), lightryanline#statusline(1)]
    for n in range(1, winnr('$'))
      call setwinvar(n, '&statusline', s[n!=w])
    endfor
  endif
endfunction

if exists('*nvim_win_get_config')
  function! s:skip() abort
    return !nvim_win_get_config(0).focusable
  endfunction
elseif exists('*win_gettype')
  function! s:skip() abort " Vim 8.2.0257 (00f3b4e007), 8.2.0991 (0fe937fd86), 8.2.0996 (40a019f157)
    return win_gettype() ==# 'popup' || win_gettype() ==# 'autocmd'
  endfunction
else
  function! s:skip() abort
    return &buftype ==# 'popup'
  endfunction
endif

function! lightryanline#update_disable() abort
  if s:lightryanline.enable.statusline
    call setwinvar(0, '&statusline', '')
  endif
endfunction

function! lightryanline#enable() abort
  let s:_ = 1
  call lightryanline#update()
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
  augroup lightryanline-disable
    autocmd!
  augroup END
  augroup! lightryanline-disable
endfunction

function! lightryanline#disable() abort
  let [&statusline, &tabline] = [get(s:, '_statusline', ''), get(s:, '_tabline', '')]
  for t in range(1, tabpagenr('$'))
    for n in range(1, tabpagewinnr(t, '$'))
      call settabwinvar(t, n, '&statusline', '')
    endfor
  endfor
  augroup lightryanline
    autocmd!
  augroup END
  augroup! lightryanline
  augroup lightryanline-disable
    autocmd!
    autocmd WinEnter * call lightryanline#update_disable()
  augroup END
  let s:_ = 2
endfunction

function! lightryanline#toggle() abort
  if exists('#lightryanline')
    call lightryanline#disable()
  else
    call lightryanline#enable()
  endif
endfunction

let s:_lightryanline = {
      \   'active': {
      \     'left': [['mode', 'paste'], ['readonly', 'filename', 'modified']],
      \     'right': [['lineinfo'], ['percent'], ['fileformat', 'fileencoding', 'filetype']]
      \   },
      \   'inactive': {
      \     'left': [['filename']],
      \     'right': [['lineinfo'], ['percent']]
      \   },
      \   'tabline': {
      \     'left': [['tabs']],
      \     'right': [['close']]
      \   },
      \   'tab': {
      \     'active': ['tabnum', 'filename', 'modified'],
      \     'inactive': ['tabnum', 'filename', 'modified']
      \   },
      \   'component': {
      \     'mode': '%{lightryanline#mode()}',
      \     'absolutepath': '%F', 'relativepath': '%f', 'filename': '%t', 'modified': '%M', 'bufnum': '%n',
      \     'paste': '%{&paste?"PASTE":""}', 'readonly': '%R', 'charvalue': '%b', 'charvaluehex': '%B',
      \     'spell': '%{&spell?&spelllang:""}', 'fileencoding': '%{&fenc!=#""?&fenc:&enc}', 'fileformat': '%{&ff}',
      \     'filetype': '%{&ft!=#""?&ft:"no ft"}', 'percent': '%3p%%', 'percentwin': '%P',
      \     'lineinfo': '%3l:%-2c', 'line': '%l', 'column': '%c', 'close': '%999X X ', 'winnr': '%{winnr()}'
      \   },
      \   'component_visible_condition': {
      \     'modified': '&modified||!&modifiable', 'readonly': '&readonly', 'paste': '&paste', 'spell': '&spell'
      \   },
      \   'component_function': {},
      \   'component_function_visible_condition': {},
      \   'component_expand': {
      \     'tabs': 'lightryanline#tabs'
      \   },
      \   'component_type': {
      \     'tabs': 'tabsel', 'close': 'raw'
      \   },
      \   'component_raw': {},
      \   'tab_component': {},
      \   'tab_component_function': {
      \     'filename': 'lightryanline#tab#filename', 'modified': 'lightryanline#tab#modified',
      \     'readonly': 'lightryanline#tab#readonly', 'tabnum': 'lightryanline#tab#tabnum'
      \   },
      \   'colorscheme': 'default',
      \   'mode_map': {
      \     'n': 'NORMAL', 'i': 'INSERT', 'R': 'REPLACE', 'v': 'VISUAL', 'V': 'V-LINE', "\<C-v>": 'V-BLOCK',
      \     'c': 'COMMAND', 's': 'SELECT', 'S': 'S-LINE', "\<C-s>": 'S-BLOCK', 't': 'TERMINAL'
      \   },
      \   'separator': { 'left': '', 'right': '' },
      \   'subseparator': { 'left': '|', 'right': '|' },
      \   'tabline_separator': {},
      \   'tabline_subseparator': {},
      \   'enable': { 'statusline': 1, 'tabline': 1 },
      \   '_mode_': {
      \     'n': 'normal', 'i': 'insert', 'R': 'replace', 'v': 'visual', 'V': 'visual', "\<C-v>": 'visual',
      \     'c': 'command', 's': 'select', 'S': 'select', "\<C-s>": 'select', 't': 'terminal'
      \   },
      \   'mode_fallback': { 'replace': 'insert', 'terminal': 'insert', 'select': 'visual' },
      \   'palette': {},
      \ }
function! lightryanline#init() abort
  let s:lightryanline = deepcopy(get(g:, 'lightryanline', {}))
  for [key, value] in items(s:_lightryanline)
    if type(value) == 4
      if !has_key(s:lightryanline, key)
        let s:lightryanline[key] = {}
      endif
      call extend(s:lightryanline[key], value, 'keep')
    elseif !has_key(s:lightryanline, key)
      let s:lightryanline[key] = value
    endif
    unlet value
  endfor
  call extend(s:lightryanline.tabline_separator, s:lightryanline.separator, 'keep')
  call extend(s:lightryanline.tabline_subseparator, s:lightryanline.subseparator, 'keep')
  let s:lightryanline.tabline_configured = has_key(get(get(g:, 'lightryanline', {}), 'component_expand', {}), 'tabs')
  for components in deepcopy(s:lightryanline.tabline.left + s:lightryanline.tabline.right)
    if len(filter(components, 'v:val !=# "tabs" && v:val !=# "close"')) > 0
      let s:lightryanline.tabline_configured = 1
      break
    endif
  endfor
  if !exists('s:_statusline')
    let s:_statusline = &statusline
  endif
  if !exists('s:_tabline')
    let s:_tabline = &tabline
  endif
  if s:lightryanline.enable.tabline
    set tabline=%!lightryanline#tabline()
  else
    let &tabline = get(s:, '_tabline', '')
  endif
  for f in values(s:lightryanline.component_function)
    silent! call call(f, [])
  endfor
  for f in values(s:lightryanline.tab_component_function)
    silent! call call(f, [1])
  endfor
  let s:mode = ''
endfunction

function! lightryanline#colorscheme() abort
  try
    let s:lightryanline.palette = g:lightryanline#colorscheme#{s:lightryanline.colorscheme}#palette
  catch
    call lightryanline#error('Could not load colorscheme ' . s:lightryanline.colorscheme . '.')
    let s:lightryanline.colorscheme = 'default'
    let s:lightryanline.palette = g:lightryanline#colorscheme#{s:lightryanline.colorscheme}#palette
  finally
    if has('win32') && !has('gui_running') && &t_Co < 256
      call lightryanline#colortable#gui2cui_palette(s:lightryanline.palette)
    endif
    let s:highlight = {}
    call lightryanline#highlight('normal')
    call lightryanline#link()
    let s:_ = 0
  endtry
endfunction

function! lightryanline#palette() abort
  return s:lightryanline.palette
endfunction

function! lightryanline#mode() abort
  return get(s:lightryanline.mode_map, mode(), '')
endfunction

let s:mode = ''
function! lightryanline#link(...) abort
  let mode = get(s:lightryanline._mode_, a:0 ? a:1 : mode(), 'normal')
  if s:mode ==# mode
    return ''
  endif
  let s:mode = mode
  if !has_key(s:highlight, mode)
    call lightryanline#highlight(mode)
  endif
  let types = map(s:uniq(sort(filter(values(s:lightryanline.component_type), 'v:val !=# "raw"'))), '[v:val, 1]')
  for [p, l] in [['Left', len(s:lightryanline.active.left)], ['Right', len(s:lightryanline.active.right)]]
    for [i, t] in map(range(0, l), '[v:val, 0]') + types
      if i != l
        exec printf('hi link Lightline%s_active_%s Lightline%s_%s_%s', p, i, p, mode, i)
      endif
      for [j, s] in map(range(0, l), '[v:val, 0]') + types
        if i + 1 == j || t || s && i != l
          exec printf('hi link Lightline%s_active_%s_%s Lightline%s_%s_%s_%s', p, i, j, p, mode, i, j)
        endif
      endfor
    endfor
  endfor
  exec printf('hi link LightlineMiddle_active LightlineMiddle_%s', mode)
  return ''
endfunction

function! s:term(p) abort
  return get(a:p, 4) !=# '' ? 'term='.a:p[4].' cterm='.a:p[4].' gui='.a:p[4] : ''
endfunction

if exists('*uniq')
  let s:uniq = function('uniq')
else
  function! s:uniq(xs) abort
    let i = len(a:xs) - 1
    while i > 0
      if a:xs[i] ==# a:xs[i - 1]
        call remove(a:xs, i)
      endif
      let i -= 1
    endwhile
    return a:xs
  endfunction
endif

function! lightryanline#highlight(...) abort
  let [c, f] = [s:lightryanline.palette, s:lightryanline.mode_fallback]
  let [s:lightryanline.llen, s:lightryanline.rlen] = [len(c.normal.left), len(c.normal.right)]
  let [s:lightryanline.tab_llen, s:lightryanline.tab_rlen] = [len(has_key(get(c, 'tabline', {}), 'left') ? c.tabline.left : c.normal.left), len(has_key(get(c, 'tabline', {}), 'right') ? c.tabline.right : c.normal.right)]
  let types = map(s:uniq(sort(filter(values(s:lightryanline.component_type), 'v:val !=# "raw"'))), '[v:val, 1]')
  let modes = a:0 ? [a:1] : extend(['normal', 'insert', 'replace', 'visual', 'inactive', 'command', 'select', 'tabline'], exists(':terminal') == 2 ? ['terminal'] : [])
  for mode in modes
    let s:highlight[mode] = 1
    let d = has_key(c, mode) ? mode : has_key(f, mode) && has_key(c, f[mode]) ? f[mode] : 'normal'
    let left = d ==# 'tabline' ? s:lightryanline.tabline.left : d ==# 'inactive' ? s:lightryanline.inactive.left : s:lightryanline.active.left
    let right = d ==# 'tabline' ? s:lightryanline.tabline.right : d ==# 'inactive' ? s:lightryanline.inactive.right : s:lightryanline.active.right
    let ls = has_key(get(c, d, {}), 'left') ? c[d].left : has_key(f, d) && has_key(get(c, f[d], {}), 'left') ? c[f[d]].left : c.normal.left
    let ms = has_key(get(c, d, {}), 'middle') ? c[d].middle[0] : has_key(f, d) && has_key(get(c, f[d], {}), 'middle') ? c[f[d]].middle[0] : c.normal.middle[0]
    let rs = has_key(get(c, d, {}), 'right') ? c[d].right : has_key(f, d) && has_key(get(c, f[d], {}), 'right') ? c[f[d]].right : c.normal.right
    for [p, l, zs] in [['Left', len(left), ls], ['Right', len(right), rs]]
      for [i, t] in map(range(0, l), '[v:val, 0]') + types
        if i < l || i < 1
          let r = t ? (has_key(get(c, d, []), i) ? c[d][i][0] : has_key(get(c, 'tabline', {}), i) ? c.tabline[i][0] : get(c.normal, i, zs)[0]) : get(zs, i, ms)
          exec printf('hi Lightline%s_%s_%s guifg=%s guibg=%s ctermfg=%s ctermbg=%s %s', p, mode, i, r[0], r[1], r[2], r[3], s:term(r))
        endif
        for [j, s] in map(range(0, l), '[v:val, 0]') + types
          if i + 1 == j || t || s && i != l
            let q = s ? (has_key(get(c, d, []), j) ? c[d][j][0] : has_key(get(c, 'tabline', {}), j) ? c.tabline[j][0] : get(c.normal, j, zs)[0]) : (j != l ? get(zs, j, ms) :ms)
            exec printf('hi Lightline%s_%s_%s_%s guifg=%s guibg=%s ctermfg=%s ctermbg=%s', p, mode, i, j, r[1], q[1], r[3], q[3])
          endif
        endfor
      endfor
    endfor
    exec printf('hi LightlineMiddle_%s guifg=%s guibg=%s ctermfg=%s ctermbg=%s %s', mode, ms[0], ms[1], ms[2], ms[3], s:term(ms))
  endfor
  if !a:0 | let s:mode = '' | endif
endfunction

function! s:subseparator(components, subseparator, expanded) abort
  let [a, c, f, v, u] = [a:components, s:lightryanline.component, s:lightryanline.component_function, s:lightryanline.component_visible_condition, s:lightryanline.component_function_visible_condition]
  let xs = map(range(len(a:components)), 'a:expanded[v:val] ? "1" :
        \ has_key(f, a[v:val]) ? (has_key(u, a[v:val]) ? "(".u[a[v:val]].")" : (exists("*".f[a[v:val]]) ? "" : "exists(\"*".f[a[v:val]]."\")&&").f[a[v:val]]."()!=#\"\"") :
        \ has_key(v, a[v:val]) ? "(".v[a[v:val]].")" : has_key(c, a[v:val]) ? "1" : "0"')
  return '%{' . (xs[0] ==# '1' || xs[0] ==# '(1)' ? '' : xs[0] . '&&(') . join(xs[1:], '||') . (xs[0] ==# '1' || xs[0] ==# '(1)' ? '' : ')') . '?"' . a:subseparator . '":""}'
endfunction

function! lightryanline#concatenate(xs, right) abort
  let separator = a:right ? s:lightryanline.subseparator.right : s:lightryanline.subseparator.left
  return join(filter(copy(a:xs), 'v:val !=# ""'), ' ' . separator . ' ')
endfunction

function! lightryanline#statusline(inactive) abort
  if a:inactive && !has_key(s:highlight, 'inactive')
    call lightryanline#highlight('inactive')
  endif
  return s:line(0, a:inactive)
endfunction

function! s:normalize(result) abort
  if type(a:result) == 3
    return map(a:result, 'type(v:val) == 1 ? v:val : string(v:val)')
  elseif type(a:result) == 1
    return [a:result]
  else
    return [string(a:result)]
  endif
endfunction

function! s:evaluate_expand(component) abort
  try
    let result = eval(a:component . '()')
    if type(result) == 1 && result ==# ''
      return []
    endif
  catch
    return []
  endtry
  return map(type(result) == 3 ? (result + [[], [], []])[:2] : [[], [result], []], 'filter(s:normalize(v:val), "v:val !=# ''''")')
endfunction

function! s:convert(name, index) abort
  if !has_key(s:lightryanline.component_expand, a:name)
    return [[[a:name], 0, a:index, a:index]]
  else
    let type = get(s:lightryanline.component_type, a:name, a:index)
    let is_raw = get(s:lightryanline.component_raw, a:name) || type ==# 'raw'
    return filter(map(s:evaluate_expand(s:lightryanline.component_expand[a:name]),
          \ '[v:val, 1 + ' . is_raw . ', v:key == 1 && ' . (type !=# 'raw') . ' ? "' . type . '" : "' . a:index . '", "' . a:index . '"]'), 'v:val[0] != []')
  endif
endfunction

function! s:expand(components) abort
  let components = []
  let expanded = []
  let indices = []
  let prevtype = ''
  let previndex = -1
  let xs = []
  call map(deepcopy(a:components), 'map(v:val, "extend(xs, s:convert(v:val, ''" . v:key . "''))")')
  for [component, expand, type, index] in xs
    if prevtype !=# type
      for i in range(previndex + 1, max([previndex, index - 1]))
        call add(indices, string(i))
        call add(components, [])
        call add(expanded, [])
      endfor
      call add(indices, type)
      call add(components, [])
      call add(expanded, [])
    endif
    call extend(components[-1], component)
    call extend(expanded[-1], repeat([expand], len(component)))
    let prevtype = type
    let previndex = index
  endfor
  for i in range(previndex + 1, max([previndex, len(a:components) - 1]))
    call add(indices, string(i))
    call add(components, [])
    call add(expanded, [])
  endfor
  call add(indices, string(len(a:components)))
  return [components, expanded, indices]
endfunction

function! s:func(name) abort
  return exists('*' . a:name) ? '%{' . a:name . '()}' : '%{exists("*' . a:name . '")?' . a:name . '():""}'
endfunction

function! s:line(tabline, inactive) abort
  let _ = a:tabline ? '' : '%{lightryanline#link()}'
  if s:lightryanline.palette == {}
    call lightryanline#colorscheme()
  endif
  let [l, r] = a:tabline ? [s:lightryanline.tab_llen, s:lightryanline.tab_rlen] : [s:lightryanline.llen, s:lightryanline.rlen]
  let [p, s] = a:tabline ? [s:lightryanline.tabline_separator, s:lightryanline.tabline_subseparator] : [s:lightryanline.separator, s:lightryanline.subseparator]
  let [c, f, t, w] = [s:lightryanline.component, s:lightryanline.component_function, s:lightryanline.component_type, s:lightryanline.component_raw]
  let mode = a:tabline ? 'tabline' : a:inactive ? 'inactive' : 'active'
  let ls = has_key(s:lightryanline, mode) ? s:lightryanline[mode].left : s:lightryanline.active.left
  let [lc, le, li] = s:expand(ls)
  let rs = has_key(s:lightryanline, mode) ? s:lightryanline[mode].right : s:lightryanline.active.right
  let [rc, re, ri] = s:expand(rs)
  for i in range(len(lc))
    let _ .= '%#LightlineLeft_' . mode . '_' . li[i] . '#'
    for j in range(len(lc[i]))
      let x = le[i][j] ? lc[i][j] : has_key(f, lc[i][j]) ? s:func(f[lc[i][j]]) : get(c, lc[i][j], '')
      let _ .= has_key(t, lc[i][j]) && t[lc[i][j]] ==# 'raw' || get(w, lc[i][j]) || le[i][j] ==# 2 || x ==# '' ? x : '%( ' . x . ' %)'
      if j < len(lc[i]) - 1 && s.left !=# ''
        let _ .= s:subseparator(lc[i][(j):], s.left, le[i][(j):])
      endif
    endfor
    let _ .= '%#LightlineLeft_' . mode . '_' . li[i] . '_' . li[i + 1] . '#'
    let _ .= i < l + len(lc) - len(ls) && li[i] < l || li[i] != li[i + 1] ? p.left : len(lc[i]) ? s.left : ''
  endfor
  let _ .= '%#LightlineMiddle_' . mode . '#%='
  for i in range(len(rc) - 1, 0, -1)
    let _ .= '%#LightlineRight_' . mode . '_' . ri[i] . '_' . ri[i + 1] . '#'
    let _ .= i < r + len(rc) - len(rs) && ri[i] < r || ri[i] != ri[i + 1] ? p.right : len(rc[i]) ? s.right : ''
    let _ .= '%#LightlineRight_' . mode . '_' . ri[i] . '#'
    for j in range(len(rc[i]))
      let x = re[i][j] ? rc[i][j] : has_key(f, rc[i][j]) ? s:func(f[rc[i][j]]) : get(c, rc[i][j], '')
      let _ .= has_key(t, rc[i][j]) && t[rc[i][j]] ==# 'raw' || get(w, rc[i][j]) || re[i][j] ==# 2 || x ==# '' ? x : '%( ' . x . ' %)'
      if j < len(rc[i]) - 1 && s.right !=# ''
        let _ .= s:subseparator(rc[i][(j):], s.right, re[i][(j):])
      endif
    endfor
  endfor
  return _
endfunction

let s:tabnr = -1
let s:tabcnt = -1
let s:columns = -1
let s:tabline = ''
function! lightryanline#tabline() abort
  if !has_key(s:highlight, 'tabline')
    call lightryanline#highlight('tabline')
  endif
  if s:lightryanline.tabline_configured || s:tabnr != tabpagenr() || s:tabcnt != tabpagenr('$') || s:columns != &columns
    let s:tabnr = tabpagenr()
    let s:tabcnt = tabpagenr('$')
    let s:columns = &columns
    let s:tabline = s:line(1, 0)
  endif
  return s:tabline
endfunction

function! lightryanline#tabs() abort
  let [x, y, z] = [[], [], []]
  let nr = tabpagenr()
  let cnt = tabpagenr('$')
  for i in range(1, cnt)
    call add(i < nr ? x : i == nr ? y : z, (i > nr + 3 ? '%<' : '') . '%' . i . 'T%{lightryanline#onetab(' . i . ',' . (i == nr) . ')}' . (i == cnt ? '%T' : ''))
  endfor
  let abbr = '...'
  let n = min([max([&columns / 40, 2]), 8])
  if len(x) > n && len(z) > n
    let x = extend(add(x[:n/2-1], abbr), x[-(n+1)/2:])
    let z = extend(add(z[:(n+1)/2-1], abbr), z[-n/2:])
  elseif len(x) + len(z) > 2 * n
    if len(x) > n
      let x = extend(add(x[:(2*n-len(z))/2-1], abbr), x[-(2*n-len(z)+1)/2:])
    elseif len(z) > n
      let z = extend(add(z[:(2*n-len(x)+1)/2-1], abbr), z[-(2*n-len(x))/2:])
    endif
  endif
  return [x, y, z]
endfunction

function! lightryanline#onetab(n, active) abort
  let _ = []
  for name in a:active ? s:lightryanline.tab.active : s:lightryanline.tab.inactive
    if has_key(s:lightryanline.tab_component_function, name)
      call add(_, call(s:lightryanline.tab_component_function[name], [a:n]))
    else
      call add(_, get(s:lightryanline.tab_component, name, ''))
    endif
  endfor
  return join(filter(_, 'v:val !=# ""'), ' ')
endfunction

function! lightryanline#error(msg) abort
  echohl ErrorMsg
  echomsg 'lightryanline.vim: '.a:msg
  echohl None
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
