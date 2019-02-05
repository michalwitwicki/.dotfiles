".vimrc for neovim should be in
"~/.config/nvim/init.vim

"--- automatic Plug installation ---"
if empty(glob('~/.local/share/nvim/site/autoload/plug.vim'))
  silent !curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

"--- plugins to Plug ---"
call plug#begin()
	Plug 'roosta/srcery' "color scheme
    Plug 'morhetz/gruvbox' "color scheme
    Plug 'dracula/vim', { 'as': 'dracula' } "color scheme
    Plug 'tomasr/molokai' "color scheme

    Plug 'octol/vim-cpp-enhanced-highlight' "cpp better highlight
    Plug 'scrooloose/nerdtree' "nerd tree
    Plug 'vim-airline/vim-airline' "airline
    Plug 'vim-airline/vim-airline-themes' "airline themes
    Plug 'tpope/vim-fugitive' "git wrapper
call plug#end()

"--- basic stuff ---"
set t_Co=256
set number
set relativenumber
set smartindent
set tabstop=4
set shiftwidth=4
set expandtab
set textwidth=80 "automatic line break
"set termguicolors

"--- color scheme management ---"
syntax on
colorscheme molokai 
let g:molokai_original = 1
"set background=dark "gruvbox dark mode

"--- mapping for easy clipboard ---"
vnoremap <C-c> "+y
map <C-v> "+P

"--- mapping for easier split navigations ---"
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

"--- more natural split opening ---"
set splitbelow
set splitright

"--- mapping NERDTree toggler ---" 
map <C-n> :NERDTreeToggle<CR>

"--- closing vim if the only window left is a NERDTree ---"
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

"--- airline whitespace disable (annoying prompt)---"
let g:airline#extensions#whitespace#enabled = 0

"--- powerline fonts in airline ---"
"for this to work installation of fonts is needed, github.com/powerline/fonts
let g:airline_powerline_fonts = 1

"--- airline theme ---"
let g:airline_theme='violet'

"--- automatic closing brackets ---"
"inoremap " ""<left>
"inoremap ' ''<left>
"inoremap ( ()<left>
"inoremap [ []<left>
"inoremap { {}<left>
"inoremap {<CR> {<CR>}<ESC>O
"inoremap {;<CR> {<CR>};<ESC>O

"--- launching hex view ---"
"nnoremap <Space> :%!xxd -c 1 -e<CR>

"--- run make from inside vim <3 ---"
imap <f9> <ESC>:w<CR>:make<CR>
nmap <f9> :w<CR>:make<CR>

"--- save with ctrl - s ---"
imap <c-s> <Esc>:w<CR>
nmap <c-s> :w<CR>

"--- close tab wit ctrl - w ---"
imap <c-w> <ESC>:q<CR>
nmap <c-w> :q<CR>

"--- open NERDTree on startup ---"
autocmd VimEnter * NERDTree

"--- edit vimrc ---"
nnoremap confe :e $MYVIMRC<CR>

"--- reload vimrc ---"
nnoremap confr :source $MYVIMRC<CR>

"--- super intelligence bracket management ---"
inoremap ( ()<Esc>i
inoremap [ []<Esc>i
inoremap { {<CR>}<Esc>O
autocmd Syntax html,vim inoremap < <lt>><Esc>i| inoremap > <c-r>=ClosePair('>')<CR>
inoremap ) <c-r>=ClosePair(')')<CR>
inoremap ] <c-r>=ClosePair(']')<CR>
inoremap } <c-r>=CloseBracket()<CR>
inoremap " <c-r>=QuoteDelim('"')<CR>
inoremap ' <c-r>=QuoteDelim("'")<CR>

function ClosePair(char)
    if getline('.')[col('.') - 1] == a:char
    return "\<Right>"
    else
    return a:char
    endif
endf

function CloseBracket()
    if match(getline(line('.') + 1), '\s*}') < 0
    return "\<CR>}"
    else
    return "\<Esc>j0f}a"
    endif
endf

function QuoteDelim(char)
    let line = getline('.')
    let col = col('.')
    if line[col - 2] == "\\"
    "Inserting a quoted quotation mark into the string
    return a:char
    elseif line[col - 1] == a:char
    "Escaping out of the string
    return "\<Right>"
    else
    "Starting a string
    return a:char.a:char."\<Esc>i"
    endif
endf

"--- alternative to ESC ---"
inoremap hh <esc>

"--- line numbering auto toggle ---"
augroup numbertoggle
    autocmd!
    autocmd BufEnter,FocusGained,InsertLeave * set relativenumber
    autocmd BufLeave,FocusLost,InsertEnter   * set norelativenumber
augroup END

"--- TODO ---
"   - zwijanie funkcji / function fold
"   - Insert-mode only Caps Lock
"   - you complete me or something
