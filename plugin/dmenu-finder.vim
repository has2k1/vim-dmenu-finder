" dmenu-finder.vim - File and buffer navigation using dmenu
" Author: Hassan Kibirige <has2k1+vim@gmail.com>
" Credit: http://bit.ly/1lmRa9u
" License: Vim License (see :help license)
" Repository: https://github.com/has2k1/vim-dmenu-finder


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
    let {a:var} = a:value
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
  if !s:is_repo()
    echohl ErrorMsg | echo "Not in a git repository" | echohl None
    return 0
  endif

  let s:prompt = 'Repository: '
  let cwd = getcwd()
  execute 'cd' fnameescape(b:git_toplevel)
  let filenames = s:get_filenames('git ls-files --exclude-standard')
  execute 'cd' fnameescape(cwd)
  return s:select_and_open_file(filenames, b:git_toplevel)
endfunction


" find line in current buffer
function! s:find_buffer()
  let s:prompt = 'Buffers: '
  " From all the created buffers,
  " remove unlisted buffers
  " remove current buffer
  let buffer_numbers = range(1, bufnr('$'))
  let keep = 'buflisted(v:val) && v:val != bufnr("%")'
  call filter(buffer_numbers, keep)

  " Buffer numbers to names
  let filenames = map(copy(buffer_numbers), 'bufname(v:val)')
  return s:select_and_open_file(filenames, '')
endfunction


" stanitize line endings
function! s:chomp(str)
  return substitute(a:str, '\n$', '', '')
endfunction


" Makes the dmenu call
function! s:pipe_to_dmenu(lines)
  let cmd = 'echo ' . join(a:lines, '\\n') . " | " . s:dmenu()
  let result = system(cmd)

  if v:shell_error
    echohl ErrorMsg | echo "Nothing from dmenu" | echohl None
  endif

  return s:chomp(result)
endfunction


" Search the filesystem and use dmenu
function! s:select_and_open_file(filenames, basepath)
  " Remove empty lines
  call filter(a:filenames, '!empty(v:val)')
  let selected = s:pipe_to_dmenu(a:filenames)
  let fname = a:basepath . selected

  if filereadable(fname)
    execute ':e ' . fnameescape(fname)
  elseif !empty(selected)
    echom fname
    echohl ErrorMsg | echo "File does not exist!" | echohl None
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
  if exists('b:git_toplevel')
    return 1
  else
    let result = s:chomp(system('git rev-parse --show-toplevel')) . '/'
    if !v:shell_error
      let b:git_toplevel = result
      return 1
    endif
    return 0
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


" Public Commands
" ---------------
command! -n=0 DmenuFinderFindFile call s:find_file()
command! -n=0 DmenuFinderFindBuffer call s:find_buffer()
command! -n=0 DmenuFinderCurDir call s:find_in_curdir()
command! -n=0 DmenuFinderRepo call s:find_in_repo()
command! -n=0 DmenuFinderClearCache call s:clear_cache()


" Clean up
" --------

" Restore previous external compatibility options
let &cpo = s:save_cpo
