if exists('g:loaded_gitpilot') | finish | endif

let s:save_cpo = &cpo
set cpo&vim

" Initialisation du plugin via Lua
lua require('gitpilot')

let &cpo = s:save_cpo
unlet s:save_cpo

let g:loaded_gitpilot = 1
