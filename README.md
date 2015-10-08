## vim-dmenu-finder ##

Use dmenu to open files and switch buffers. The plugin allows you
to search the entire git repository.

## Usage

Here is how you could map to the functions

```vim
" Trys to be smart by detecting a Repository and if
" that fails it checks the current directory 
nnoremap <silent> <leader>ff :DmenuFinderFindFile<cr>

" Find file in current directory
nnoremap <silent> <leader>fd :DmenuFinderCurDir<cr>

" find file in repository
nnoremap <silent> <leader>fr :DmenuFinderRepo<cr>

" The plugin caches the files in the repository and
" subsequently searches those. You can clear that cache
" if new files are not showing up.
nnoremap <silent> <leader>fc :DmenuFinderClearCache<cr>

" Find file in open buffers
nnoremap <silent> <leader>fb :DmenuFinderFindBuffer<cr>

" Location of dmenu command
let g:dmenu_finder_dmenu_command = "/usr/bin/dmenu"
```

### Requires ###

[dmenu] (http://tools.suckless.org/dmenu/)
