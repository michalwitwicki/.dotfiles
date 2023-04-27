set number	
set linebreak
set showbreak=+++	
set textwidth=100	
set showmatch	
set visualbell	
 
set hlsearch	
set smartcase	
set ignorecase	
set incsearch	
 
set autoindent	
set shiftwidth=4
set smartindent	
set smarttab	
set softtabstop=4

vnoremap <C-c> "+y
map <C-v> "+P

imap <c-s> <Esc>:w<CR>
nmap <c-s> :w<CR>

imap <c-w> <ESC>:q<CR>
nmap <c-w> :q<CR>

nnoremap confe :e $MYVIMRC<CR>

nnoremap confr :source $MYVIMRC<CR>

nmap <a-Enter> O<Esc>j
nmap <CR> o<Esc>k

inoremap jk <esc>

set undolevels=1000
set backspace=indent,eol,start
 
