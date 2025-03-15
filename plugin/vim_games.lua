" vim_games.vim
" Auto-loaded script for vim-games plugin

" Prevent loading the plugin multiple times
if exists('g:loaded_vim_vim_games')
  finish
endif
let g:loaded_vim_games = 1

" Set up the plugin
lua require('vim_games').setup()
