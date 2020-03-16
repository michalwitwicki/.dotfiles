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

"=== Automatically install missing plugins on startup ==="
autocmd VimEnter *
  \  if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
  \|   PlugInstall --sync | q
  \| endif

"=== Plugins to install ==="
call plug#begin()
    Plug 'morhetz/gruvbox' "color scheme
    Plug 'tomasr/molokai' "color scheme
    Plug 'joshdick/onedark.vim'
    Plug 'nanotech/jellybeans.vim'
    Plug 'jacoborus/tender.vim'

    Plug 'scrooloose/nerdtree' "nerd tree
    "Plug 'Shougo/defx.nvim', { 'do': ':UpdateRemotePlugins' } "alternative for NERDTree
    "Plug 'justinmk/vim-dirvish' "is another alternative for nerdtree
    
    "Plug 'tiagofumo/vim-nerdtree-syntax-highlight'
    Plug 'ryanoasis/vim-devicons'
    Plug 'vim-airline/vim-airline' "airline

    "Plug 'dense-analysis/ale'
    "Plug 'mbbill/undotree'
    "Plug 'itchyny/lightline.vim'"maybe someday ?
    Plug 'mhinz/vim-startify'
    Plug 'sheerun/vim-polyglot' "A collection of language packs for Vim
call plug#end()

" ==============================================================================
" GENERAL
" ==============================================================================
"=== Leader key as comma ==="
let mapleader = ","
set nocompatible
"set t_Co=256
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

" Sets how many lines of history VIM has to remember
set history=500

" Set to auto read when a file is changed from the outside
set autoread

" More natural split opening
set splitbelow
set splitright

set wildmenu
" Ignore compiled files
set wildignore=*.o,*~,*.pyc
if g:os == "Windows"
    set wildignore+=.git\*,.hg\*,.svn\*
else
    set wildignore+=*/.git/*,*/.hg/*,*/.svn/*,*/.DS_Store
endif

" Let 'tl' toggle between this and the last accessed tab
let g:lasttab = 1
nmap <leader>tl :exe "tabn ".g:lasttab<CR>
au TabLeave * let g:lasttab = tabpagenr()

" Return to last edit position when opening files (You want this!)
" au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif

set noshowmode
set mouse=a
set hidden "allows to close window with not saved buffer

set encoding=utf-8

set noswapfile

set path+=** "Search down into subfolders

" ==============================================================================
" COLOR SCHEME MANAGEMENT
" ==============================================================================
syntax enable
let g:onedark_terminal_italics=1
let g:onedark_termcolors=256
let g:onedark_hide_endofbuffer=1
colorscheme gruvbox
"let g:molokai_original = 1
set background=dark "gruvbox dark mode

"=== Fixes annoying brackets coloring ==="
highlight MatchParen cterm=bold ctermbg=none ctermfg=Yellow

"=== Tab bar colors ==="
hi TabLineFill ctermfg=DarkGrey ctermbg=none
"hi TabLine ctermfg=Blue ctermbg=Yellow "not active tab
hi TabLineSel ctermfg=White ctermbg=Grey "active tab
"hi Title ctermfg=Black ctermbg=Yellow "this affect window counter per tab

hi Normal guibg=NONE ctermbg=NONE "transparent background

" ==============================================================================
" MAPPING
" ==============================================================================

"=== Mapping for easy clipboard ==="
vnoremap <C-c> "+y
map <C-v> "+P

"=== Mapping for easier split navigations ==="
:tnoremap <C-h> <C-\><C-N><C-w>h
:tnoremap <C-j> <C-\><C-N><C-w>j
:tnoremap <C-k> <C-\><C-N><C-w>k
:tnoremap <C-l> <C-\><C-N><C-w>l
:inoremap <C-h> <C-\><C-N><C-w>h
:inoremap <C-j> <C-\><C-N><C-w>j
:inoremap <C-k> <C-\><C-N><C-w>k
:inoremap <C-l> <C-\><C-N><C-w>l
:nnoremap <C-h> <C-w>h
:nnoremap <C-j> <C-w>j
:nnoremap <C-k> <C-w>k
:nnoremap <C-l> <C-w>l

"=== Run make from inside vim ==="
imap <f9> <ESC>:w<CR>:make<CR>
nmap <f9> :w<CR>:make<CR>

"=== Save with ctrl-s ==="
imap <c-s> <Esc>:w<CR>
nmap <c-s> :w<CR>

"=== Close tab/window with ctrl-w ==="
imap <c-w> <ESC>:q<CR>
nmap <c-w> :q<CR>

"=== Edit vimrc ==="
"nnoremap confe :e ~/Documents/vimrc/init.vim<CR>
nnoremap confe :e $MYVIMRC<CR>

"=== Reload vimrc ==="
"nnoremap confr :source ~/Documents/vimrc/init.vim<CR>
nnoremap confr :source $MYVIMRC<CR>

"=== Adding empty lines above or below current one ==="
nmap <a-Enter> O<Esc>j
nmap <CR> o<Esc>k

"=== Alternative to ESC ==="
inoremap hh <esc>

"=== Resizing splits ==="
:nnoremap <silent> <c-Up> <c-w>+
:nnoremap <silent> <c-Down> <c-w>-
:nnoremap <silent> <c-Right> <c-w>>
:nnoremap <silent> <c-Left> <c-w><

"=== Exit terminal-mode ==="
:tnoremap <Esc> <c-\><c-n>

"=== Traversing long lines ==="
nnoremap <Up> gk
nnoremap <Down> gj

" ==============================================================================
" COMMANDS
" ==============================================================================
"Create tags file
command! MakeTags !ctags -R .

" ==============================================================================
" AUTO COMMANDS
" ==============================================================================
"=== Open Startify on startup ==="
"autocmd VimEnter * Startify
autocmd VimEnter * NERDTree
autocmd BufWinEnter * NERDTreeMirror

"=== Focus right window on startup ==="
autocmd VimEnter * wincmd l 

"=== Line numbering auto toggle ==="
"augroup numbertoggle
"    autocmd!
"    autocmd BufEnter,FocusGained,InsertLeave * set relativenumber
"    autocmd BufLeave,FocusLost,InsertEnter   * set norelativenumber
"augroup END

"=== Switch tab to last active ==="
au TabLeave * let g:lasttab = tabpagenr()
nnoremap <silent> <c-Space> :exe "tabn ".g:lasttab<cr>
vnoremap <silent> <c-Space> :exe "tabn ".g:lasttab<cr>

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

"=== Commenting blocks of code ==="
"autocmd FileType c,cpp,java,scala let b:comment_leader = '// '
"autocmd FileType sh,ruby,python   let b:comment_leader = '# '
"autocmd FileType conf,fstab       let b:comment_leader = '# '
"autocmd FileType tex              let b:comment_leader = '% '
"autocmd FileType mail             let b:comment_leader = '> '
"autocmd FileType vim              let b:comment_leader = '" '
"noremap <silent> ,cc :<C-B>silent <C-E>s/^/<C-R>=escape(b:comment_leader,'\/')<CR>/<CR>:nohlsearch<CR>
"noremap <silent> ,cu :<C-B>silent <C-E>s/^\V<C-R>=escape(b:comment_leader,'\/')<CR>//e<CR>:nohlsearch<CR>

let s:comment_map = { 
    \   "c": '\/\/',
    \   "cpp": '\/\/',
    \   "go": '\/\/',
    \   "java": '\/\/',
    \   "javascript": '\/\/',
    \   "lua": '--',
    \   "scala": '\/\/',
    \   "php": '\/\/',
    \   "python": '#',
    \   "ruby": '#',
    \   "rust": '\/\/',
    \   "sh": '#',
    \   "desktop": '#',
    \   "fstab": '#',
    \   "conf": '#',
    \   "profile": '#',
    \   "bashrc": '#',
    \   "bash_profile": '#',
    \   "mail": '>',
    \   "eml": '>',
    \   "bat": 'REM',
    \   "ahk": ';',
    \   "vim": '"',
    \   "tex": '%',
    \ }

function! ToggleComment()
    if has_key(s:comment_map, &filetype)
        let comment_leader = s:comment_map[&filetype]
        if getline('.') =~ '^\s*$'
            " Skip empty line
            return
        endif
        if getline('.') =~ '^\s*' . comment_leader
            " Uncomment the line
            execute 'silent s/\v\s*\zs' . comment_leader . '\s*\ze//'
        else
            " Comment the line
            execute 'silent s/\v^(\s*)/\1' . comment_leader . ' /'
        endif
    else
        echo "No comment leader found for filetype"
    endif
endfunction

nnoremap <C-_> :call ToggleComment()<cr>
vnoremap <C-_> :call ToggleComment()<cr>

"=== Remeber folds after restart ===" 
augroup remember_folds
  autocmd!
  "autocmd BufWinLeave * mkview
  autocmd BufWinEnter * silent! loadview
augroup END

"=== Set insert-mode when entering the terminal ===" 
autocmd BufWinEnter,WinEnter term://* startinsert

"=== Set normal-mode when leaving terminal ===" 
"autocmd BufLeave term://* stopinsert

" ==============================================================================
" PLUGIN NERDTree
" ==============================================================================
"=== Mapping NERDTree toggler ===" 
map <C-n> :NERDTreeToggle<CR>

"=== Closing vim if the only window left is a NERDTree ==="
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

let NERDTreeMinimalUI = 1
let NERDTreeShowLineNumbers=0

" ==============================================================================
" PLUGIN Airline
" ==============================================================================
"=== Airline whitespace disable (annoying prompt) ==="
let g:airline#extensions#whitespace#enabled = 0

"=== Powerline fonts in airline ==="
"For this to work installation of fonts is needed, github.com/powerline/fonts
let g:airline_powerline_fonts = 1

"=== Airline theme ==="
let g:airline_theme='onedark'

"let g:airline#extensions#tabline#enabled = 1

" vim-devicons
let g:DevIconsEnableFoldersOpenClose = 1

let g:WebDevIconsUnicodeDecorateFileNodesExtensionSymbols = {}
let g:WebDevIconsUnicodeDecorateFileNodesExtensionSymbols['html'] = ''
let g:WebDevIconsUnicodeDecorateFileNodesExtensionSymbols['js'] = ''
let g:WebDevIconsUnicodeDecorateFileNodesExtensionSymbols['json'] = ''
let g:WebDevIconsUnicodeDecorateFileNodesExtensionSymbols['jsx'] = 'ﰆ'
let g:WebDevIconsUnicodeDecorateFileNodesExtensionSymbols['md'] = ''
let g:WebDevIconsUnicodeDecorateFileNodesExtensionSymbols['vim'] = ''
let g:WebDevIconsUnicodeDecorateFileNodesExtensionSymbols['yaml'] = ''
let g:WebDevIconsUnicodeDecorateFileNodesExtensionSymbols['yml'] = ''

let g:WebDevIconsUnicodeDecorateFileNodesPatternSymbols = {}
let g:WebDevIconsUnicodeDecorateFileNodesPatternSymbols['.*vimrc.*'] = ''
let g:WebDevIconsUnicodeDecorateFileNodesPatternSymbols['.gitignore'] = ''
let g:WebDevIconsUnicodeDecorateFileNodesPatternSymbols['package.json'] = ''
let g:WebDevIconsUnicodeDecorateFileNodesPatternSymbols['package.lock.json'] = ''
let g:WebDevIconsUnicodeDecorateFileNodesPatternSymbols['node_modules'] = ''
let g:WebDevIconsUnicodeDecorateFileNodesPatternSymbols['webpack\.'] = 'ﰩ'

let g:NERDTreeHighlightFolders = 1
let g:NERDTreeHighlightFoldersFullName = 1

" ==============================================================================
" TIPS/ LESSONS/ TUTORIALS ?
" ==============================================================================
"=== Concerning folding ==="
"zf => create a fold on visual selected lines
"zf#j => fold down # lines
"za => unfold
"zR => unfold all

"=== Splits, tabs, buffers ==="
":new
":vnew
":tabnew :tabe
":edit or better version :find
":ls for listing buffers
":b N for moving to Nth buffer
":bd N for deleting buffer

"=== Resizing ==="
":resize N
":vertical resize N

"=== Finding Files ===" 
"hit tab to :find by partial match
"use * to make it fuzzy

"=== Tag Jumping ==="
"^] => jump to tag under cursor
"g^] => for ambiguous tags
"^t => jump back up the tag stack

"=== Autocomplete ==="
"check documentation in |ins-completion|
"^x^n for just this file
"^x^f for filenames
"^x^] for tags only
"^n for anything specified by the 'complete' option
"^n and ^p to go back and forth in the suggestion list

"=== Others ==="
"gx to open link in browser

"=== TODO ===
"   - Folding sections
"   - Build in autocomplete system 

