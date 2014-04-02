" dmenu-finder.vim - File and buffer navigation using dmenu
" Author: Hassan Kibirige <has2k1+vim@gmail.com>
" Credit: http://bit.ly/1lmRa9u
" Last Modified: Thursday 03 April 2014 02:00:30 AM CDT
" License: Vim License (see :help license)


if exists("g:loaded_dmenu_finder")
  finish
endif
let g:loaded_dmenu_finder = 1

" Preserve external compatibility options,
" then enable full vim compatibility...
let s:save_cpo = &cpo
set cpo&vim


" Variables
" ---------
let s:cache = {}


" Functions
" ---------

" return 1 if set, 0 if not set
function! s:init_variable(var, value)
  if !exists(a:var)
    exec 'let ' . a:var . ' = ' . "'" .
          \ substitute(a:value, "'", "''", "g") . "'"
    return 1
  endif
  return 0
endfunction

" Try to be clever
function! s:find_file()
  if s:is_repo()
    return s:find_in_repo()
  endif
  return s:find_in_cur_dir()
endfunction

" find in current directory
function! s:find_in_curdir()
  let s:prompt = 'Current Directory: '
  let key = getcwd()

  " Cache the file names
  if !has_key(s:cache, key)
    let s:cache[key] = s:get_filenames(
          \ 'file -F "<-- -->" --mime-type * | grep text | awk '.
          \ "'".
          \ 'BEGIN{FS="<-- -->"}{print $1}'.
          \ "'")
  endif

  return s:select_and_open_file(s:cache[key], '')
endfunction

" find file in git repository
function! s:find_in_repo()
  let s:prompt = 'Repository: '
  let cwd = getcwd()
  execute 'cd' fnameescape(b:git_toplevel)
  let filenames = s:get_filenames('git ls-files --exclude-standard')
  execute 'cd' fnameescape(cwd)
  return s:select_and_open_file(filenames, b:git_toplevel)
endfunction

" find line in current buffer
function! s:find_in_buffer()
endfunction

" stanitize line endings
function! s:chomp(str)
  return substitute(a:str, '\n$', '', '')
endfunction

" Makes the dmenu call
function! s:pipe_to_dmenu(lines)
  return s:chomp(system('echo '. join(a:lines, '\\n') .
        \ " | " . s:dmenu()))
endfunction

" Search the filesystem and use dmenu
function! s:select_and_open_file(filenames, basepath)
  let fname = a:basepath . s:pipe_to_dmenu(a:filenames)
  if filereadable(fname)
    execute ":e " . fnameescape(fname)
  endif
endfunction

function! s:go_to_line(str)
endfunction

" Return the dmenu command string
function! s:dmenu()
  return g:dmenu_finder_dmenu_command . ' -p "' . s:prompt . '"'
endfunction

" Return true if this buffer is part of a repository
function! s:is_repo()
  if exists("b:git_toplevel")
    return 1
  endif
  return 0
endfunction

" For the buffer record the top level repository directory
function! s:detect_repo()
  let result = s:chomp(system('git rev-parse --show-toplevel')) . '/'
  if !v:shell_error
    let b:git_toplevel = result
  endif
endfunction

" Return a list of filenames
function! s:get_filenames(files_cmd)
  return split(s:chomp(system(a:files_cmd)), '\n')
endfunction

" Clean stuff
function! s:clear_cache()
  let s:cache = {}
endfunction


" Options
" -------
call s:init_variable('g:dmenu_finder_dmenu_command', 'dmenu')
" call s:init_variable('g:dmenu_finder_cache_dir', '/tmp/')
" let s:cache_dir = g:dmenu_finder_cache_dir


" Public Commands
" ---------------
command! -n=0 DmenuFinderFindFile call s:find_file()
command! -n=0 DmenuFinderCurDir call s:find_in_curdir()
command! -n=0 DmenuFinderRepo call s:find_in_repo()
command! -n=0 DmenuFinderClearCache call s:clear_cache()


" Autocommands
" ------------
augroup dmenufinder
  autocmd!
  autocmd BufNewFile,BufReadPost * call s:detect_repo()
augroup END

" Restore previous external compatibility options
let &cpo = s:save_cpo
