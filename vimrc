" vim: et ts=2 sts=2 sw=2 tw=80

set nocompatible

filetype off

call plug#begin('~/.vim/plugged')

Plug 'itchyny/lightline.vim'

Plug 'liuchengxu/vista.vim'

Plug 'junegunn/vim-easy-align'

Plug 'Yggdroot/LeaderF', { 'do': ':LeaderfInstallCExtension', 'on': [] }

" 注释
Plug 'tpope/vim-commentary'

Plug 'tpope/vim-surround'

Plug 'tpope/vim-abolish'

" 作用于整个文件 例如"*yae
Plug 'kana/vim-textobj-user'
Plug 'kana/vim-textobj-entire'

" 语言
Plug 'Vimjas/vim-python-pep8-indent', { 'for': 'python' }
Plug 'chrisbra/csv.vim', { 'for': 'csv' }
" Plug 'jaxbot/semantic-highlight.vim', {
"             \ 'for': ['python', 'javascript', 'c', 'cpp', 'rust', 'typescript']
"             \ }

" Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'uiiaoo/java-syntax.vim'

" lsp coc
Plug 'neoclide/coc.nvim', { 'branch': 'release' }
Plug 'josa42/vim-lightline-coc'
Plug 'honza/vim-snippets'

" debug
Plug 'puremourning/vimspector'

Plug 'vim-test/vim-test'

Plug 'mbbill/undotree'

Plug 'Raimondi/delimitMate', { 'on': [] }

Plug 'justinmk/vim-sneak'
" Plug 'rhysd/clever-f.vim' 2021-06-13 658384e0f89fc31dba94e71eae2484cabe1ad7d0

Plug 'Yggdroot/indentLine'

" markdown
Plug 'iamcco/markdown-preview.vim', { 'for': 'markdown' }

Plug 'tpope/vim-repeat'

Plug 'luochen1990/rainbow'

Plug 'ybian/smartim'

call plug#end()

augroup load_delimitMate
  au!
  au InsertEnter * call plug#load('delimitMate') | au! load_delimitMate
augroup END
augroup lazy_load
  au!
  au BufWinEnter * call plug#load(['LeaderF']) | au! lazy_load
augroup END

so ~/.vim/base.vim

so ~/.vim/plugin_config.vim

if has('nvim')
  so ~/.vim/nvim.vim
endif
