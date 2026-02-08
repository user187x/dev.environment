
" This MUST be the first line in your .vimrc to ensure no side effects.
set nocompatible

" ==========================================
"  AIR-GAP VIMRC
" ==========================================

call plug#begin('~/.vim/plugged')
 Plug 'preservim/nerdtree'
 Plug 'junegunn/fzf'
 Plug 'junegunn/fzf.vim'
 Plug 'vim-airline/vim-airline'
 Plug 'morhetz/gruvbox'
 Plug 'sheerun/vim-polyglot'
call plug#end()

" --- General User Interface ---
" Enable syntax highlighting based on file type
syntax on
" Show line numbers on the left sidebar
set number
" Show the line number relative to the line the cursor is on
set relativenumber
" Highlight the line currently under the cursor for better visibility
set cursorline
" Wrap lines that are longer than the screen width
set wrap
" Don't make a backup file before overwriting a file
set nobackup
" Don't create a swap file for the current buffer
set noswapfile
" --- Indentation & Tabs ---
" Copy indent from the current line when starting a new line
set autoindent
" Enable smart indentation (e.g., indenting automatically after a '{')
set smartindent
" Convert tabs to spaces (standard for most modern coding styles)
set expandtab
" The number of spaces inserted for each indentation level
set shiftwidth=4
" The number of spaces a <Tab> counts for
set tabstop=4
" When pressing <Tab> or <Backspace>, treat spaces like a tab
set softtabstop=4
" --- Search Behavior ---
" Highlight all search matches
set hlsearch
" Show search matches as you type
set incsearch
" Ignore case when searching
set ignorecase
" Override 'ignorecase' if the search pattern contains uppercase characters
set smartcase
" --- Usability & Navigation ---
" Allow hidden buffers (opening a new file without saving current one)
set hidden
" Enable system clipboard
set clipboard=unnamedplus
" Keep 8 lines of context above/below the cursor when scrolling
set scrolloff=8
" Display incomplete commands in the bottom right corner
set showcmd
" Enhanced command-line completion menu
set wildmenu
" Reduce screen redraws during macros
set lazyredraw
" Allow backspacing over auto-indentation, line breaks, and start of insert
set backspace=indent,eol,start

" --- Key Mappings ---
let mapleader = " "
inoremap jj <Esc>
nnoremap <leader><space> :nohlsearch<CR>
nnoremap <leader>w :w<CR>
nnoremap <leader>q :q<CR>

" --- Plugin Settings ---
" NERDTree Toggle
nnoremap <C-n> :NERDTreeToggle<CR>
autocmd BufEnter * if tabpagenr('$') == 1 && winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() | quit | endif

" FZF Finder
nnoremap <C-p> :Files<CR>

" Theme
set background=dark
try
 colorscheme gruvbox
catch
 colorscheme default
endtry
