let g:python_host_prog = '~/env/bin/python'
let g:python3_host_prog = '~/env3/bin/python'

call plug#begin('~/.local/share/vscnvim/plugged')
"Plug 'abcjjy/cscope_mappings'
"Plug 'tpope/vim-fugitive' 
"Plug 'plasticboy/vim-markdown' 
Plug 'kien/ctrlp.vim' 
"Plug 'kshenoy/vim-signature' 
Plug 'godlygeek/tabular' 
"Plug 'Shougo/deoplete.nvim' 
"Plug 'derekwyatt/vim-fswitch' 
Plug 'scrooloose/nerdcommenter' 
"Plug 'easymotion/vim-easymotion' 
"Plug 'asvetliakov/vim-easymotion'
Plug 'dkprice/vim-easygrep'
Plug 'elzr/vim-json' 
"Plug 'moll/vim-bbye' 
"Plug 'danro/rename.vim' 
"Plug 'tpope/vim-obsession'
"Plug 'lepture/vim-jinja' 
"Plug 'kablamo/vim-git-log' 
"Plug 'abcjjy/diokai' 
Plug 'jiangmiao/auto-pairs' 
"Plug 'Yggdroot/indentLine' 
"Plug 'vim-scripts/ShaderHighLight'
Plug 'phaazon/hop.nvim'
call plug#end()

"set t_Co=256
set hidden
set ts=4
set sw=4
set expandtab
set wrap
set linebreak
"set autoindent
set nosmartindent
set indentexpr=""
set backspace=2
set shiftround
set foldlevel=99
set confirm " ask for confirmation when leaving buffer
set laststatus=2 " always show status line
set title "show title in window bar
set showcmd
let mapleader=","
syntax off
filetype off
filetype plugin off
filetype indent off
map <C-h> <C-w>h
map <C-j> <C-w>j
map <C-k> <C-w>k
map <C-l> <C-w>l
"let g:indentLine_setColors = 0

set ignorecase
set smartcase
set fileignorecase
set incsearch
set wildignore=*.o,*.meta,*.a,*.so

"hi Pmenu ctermfg=White ctermbg=DarkBlue
"hi PmenuSel ctermfg=DarkBlue ctermbg=White

"au BufRead,BufNewFile *.pkg set syntax=cpp
"au BufRead,BufNewFile *.h,*.cpp set fdm=syntax 
"au BufRead,BufNewFile *.h,*.cpp normal zR
"au BufRead,BufNewFile *.h,*.cpp,*.c set cindent
"au BufRead,BufNewFile *.js set fdm=indent
"au BufRead,BufNewFile *.sef set syntax=json|set fdm=indent
"au BufRead,BufNewFile *.json set fdm=indent
"au BufRead,BufNewFile *.as set syntax=cpp "angelscript
"au BufRead,BufNewFile *.angelscript set syntax=cpp "angelscript
"au BufRead,BufNewFile *.cs setf text
au BufRead,BufNewFile *.cs set nosmartindent

"au BufEnter * set sw=4|set ts=4
"au BufEnter *.yaml set sw=2|set ts=2

set scrolloff=5 " scroll offset bottom and top

set number "show line number
set numberwidth=3 " line number fixed width

"set statusline=%F%m%r%h%w\ [FORMAT=%{&ff}]\ [TYPE=%Y]\ [ASCII=\%03.3b]\ [HEX=\%02.2B]\ [POS=%04l,%04v]\ [%p%%]\ [LEN=%L]\ %{ObsessionStatus()}

match Todo /\c\<\(TODO\|FIXME\):.*/

"set spell " enable spell checking and use Z= for suggestion

"nmap gf :edit <cfile><CR> " open file in new window
nnoremap <Leader>s :%s/\<<C-r><C-w>\>/
nnoremap <Leader>S :%s/<C-r><C-w>/

map <F4> <Esc>:FSLeft<CR>

set completeopt=menuone,longest

set cursorline " highlight current line
"current line style
"highlight CursorLine cterm=underline term=underline ctermbg=None guibg=None

"iabbrev cctd //TODO: not implemented 
"iabbrev catd CCASSERT(false, "Not implemented");

"EasyGrep options
let g:EasyGrepMode = 2
let g:EasyGrepRecursive = 1
let g:EasyGrepFilesToExclude=".svn,.git,*.swp,*.swo"
let g:EasyGrepSearchCurrentBufferDir = 0
let g:EasyGrepReplaceWindowMode = 2

"Search in visual selected block
"function! RangeSearch(direction)
  "call inputsave()
  "let g:srchstr = input(a:direction)
  "call inputrestore()
  "if strlen(g:srchstr) > 0
    "let g:srchstr = g:srchstr.
          "\ '\%>'.(line("'<")-1).'l'.
          "\ '\%<'.(line("'>")+1).'l'
  "else
    "let g:srchstr = ''
  "endif
"endfunction
"vnoremap <silent> / :<C-U>call RangeSearch('/')<CR>:if strlen(g:srchstr) > 0\|exec '/'.g:srchstr\|endif<CR>
"vnoremap <silent> ? :<C-U>call RangeSearch('?')<CR>:if strlen(g:srchstr) > 0\|exec '?'.g:srchstr\|endif<CR>

autocmd BufWritePost *.cpp silent execute "!hgen2.py %:p" | redraw!
autocmd BufWritePost *.mm silent execute "!hgen2.py %:p" | redraw!

"nnoremap <Leader>q :Bdelete<CR>

"hgen short cut
"imap hdcl /*H_Declare<CR><Esc>cc#include <string><Esc><<o<CR>*/<Esc>ka
"imap hmpv //H_Method public virtual<CR><Esc>cc
"imap hmpo //H_Method public virtual override<CR><Esc>cc
"imap hmp //H_Method public<CR><Esc>cc
"imap hmps //H_Method public static<CR><Esc>cc
"imap hmo //H_Method protected<CR><Esc>cc
"imap hmov //H_Method protected virtual<CR><Esc>cc
"imap hmi //H_Method private<CR><Esc>cc
"imap hvp //H_MVar public<Esc>a
"imap hvo //H_MVar protected<Esc>a
"imap hvi //H_MVar private<Esc>a
"imap hvps //H_MVar public static<CR><Esc>cc
"imap hvos //H_MVar protected static<CR><Esc>cc
"imap hvis //H_MVar private static<CR><Esc>cc

"imap hdcc /*H_Declare<CR><Esc>cc#incc<CR>//H_Class <C-n><CR>*/<Esc>kk$a
"imap #incc #include "cocos2d.h"<CR>#include "cocos-ext.h"<CR>USING_NS_CC;<CR>USING_NS_CC_EXT;<CR>
"imap usst using namespace std;<CR>

"break auto inserted line headers
"imap <C-n> <Esc>o<Esc>cc

nmap <Leader>j :%!python -c 'import sys,json;print json.dumps(json.loads(sys.stdin.read()),indent=4,ensure_ascii=False,sort_keys=True).encode("utf-8")'<CR>

nmap <Leader>r <ESC>:Rename 

"This is only for my game projects
"iab frjs void ::fromJson(const JSONNode & json)<ESC>^wi
"iab tojs JSONNode ::toJson()<ESC>^wi

"cocos2dx tags
"set tags+=/Users/jjy/code/cocos2d-x-2.2/tags
"set tags+=~/code/libcocos2dx/tags
"set tags+=~/code/qqgc/tags

"for tabular
nmap <Leader>a= :Tabularize /=<CR>
vmap <Leader>a= :Tabularize /=<CR>
nmap <Leader>a: :Tabularize /:\zs<CR>
vmap <Leader>a: :Tabularize /:\zs<CR>
nmap <Leader>a, :Tabularize /,<CR>
vmap <Leader>a, :Tabularize /,<CR>
nmap <Leader>a\| :Tabularize /\|<CR>

"Fix bug in signature plugin while delete mark
"nmap m- :<C-U>call signature#mark#Purge("line")<CR>:SignatureRefresh<CR>

"localvimrc
let g:localvimrc_ask=0

"set background=dark
"let g:solarized_termcolors=256
"colorscheme solarized

map <LEADER>er <ESC>:!python % &<CR>

set background=dark
"colorscheme diokai
"au BufEnter * colorscheme diokai
"au BufEnter *.py colorscheme molokai

hi link EasyMotionTarget ErrorMsg
hi link EasyMotionShade  Comment

hi link EasyMotionTarget2First ErrorMsg
hi link EasyMotionTarget2Second ErrorMsg

"set sessionoptions=buffers,curdir
"IndentLine makes bracket input laggy in C++ files
"let g:indentLine_enabled = 0

"let g:netrw_list_hide= '.*\.swp$,.*\.pyc$,.*\.meta$'
"let g:deoplete#enable_at_startup = 1

"inoremap <silent><expr> <TAB>
                "\ pumvisible() ? "\<C-n>" :
                "\ <SID>check_back_space() ? "\<TAB>" :
                "\ deoplete#mappings#manual_complete()
                "function! s:check_back_space() abort "{{{
                "let col = col('.') - 1
                "return !col || getline('.')[col - 1]  =~ '\s'
                "endfunction"}}}

"notebook navigation
map <LEADER>q <Cmd>call VSCodeNotify("notebook.cell.quitEdit")<CR>
map <LEADER>j <Cmd>call VSCodeNotify("notebook.focusNextEditor")<CR>
map <LEADER>k <Cmd>call VSCodeNotify("notebook.focusPreviousEditor")<CR>
map <LEADER>zc <Cmd>call VSCodeNotify("notebook.cell.collapseCellInput")<CR>
map <LEADER>zC <Cmd>call VSCodeNotify("notebook.cell.collapseAllCellInputs")<CR>
map <LEADER>zo <Cmd>call VSCodeNotify("notebook.cell.expandCellInput")<CR>
map <LEADER>zo <Cmd>call VSCodeNotify("notebook.cell.expandAllCellInputs")<CR>
map <LEADER>m <Cmd>call VSCodeNotify("notebook.cell.changeToMarkdown")<CR>

"map <LEADER>b <Cmd>call VSCodeNotify("workbench.action.toggleSidebarVisibility")<CR>

lua require'hop'.setup {}

nmap <LEADER>b <Cmd>HopWordBC<CR>
nmap <LEADER>w <Cmd>HopWordAC<CR>
nmap <LEADER>k <Cmd>HopLineStartBC<CR>
nmap <LEADER>j <Cmd>HopLineStartAC<CR>
