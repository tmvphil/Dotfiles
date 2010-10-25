"  # # # # # # # # #         
" General Settings #
"  # # # # # # # # #
filetype off
call pathogen#helptags()
call pathogen#runtime_append_all_bundles()
filetype plugin indent on

set nocompatible
set tabstop=4
set shiftwidth=4
set expandtab
set smarttab
set showcmd
set showmode
set relativenumber
set incsearch
set showmatch
set hlsearch
set ignorecase
set smartcase
set gdefault
set autoindent
" set colorcolumn=80
set backupdir=~/.vim/backup
colorscheme wombat256
syntax on

"  # # # # #
" Mappings #
"  # # # # #
let mapleader =  ","
nnoremap j gj
nnoremap k gk
nnoremap J <C-f>
nnoremap K <C-b>
nnoremap ; :
nnoremap <leader><space> :noh<cr>   
nnoremap <tab> %
vnoremap <tab> %
nnoremap <leader>W :%s/\s\+$//<cr>:let @/=''<CR>
"  # # # # # # #
" Autocommands #
"  # # # # # # #
au FocusLost * :wa

"  # # # # # # # # #
" Plugins Settings #
"  # # # # # # # # #

" MiniBufferExplorer
let g:miniBufExplMapWindowNavVim = 1
let g:miniBufExplModSelTarget = 1

" Tasklist
cabbrev task TaskList

" TagsList
cabbrev tags TlistToggle

" NerdTree
cabbrev tree NERDTreeToggle
