"Place vimrc in:
"   - in case of linux:     ~/.config/nvim/init.vim
"   - in case of windows:   ~\AppData\Local\nvim\init.vim


" ==============================================================================
" DETECTING OPERATING SYSTEM
" ==============================================================================
if !exists("g:os")
    if has("win64") || has("win32") || has("win16")
        let g:os = "Windows"
    else
        let g:os = substitute(system('uname'), '\n', '', '')
    endif
endif


" ==============================================================================
" PLUG
" ==============================================================================
"=== Plug installation ==="
"In Linux case installation is automatic
if g:os != "Windows"
    if empty(glob('~/.local/share/nvim/site/autoload/plug.vim'))
      silent !curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs
        \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
      autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
    endif
endif

"In Windows case run script from link below in PowerShell
"https://github.com/junegunn/vim-plug

"=== Plugins to install ==="
call plug#begin()
    Plug 'morhetz/gruvbox' "color scheme
    Plug 'tomasr/molokai' "color scheme

    Plug 'octol/vim-cpp-enhanced-highlight' "cpp better highlight
    Plug 'numirias/semshi', {'do': ':UpdateRemotePlugins'} "python better highlight
    Plug 'scrooloose/nerdtree' "nerd tree
    Plug 'vim-airline/vim-airline' "airline
    Plug 'vim-airline/vim-airline-themes' "airline themes
call plug#end()


" ==============================================================================
" BASIC SETS
" ==============================================================================
set nocompatible
set t_Co=256
set number
set relativenumber
set smartindent
set tabstop=4
set shiftwidth=4
set expandtab
set textwidth=120 "automatic line break
set ruler
set backspace=indent,eol,start
set smarttab
set incsearch
set scrolloff=2
set sidescrolloff=5
filetype plugin on "for netrw
"set termguicolors

"=== more natural split opening ==="
set splitbelow
set splitright


" ==============================================================================
" THAT YOUTUBE VIDEO
" ==============================================================================
"=== Finding Files ===" 
"Search down into subfolders
"Provides tab-completion for all file-related tasks
set path+=**

"Dispaly all matching files when we tab complete
set wildmenu

"NOW WE CAN
"- hit tab to :find by partial match
"- use * to make it fuzzy

"THING TO CONSIDER
"- :ls lets you list all buffers
"- :b lets you autocomplete for any buffer

"=== Tag Jumping ==="
"Create tags file
command! MakeTags !ctags -R .

"NOW WE CAN
"- use ^] to jump to tag under cursor
"- use g^] for ambiguous tags
"- use ^t to jump back up the tag stack

"=== Autocomplete ==="
"check documentation in |ins-completion|
"^x^n for just this file
"^x^f for filenames
"^x^] for tags only
"^n for anything specified by the 'complete' option
"^n and ^p to go back and forth in the suggestion list


" ==============================================================================
" COLOR SCHEME MANAGEMENT
" ==============================================================================
syntax enable
colorscheme molokai 
"let g:molokai_original = 1
"set background=dark "gruvbox dark mode

"=== Fixes annoying brackets coloring ==="
highlight MatchParen cterm=bold ctermbg=none ctermfg=Yellow

"=== Tab bar colors ==="
hi TabLineFill ctermfg=DarkGrey ctermbg=none
"hi TabLine ctermfg=Blue ctermbg=Yellow "not active tab
hi TabLineSel ctermfg=White ctermbg=Grey "active tab
"hi Title ctermfg=Black ctermbg=Yellow "this affect window counter per tab


" ==============================================================================
" MAPPING
" ==============================================================================
"=== Mapping for easy clipboard ==="
vnoremap <C-c> "+y
map <C-v> "+P

"=== Mapping for easier split navigations ==="
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

"=== Run make from inside vim ==="
imap <f9> <ESC>:w<CR>:make<CR>
nmap <f9> :w<CR>:make<CR>

"=== Save with ctrl-s ==="
imap <c-s> <Esc>:w<CR>
nmap <c-s> :w<CR>

"=== Close tab wit ctrl-w ==="
imap <c-w> <ESC>:q<CR>
nmap <c-w> :q<CR>

"=== Edit vimrc ==="
nnoremap confe :e $MYVIMRC<CR>
"nnoremap confe :e ~/Documents/vimrc/init.vim<CR>

"=== Reload vimrc ==="
"nnoremap confr :source ~/Documents/vimrc/init.vim<CR>
nnoremap confr :source $MYVIMRC<CR>

"=== Adding empty lines above or below current one ==="
nmap <a-Enter> O<Esc>j
nmap <CR> o<Esc>k

"=== Alternative to ESC ==="
inoremap hh <esc>


" ==============================================================================
" AUTO COMMANDS
" ==============================================================================
"=== Focus right window on startup ==="
autocmd VimEnter * wincmd l 

"=== Line numbering auto toggle ==="
augroup numbertoggle
    autocmd!
    autocmd BufEnter,FocusGained,InsertLeave * set relativenumber
    autocmd BufLeave,FocusLost,InsertEnter   * set norelativenumber
augroup END

"=== Super intelligence bracket management ==="
inoremap ( ()<Esc>i
inoremap [ []<Esc>i
inoremap { {<CR>}<Esc>O
autocmd Syntax html,vim inoremap < <lt>><Esc>i| inoremap > <c-r>=ClosePair('>')<CR>
inoremap ) <c-r>=ClosePair(')')<CR>
inoremap ] <c-r>=ClosePair(']')<CR>
inoremap } <c-r>=CloseBracket()<CR>
"inoremap " <c-r>=QuoteDelim('"')<CR>
inoremap ' <c-r>=QuoteDelim("'")<CR>

function! ClosePair(char)
    if getline('.')[col('.') - 1] == a:char
    return "\<Right>"
    else
    return a:char
    endif
endf

function! CloseBracket()
    if match(getline(line('.') + 1), '\s*}') < 0
    return "\<CR>}"
    else
    return "\<Esc>j0f}a"
    endif
endf

function! QuoteDelim(char)
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


" ==============================================================================
" PLUGIN NERDTree
" ==============================================================================
"=== Mapping NERDTree toggler ===" 
map <C-n> :NERDTreeToggle<CR>

"=== Closing vim if the only window left is a NERDTree ==="
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

"=== Open NERDTree on startup ==="
"autocmd VimEnter * NERDTree


" ==============================================================================
" PLUGIN Airline
" ==============================================================================
"=== Airline whitespace disable (annoying prompt) ==="
let g:airline#extensions#whitespace#enabled = 0

"=== Powerline fonts in airline ==="
"For this to work installation of fonts is needed, github.com/powerline/fonts
let g:airline_powerline_fonts = 1

"=== Airline theme ==="
let g:airline_theme='violet'


"=== TODO ===
"   - Folding sections
"   - Build in autocomplete system 
