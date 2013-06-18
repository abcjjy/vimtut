set ts=4
set sw=4
set expandtab
set autoindent
set smartindent
set backspace=2
set shiftround
set foldlevel=99
set confirm
set laststatus=2
set title

set ignorecase
set smartcase
set incsearch

set scrolloff=5 " scroll offset bottom and top

set numbers "show line number
set numberwidth=3 " line number fixed width

set cursorline " highlight current line
highlight CursorLine ctermbg=0 guibg=0 cterm=None term=0 " current line style

set statusline=%F%m%r%h%w\ [FORMAT=%{&ff}]\ [TYPE=%Y]\ [ASCII=\%03.3b]\ [HEX=\%02.2B]\ [POS=%04l,%04v]\ [%p%%]\ [LEN=%L]

"set spell " enable spell checking and use Z= for suggestion
