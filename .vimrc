set hidden
set ts=4
set sw=4
set expandtab
set wrap
set linebreak
set autoindent
set smartindent
set backspace=2
set shiftround
set foldlevel=99
set confirm " ask for confirmation when leaving buffer
set laststatus=2 " always show status line
set title "show title in window bar
set showcmd
colorscheme desert
let mapleader=","
syntax on
filetype on
map <C-h> <C-w>h
map <C-j> <C-w>j
map <C-k> <C-w>k
map <C-l> <C-w>l
let mapleader = ","

set ignorecase
set smartcase
set incsearch

hi Pmenu ctermfg=White ctermbg=DarkBlue
hi PmenuSel ctermfg=DarkBlue ctermbg=White

au BufRead,BufNewFile *.pkg set syntax=cpp
au BufRead,BufNewFile *.h,*.cpp set fdm=syntax 
au BufRead,BufNewFile *.h,*.cpp normal zR
au BufRead,BufNewFile *.h,*.cpp,*.c set cindent
au BufRead,BufNewFile *.js set fdm=indent

set scrolloff=5 " scroll offset bottom and top

set number "show line number
set numberwidth=3 " line number fixed width

set statusline=%F%m%r%h%w\ [FORMAT=%{&ff}]\ [TYPE=%Y]\ [ASCII=\%03.3b]\ [HEX=\%02.2B]\ [POS=%04l,%04v]\ [%p%%]\ [LEN=%L]

match Todo /\c\<\(TODO\|FIXME\):.*/

"set spell " enable spell checking and use Z= for suggestion

nmap gf :edit <cfile><CR> " open file in new window
nnoremap <Leader>s :%s/\<<C-r><C-w>\>/

map <F4> <Esc>:FSLeft<CR>

" scroll popup menu by tab
function! CleverTab()
   if strpart( getline('.'), 0, col('.')-1 ) =~ '^\s*$'
    return "\<Tab>"
   else
	  return "\<C-N>"
   endif
endfunction
inoremap <Tab> <C-R>=CleverTab()<CR>

" clang_complete options
let g:clang_snippets = 1
let g:clang_snippets_engine = 'clang_complete'

set completeopt=menuone,longest

" 
" VAM settings
"

" put this line first in ~/.vimrc
set nocompatible | filetype indent plugin on | syn on

fun! EnsureVamIsOnDisk(plugin_root_dir)
  " windows users may want to use http://mawercer.de/~marc/vam/index.php
  " to fetch VAM, VAM-known-repositories and the listed plugins
  " without having to install curl, 7-zip and git tools first
  " -> BUG [4] (git-less installation)
  let vam_autoload_dir = a:plugin_root_dir.'/vim-addon-manager/autoload'
  if isdirectory(vam_autoload_dir)
    return 1
  else
    if 1 == confirm("Clone VAM into ".a:plugin_root_dir."?","&Y\n&N")
      " I'm sorry having to add this reminder. Eventually it'll pay off.
      call confirm("Remind yourself that most plugins ship with ".
                  \"documentation (README*, doc/*.txt). It is your ".
                  \"first source of knowledge. If you can't find ".
                  \"the info you're looking for in reasonable ".
                  \"time ask maintainers to improve documentation")
      call mkdir(a:plugin_root_dir, 'p')
      execute '!git clone --depth=1 git://github.com/MarcWeber/vim-addon-manager '.
                  \       shellescape(a:plugin_root_dir, 1).'/vim-addon-manager'
      " VAM runs helptags automatically when you install or update 
      " plugins
      exec 'helptags '.fnameescape(a:plugin_root_dir.'/vim-addon-manager/doc')
    endif
    return isdirectory(vam_autoload_dir)
  endif
endfun

fun! SetupVAM()
  " Set advanced options like this:
  " let g:vim_addon_manager = {}
  " let g:vim_addon_manager.key = value
  "     Pipe all output into a buffer which gets written to disk
  " let g:vim_addon_manager.log_to_buf =1

  " Example: drop git sources unless git is in PATH. Same plugins can
  " be installed from www.vim.org. Lookup MergeSources to get more control
  " let g:vim_addon_manager.drop_git_sources = !executable('git')
  " let g:vim_addon_manager.debug_activation = 1

  " VAM install location:
  let c = get(g:, 'vim_addon_manager', {})
  let g:vim_addon_manager = c
  let c.plugin_root_dir = expand('$HOME/.vim/vim-addons', 1)
  if !EnsureVamIsOnDisk(c.plugin_root_dir)
    echohl ErrorMsg | echomsg "No VAM found!" | echohl NONE
    return
  endif
  let &rtp.=(empty(&rtp)?'':',').c.plugin_root_dir.'/vim-addon-manager'

  " Tell VAM which plugins to fetch & load:
  call vam#ActivateAddons(['clang_complete', 'github:vim-scripts/AutoComplPop', 'snipMate', 'taglist', 'Command-T', 'wmgraphviz', 'FSwitch', 'EasyGrep', 'The_NERD_Commenter', 'EasyMotion', 'github:elzr/vim-json', 'github:marijnh/tern_for_vim', 'github:moll/vim-bbye'], {'auto_install' : 0})
  " sample: call vam#ActivateAddons(['pluginA','pluginB', ...], {'auto_install' : 0}) 

  " Addons are put into plugin_root_dir/plugin-name directory
  " unless those directories exist. Then they are activated.
  " Activating means adding addon dirs to rtp and do some additional
  " magic

  " How to find addon names?
  " - look up source from pool
  " - (<c-x><c-p> complete plugin names):
  " You can use name rewritings to point to sources:
  "    ..ActivateAddons(["github:foo", .. => github://foo/vim-addon-foo
  "    ..ActivateAddons(["github:user/repo", .. => github://user/repo
  " Also see section "2.2. names of addons and addon sources" in VAM's documentation
endfun
call SetupVAM()
" experimental [E1]: load plugins lazily depending on filetype, See
" NOTES
" experimental [E2]: run after gui has been started (gvim) [3]
" option1:  au VimEnter * call SetupVAM()
" option2:  au GUIEnter * call SetupVAM()
" See BUGS sections below [*]
" Vim 7.0 users see BUGS section [3]


set cursorline " highlight current line
"current line style
highlight CursorLine cterm=underline term=underline ctermbg=None guibg=None

iabbrev cctd //TODO: not implemented 

"EasyGrep options
let g:EasyGrepFileAssociations=expand("$HOME/.vim/vim-addons/EasyGrep/plugin/EasyGrepFileAssociations")
let g:EasyGrepMode = 2
let g:EasyGrepRecursive = 1

"Search in visual selected block
function! RangeSearch(direction)
  call inputsave()
  let g:srchstr = input(a:direction)
  call inputrestore()
  if strlen(g:srchstr) > 0
    let g:srchstr = g:srchstr.
          \ '\%>'.(line("'<")-1).'l'.
          \ '\%<'.(line("'>")+1).'l'
  else
    let g:srchstr = ''
  endif
endfunction
vnoremap <silent> / :<C-U>call RangeSearch('/')<CR>:if strlen(g:srchstr) > 0\|exec '/'.g:srchstr\|endif<CR>
vnoremap <silent> ? :<C-U>call RangeSearch('?')<CR>:if strlen(g:srchstr) > 0\|exec '?'.g:srchstr\|endif<CR>

autocmd BufWritePost *.cpp silent execute "!hgen.py %:p" | redraw!

nnoremap <Leader>q :Bdelete<CR>

