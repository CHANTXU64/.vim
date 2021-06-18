" vim: et ts=2 sts=2 sw=2 tw=80

set nocompatible

filetype off

call plug#begin('~/.vim/plugged')

Plug 'itchyny/lightline.vim'

Plug 'preservim/nerdtree', { 'on': 'NERDTreeTabsOpen' }
Plug 'Xuyuanp/nerdtree-git-plugin', { 'on': 'NERDTreeTabsOpen' }
Plug 'jistr/vim-nerdtree-tabs', { 'on': 'NERDTreeTabsOpen' }

Plug 'chrisbra/csv.vim', { 'for': 'csv' }

Plug 'liuchengxu/vista.vim'

Plug 'junegunn/vim-easy-align'

Plug 'Yggdroot/LeaderF', { 'do': ':LeaderfInstallCExtension' , 'on': [] }

Plug 'rhysd/accelerated-jk'
Plug 'psliwka/vim-smoothie'

" 注释
Plug 'tpope/vim-commentary'

Plug 'tpope/vim-surround'

Plug 'tpope/vim-abolish'

" 作用于整个文件 例如"*yae
Plug 'kana/vim-textobj-user'
Plug 'kana/vim-textobj-entire'

" 语法高亮
Plug 'sheerun/vim-polyglot'

" lsp coc
Plug 'neoclide/coc.nvim', { 'branch': 'release' }
Plug 'josa42/vim-lightline-coc'

" debug
Plug 'puremourning/vimspector'

Plug 'mbbill/undotree'

Plug 'Raimondi/delimitMate', { 'on': [] }

Plug 'justinmk/vim-sneak'
" Plug 'rhysd/clever-f.vim' 2021-06-13 658384e0f89fc31dba94e71eae2484cabe1ad7d0

Plug 'Yggdroot/indentLine'

" markdown
Plug 'iamcco/markdown-preview.vim', { 'for': 'markdown' }

Plug 'andymass/vim-matchup'

Plug 'tpope/vim-repeat'

Plug 'luochen1990/rainbow'

call plug#end()

augroup load_delimitMate
  autocmd!
  autocmd InsertEnter * call plug#load('delimitMate') | autocmd! load_delimitMate
augroup END
augroup load_LeaderF
  autocmd!
  autocmd VimEnter * call plug#load('LeaderF') | auto! load_LeaderF
augroup END


so ~/.vim/base.vim

so ~/.vim/plugin_config.vim
