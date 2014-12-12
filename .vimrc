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
au BufRead,BufNewFile *.sef set syntax=json|set fdm=indent
au BufRead,BufNewFile *.json set fdm=indent
au BufRead,BufNewFile *.yaml set sw=2|set ts=2
au BufRead,BufNewFile *.as set syntax=cpp "angelscript
au BufRead,BufNewFile *.angelscript set syntax=cpp "angelscript

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
let g:clang_library_path = '/Applications/Xcode.app//Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/'

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
  "call vam#ActivateAddons(['AutoComplPop', 'FSwitch', 'EasyGrep', 'The_NERD_Commenter', 'EasyMotion', 'github:jakar/vim-json', 'github:moll/vim-bbye', 'github:danro/rename.vim'], {'auto_install' : 0})
  call vam#ActivateAddons(['github:plasticboy/vim-markdown', 'github:embear/vim-localvimrc', 'github:kien/ctrlp.vim', 'github:kshenoy/vim-signature', 'github:godlygeek/tabular', 'OmniCppComplete', 'github:Shougo/neocomplete.vim', 'FSwitch', 'EasyGrep', 'The_NERD_Commenter', 'EasyMotion', 'github:jakar/vim-json', 'github:moll/vim-bbye', 'github:danro/rename.vim'], {'auto_install' : 0})
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

autocmd BufWritePost *.cpp silent execute "!hgen2.py %:p" | redraw!
autocmd BufWritePost *.mm silent execute "!hgen2.py %:p" | redraw!

nnoremap <Leader>q :Bdelete<CR>

"hgen short cut
imap hdcl /*H_Declare<CR><Esc>cc#include <string><Esc><<o<CR>*/<Esc>ka
imap hmpv //H_Method public virtual<CR><Esc>cc
imap hmp //H_Method public<CR><Esc>cc
imap hmps //H_Method public static<CR><Esc>cc
imap hmo //H_Method protected<CR><Esc>cc
imap hmov //H_Method protected virtual<CR><Esc>cc
imap hmi //H_Method private<CR><Esc>cc
imap hvp //H_MVar public<Esc>a
imap hvo //H_MVar protected<Esc>a
imap hvi //H_MVar private<Esc>a
imap hvps //H_MVar public static<CR><Esc>cc
imap hvos //H_MVar protected static<CR><Esc>cc
imap hvis //H_MVar private static<CR><Esc>cc

imap hdcc /*H_Declare<CR><Esc>cc#incc<CR>//H_Class <C-n><CR>*/<Esc>kk$a
"imap #incc #include "cocos2d.h"<CR>#include "cocos-ext.h"<CR>USING_NS_CC;<CR>USING_NS_CC_EXT;<CR>
"imap usst using namespace std;<CR>

"break auto inserted line headers
imap <C-n> <Esc>o<Esc>cc

nmap <Leader>j :%!python -m json.tool<CR>

nmap <Leader>r <ESC>:Rename 

"This is for autoclosing brace in c++ source
imap {<CR> {}<Left><CR><Esc>O

"This is only for my game projects
iab frjs void ::fromJson(const JSONNode & json)<ESC>^wi
iab tojs JSONNode ::toJson()<ESC>^wi

"cocos2dx tags
"set tags+=/Users/jjy/code/cocos2d-x-2.2/tags
set tags+=/Users/jjy/code/cocos2dx-store/tags

" Disable AutoComplPop.
let g:acp_enableAtStartup = 0
" Use neocomplete.
let g:neocomplete#enable_at_startup = 1
" Use smartcase.
let g:neocomplete#enable_smart_case = 1
" Set minimum syntax keyword length.
let g:neocomplete#sources#syntax#min_keyword_length = 3
let g:neocomplete#lock_buffer_name_pattern = '\*ku\*'

" Define dictionary.
let g:neocomplete#sources#dictionary#dictionaries = {
    \ 'default' : '',
    \ 'vimshell' : $HOME.'/.vimshell_hist',
    \ 'scheme' : $HOME.'/.gosh_completions'
        \ }

" Define keyword.
if !exists('g:neocomplete#keyword_patterns')
    let g:neocomplete#keyword_patterns = {}
endif
let g:neocomplete#keyword_patterns['default'] = '\h\w*'

" Plugin key-mappings.
inoremap <expr><C-g>     neocomplete#undo_completion()
inoremap <expr><C-l>     neocomplete#complete_common_string()

" Recommended key-mappings.
" <CR>: close popup and save indent.
inoremap <silent> <CR> <C-r>=<SID>my_cr_function()<CR>
function! s:my_cr_function()
  return neocomplete#close_popup() . "\<CR>"
  " For no inserting <CR> key.
  "return pumvisible() ? neocomplete#close_popup() : "\<CR>"
endfunction
" <TAB>: completion.
inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"
" <C-h>, <BS>: close popup and delete backword char.
inoremap <expr><C-h> neocomplete#smart_close_popup()."\<C-h>"
inoremap <expr><BS> neocomplete#smart_close_popup()."\<C-h>"
"inoremap <expr><CR>  neocomplete#close_popup()
inoremap <expr><C-e>  neocomplete#cancel_popup()
" Close popup by <Space>.
inoremap <expr><CR> pumvisible() ? neocomplete#close_popup() : "\<CR>"

" For cursor moving in insert mode(Not recommended)
"inoremap <expr><Left>  neocomplete#close_popup() . "\<Left>"
"inoremap <expr><Right> neocomplete#close_popup() . "\<Right>"
"inoremap <expr><Up>    neocomplete#close_popup() . "\<Up>"
"inoremap <expr><Down>  neocomplete#close_popup() . "\<Down>"
" Or set this.
"let g:neocomplete#enable_cursor_hold_i = 1
" Or set this.
"let g:neocomplete#enable_insert_char_pre = 1

" AutoComplPop like behavior.
let g:neocomplete#enable_auto_select = 1

" Shell like behavior(not recommended).
"set completeopt+=longest
"let g:neocomplete#enable_auto_select = 1
"let g:neocomplete#disable_auto_complete = 1
"inoremap <expr><TAB>  pumvisible() ? "\<Down>" : "\<C-x>\<C-u>"

" Enable omni completion.
autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags

" Enable heavy omni completion.
if !exists('g:neocomplete#sources#omni#input_patterns')
  let g:neocomplete#sources#omni#input_patterns = {}
endif
"let g:neocomplete#sources#omni#input_patterns.php = '[^. \t]->\h\w*\|\h\w*::'
"let g:neocomplete#sources#omni#input_patterns.c = '[^.[:digit:] *\t]\%(\.\|->\)'
"let g:neocomplete#sources#omni#input_patterns.cpp = '[^.[:digit:] *\t]\%(\.\|->\)\|\h\w*::'

" For perlomni.vim setting.
" https://github.com/c9s/perlomni.vim
let g:neocomplete#sources#omni#input_patterns.perl = '\h\w*->\h\w*\|\h\w*::'

"for tabular
nmap <Leader>a= :Tabularize /=<CR>
vmap <Leader>a= :Tabularize /=<CR>
nmap <Leader>a: :Tabularize /:\zs<CR>
vmap <Leader>a: :Tabularize /:\zs<CR>
nmap <Leader>a, :Tabularize /,<CR>
vmap <Leader>a, :Tabularize /,<CR>

"Fix bug in signature plugin while delete mark
nmap m- :<C-U>call signature#mark#Purge("line")<CR>:SignatureRefresh<CR>

"localvimrc
let g:localvimrc_ask=0

