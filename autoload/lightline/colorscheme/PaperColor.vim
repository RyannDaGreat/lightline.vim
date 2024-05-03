" =============================================================================
" Filename: autoload/lightryanline/colorscheme/PaperColor.vim
" Author: TKNGUE
" License: MIT License
" Last Change: 2017/11/25 11:13:35.
" =============================================================================

if lightryanline#colorscheme#background() ==# 'light'
  let g:lightryanline#colorscheme#PaperColor#palette = g:lightryanline#colorscheme#PaperColor_light#palette
else
  let g:lightryanline#colorscheme#PaperColor#palette = g:lightryanline#colorscheme#PaperColor_dark#palette
endif
