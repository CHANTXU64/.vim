" vim: et ts=2 sts=2 sw=2 tw=80

set nocompatible

filetype off

call plug#begin('~/.vim/plugged')
Plug 'itchyny/lightline.vim'

Plug 'mhinz/vim-signify'

Plug 'preservim/nerdtree',
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'jistr/vim-nerdtree-tabs'

Plug 'chrisbra/csv.vim'

Plug 'liuchengxu/vista.vim'

Plug 'junegunn/vim-easy-align'

Plug 'Yggdroot/LeaderF'

Plug 'wsdjeg/vim-fetch'

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

" debug
Plug 'puremourning/vimspector'

" git
Plug 'tpope/vim-fugitive'

Plug 'mbbill/undotree'

Plug 'Raimondi/delimitMate'

Plug 'easymotion/vim-easymotion'

Plug 'Yggdroot/indentLine'

" google code style
" Plug 'google/vim-maktaba', { 'for': [ 'cpp', 'c', 'javascript', 'typescript', 'css', 'html', 'json', 'shell', 'python' ] }
" Plug 'google/vim-glaive', { 'for': [ 'cpp', 'c', 'javascript', 'typescript', 'css', 'html', 'json', 'shell', 'python' ] }
" Plug 'google/vim-codefmt', { 'for': [ 'cpp', 'c', 'javascript', 'typescript', 'css', 'html', 'json', 'shell', 'python' ] }

" markdown
Plug 'iamcco/mathjax-support-for-mkdp', { 'for': 'markdown' }
Plug 'iamcco/markdown-preview.vim', { 'for': 'markdown' }

" runtime macros/matchit.vim
Plug 'andymass/vim-matchup'

Plug 'tpope/vim-repeat'

Plug 'luochen1990/rainbow'

call plug#end()

so ~/.vim/base.vim

"##### auto fcitx  ###########
let g:fcitx_auto_toggle_flag = 0
function! Toggle_fcitx_auto_toggle_flag()
  if g:fcitx_auto_toggle_flag
    let g:fcitx_auto_toggle_flag = 0
    echo 'Fcitx auto toggle - disabled'
  else
    let g:fcitx_auto_toggle_flag = 1
    echo 'Fcitx auto toggle - enabled'
  endif
endfunction
let g:input_toggle = 0
function! Fcitx2en()
  if g:fcitx_auto_toggle_flag
    let s:input_status = system("fcitx-remote")
    if s:input_status == 2
      let g:input_toggle = 1
      let l:a = system("fcitx-remote -c")
    endif
  endif
endfunction
function! Fcitx2zh()
  if g:fcitx_auto_toggle_flag
    let s:input_status = system("fcitx-remote")
    if s:input_status != 2 && g:input_toggle == 1
      let l:a = system("fcitx-remote -o")
      let g:input_toggle = 0
    endif
  endif
endfunction
"退出插入模式
autocmd InsertLeave * call Fcitx2en()
"进入插入模式
autocmd InsertEnter * call Fcitx2zh()
nmap <Leader><Leader>f :call Toggle_fcitx_auto_toggle_flag()<CR>
xmap <Leader><Leader>f :call Toggle_fcitx_auto_toggle_flag()<CR>
"##### auto fcitx end ######

so ~/.vim/plugin_config.vim
