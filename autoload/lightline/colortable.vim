" =============================================================================
" Filename: autoload/lightryanline/colortable.vim
" Author: itchyny
" License: MIT License
" Last Change: 2020/06/19 11:07:13.
" =============================================================================

let s:save_cpo = &cpo
set cpo&vim

function! s:load() abort
  let rgbfile = $VIMRUNTIME . '/rgb.txt'
  let table = {}
  if filereadable(rgbfile)
    for _ in map(filter(readfile(rgbfile), 'v:val !~# "^!"'), 'matchlist(v:val, "^\\s*\\(\\d\\+\\)\\s\\+\\(\\d\\+\\)\\s\\+\\(\\d\\+\\)\\s\\+\\(.*\\)")[1:4]')
      let table[tolower(_[3])] = _[0:2]
    endfor
  endif
  return table
endfunction

let s:table = s:load()

function! lightryanline#colortable#name_to_rgb(name) abort
  let name = tolower(a:name)
  return has_key(s:table, name) ? s:table[name] : []
endfunction

function! lightryanline#colortable#gui2cui(rgb, fallback) abort
  let rgb = map(matchlist(a:rgb, '#\(..\)\(..\)\(..\)')[1:3], '0 + ("0x".v:val)')
  if len(rgb) == 0
    let rgb = lightryanline#colortable#name_to_rgb(a:rgb)
    if len(rgb) == 0
      return a:fallback % 128
    endif
  endif
  let rgb = [rgb[0] > 127 ? 4 : 0, rgb[1] > 127 ? 2 : 0, rgb[2] > 127 ? 1 : 0]
  return rgb[0] + rgb[1] + rgb[2]
endfunction

function! lightryanline#colortable#gui2cui_palette(palette) abort
  for u in values(a:palette)
    for v in values(u)
      for w in v
        let [w[2], w[3]] = [lightryanline#colortable#gui2cui(w[0], w[2]), lightryanline#colortable#gui2cui(w[1], w[3])]
      endfor
    endfor
  endfor
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
