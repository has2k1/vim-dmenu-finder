" dmenu-finder.vim - File and buffer navigation using dmenu
" Author: Hassan Kibirige <has2k1+vim@gmail.com>
" Credit: http://bit.ly/1lmRa9u
" Last Modified: Wednesday 02 April 2014 06:55:17 AM CDT
" License: Vim License (see :help license)


if exists("g:loaded_dmenu_finder")
  finish
endif
let g:loaded_dmenu_finder = 1
   
" Preserve external compatibility options,
" then enable full vim compatibility...
let s:save_cpo = &cpo
set cpo&vim


" Options
" -------

if !exists('g:dmenu_finder_dmenu_command')
  let g:dmenu_finder_dmenu_command = 'dmenu'
endif
let s:dmenu = g:dmenu_finder_dmenu_command


" Public Interface
" ----------------



" Functions
" ---------

" find in current directory
function! DmenuFinder_curdir()
  s:open_file('git ls-files --exclude-standard')
endfunction

" find file in git repository
function! DmenuFinder_repo()
  let gcmd = 'git ls-tree -r --full-tree --name-only HEAD'
endfunction

" find line in current buffer
function! DmenuFinder_bufline()
endfunction

function! s:chomp(str)
  return substitute(a:str, '\n$', '', '')
endfunction

function! s:dmenu_execute(cmd)
  return s:chomp(system(cmd . " | " . s:dmenu))
endfunction

function! s:open_file(search_cmd)
  let fname = s:dmenu_execute(a:search_cmd)
  if filereadable(fname)
    execute ":e " . fname
  endif
endfunction

function! s:go_to_line(str)
endfunction

function! s:get_repository_root()
endfunction


" Restore previous external compatibility options
let &cpo = s:save_cpo
