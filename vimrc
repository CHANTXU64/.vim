" vim: et ts=2 sts=2 sw=2 tw=80

set nocompatible

filetype off

call plug#begin('~/.vim/plugged')
Plug 'vim-airline/vim-airline'

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

Plug 'neomake/neomake'

" lsp coc
Plug 'neoclide/coc.nvim', { 'branch': 'release' }

" git
Plug 'tpope/vim-fugitive'

Plug 'mbbill/undotree'

Plug 'Raimondi/delimitMate'

Plug 'easymotion/vim-easymotion'

Plug 'Yggdroot/indentLine'

" google code style
Plug 'google/vim-maktaba'
Plug 'google/vim-glaive'
Plug 'google/vim-codefmt'

" markdown
Plug 'iamcco/mathjax-support-for-mkdp'
Plug 'iamcco/markdown-preview.vim'

Plug 'terryma/vim-expand-region'

" runtime macros/matchit.vim
Plug 'andymass/vim-matchup'

call plug#end()

filetype indent on
filetype plugin on

set noshowmode

set background=light

hi ColorColumn ctermbg=255
hi CursorLine ctermbg=none
hi VertSplit ctermfg=253 ctermbg=251
hi LineNr ctermfg=244 ctermbg=251
hi CursorLineNr cterm=bold ctermfg=0 ctermbg=251
hi MatchParen ctermbg=45
hi Pmenu ctermfg=232 ctermbg=253
hi PmenuSel ctermfg=232 ctermbg=248
hi Search term=standout ctermfg=8 ctermbg=229

nnoremap ' `
xnoremap ' `
onoremap ' `
nnoremap - :
xnoremap - :

nnoremap & :&&<CR>
xnoremap & :&&<CR>

nnoremap < <<
nnoremap > >>

nnoremap H ^
xnoremap H ^
onoremap H ^
nnoremap L $
xnoremap L $
onoremap L $

nnoremap gh H
xnoremap gh H
onoremap gh H
nnoremap gl L
xnoremap gl L
onoremap gl L

nnoremap gH K
xnoremap gH K

nnoremap t f
nnoremap f t
xnoremap t f
xnoremap f t

nnoremap , ;
nnoremap ; ,
xnoremap , ;
xnoremap ; ,
onoremap , ;
onoremap ; ,

nnoremap Y "+y
xnoremap Y "+y

xnoremap <silent> * :<C-u>call VisualSelection('', '')<CR>/<C-R>=@/<CR><CR>
xnoremap <silent> # :<C-u>call VisualSelection('', '')<CR>?<C-R>=@/<CR><CR>
function! VisualSelection(direction, extra_filter) range
  let l:saved_reg = @"
  execute "normal! vgvy"

  let l:pattern = escape(@", "\\/.*'$^~[]")
  let l:pattern = substitute(l:pattern, "\n$", "", "")

  if a:direction == 'gv'
    call CmdLine("Ack '" . l:pattern . "' " )
  elseif a:direction == 'replace'
    call CmdLine("%s" . '/'. l:pattern . '/')
  endif

  let @/ = l:pattern
  let @" = l:saved_reg
endfunction

" A buffer becomes hidden when it is abandoned
set hid

" nmap g: q:
" vmap g: q:
" nmap g/ q/
" vmap g/ q/

nnoremap <C-n> n
nnoremap <C-p> N
onoremap <C-n> n
onoremap <C-p> N
xnoremap <C-n> n
xnoremap <C-p> N

nmap n ge
nmap N gE
omap n ge
omap N gE
xmap n ge
xmap N gE

" 默认虚拟替换
nnoremap R gR

let mapleader = " "
map <space> <nop>

syntax on

set wrap "Wrap lines

" nmap <f2> d:%s///gc<left><left><left>

set showcmd

" Sets how many lines of history VIM has to remember
set history=2000

" 默认十进制
set nrformats=

" Set to auto read when a file is changed from the outside
set autoread
au FocusGained,BufEnter * checktime

" Set utf8 as standard encoding and en_US as the standard language
set encoding=utf8

" Use Unix as the standard file type
set ffs=unix,dos,mac

" Set 7 lines to the cursor - when moving vertically using j/k
set scrolloff=7

" Fast saving
nmap <Leader>w :w<CR>
nmap <Leader>q :q<CR>
nmap q<Leader> <Leader>

" :W sudo saves the file
" (useful for handling the permission-denied error)
command! W execute 'w !sudo tee % > /dev/null' <bar> edit!

" Avoid garbled characters in Chinese language windows OS
let $LANG='en'
set langmenu=en

" Turn on the Wild menu
set wildmenu

" Ignore compiled files
set wildignore=*.o,*~,*.pyc
if has("win16") || has("win32")
  set wildignore+=.git\*,.hg\*,.svn\*
else
  set wildignore+=*/.git/*,*/.hg/*,*/.svn/*,*/.DS_Store
endif

set ruler

" Height of the command bar
set cmdheight=1

" Configure backspace so it acts as it should act
set backspace=eol,start,indent

set cursorline
set number
set relativenumber

set colorcolumn=81

set ignorecase
set smartcase
set hlsearch
set incsearch
exec "nohlsearch"
noremap <Leader>/ :%s///gn<CR>

" Don't redraw while executing macros (good performance config)
set lazyredraw

" For regular expressions turn magic on
set magic

"清屏并暂时关闭查找高亮
nnoremap <silent> <Leader>l :<C-u>nohlsearch<CR>

" Show matching brackets when text indicator is over them
set showmatch
" How many tenths of a second to blink when matching brackets
set mat=2

" No annoying sound on errors
set noerrorbells
set novisualbell
set t_vb=
set tm=500

set autoindent
set si "Smart indent
set shiftwidth=4
set tabstop=4
set expandtab
set smarttab

set splitright
set ttyfast

map <leader>pp :setlocal paste!<CR>

"展开当前文件所在目录
cnoremap <expr> %% getcmdtype() == ':' ? expand('%:h').'/' : '%%'

cnoremap <expr> <space><space> getcmdtype() == ':' ? '+' : '  '

cnoremap <C-a> <Home>
cnoremap <C-e> <End>
cnoremap <C-p> <Up>
cnoremap <C-n> <Down>
cnoremap <C-b> <Left>
cnoremap <C-f> <Right>

nmap <silent> <leader>,t :tabprevious<CR>
nmap <silent> <leader>,T :tabfirst<CR>
nmap <silent> <leader>.t :tabnext<CR>
nmap <silent> <leader>.T :tablast<CR>

nmap <silent> <leader>,b :bprevious<CR>
nmap <silent> <leader>,B :bfirst<CR>
nmap <silent> <leader>.b :bnext<CR>
nmap <silent> <leader>.B :blast<CR>
nmap <silent> <leader>bd :Bclose<CR>:tabclose<CR>gT

" Don't close window, when deleting a buffer
command! Bclose call <SID>BufcloseCloseIt()
function! <SID>BufcloseCloseIt()
  let l:currentBufNum = bufnr("%")
  let l:alternateBufNum = bufnr("#")

  if buflisted(l:alternateBufNum)
    buffer #
  else
    bnext
  endif

  if bufnr("%") == l:currentBufNum
    new
  endif

  if buflisted(l:currentBufNum)
    execute("bdelete! ".l:currentBufNum)
  endif
endfunction

nmap <C-j> <C-W>j
nmap <C-k> <C-W>k
nmap <C-h> <C-W>h
nmap <C-l> <C-W>l
xmap <C-j> <C-W>j
xmap <C-k> <C-W>k
xmap <C-h> <C-W>h
xmap <C-l> <C-W>l

set ttimeoutlen=50
set timeoutlen=1000
set updatetime=200

" Close all the buffers
map <leader>ba :bufdo bd<CR>

" Useful mappings for managing tabs
map <leader>tn :tabnew<CR>
map <leader>to :tabonly<CR>
map <leader>tc :tabclose<CR>
map <leader>tm :tabmove "
map <leader>t<leader> :tabnext

" Opens a new tab with the current buffer's path
" Super useful when editing files in the same directory
map <leader>te :tabedit <C-r>=expand("%:p:h")<CR>/

" Switch CWD to the directory of the open buffer
map <leader>cd :cd %:p:h<CR>:pwd<CR>

" Return to last edit position when opening files (You want this!)
au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif

"ctags
nnoremap <f5> :!ctags -R --exclude=.git<CR>

map <leader>ss :setlocal spell!<CR>

" Shortcuts using <leader>
map <leader>sn ]s
map <leader>sp [s
map <leader>sa zg
map <leader>s? z=

nmap [e [l
nmap [E [L
nmap ]e ]l
nmap ]E ]L

map <up> <Nop>
map <down> <Nop>
map <left> :vertical resize-3<CR>
map <right> :vertical resize+3<CR>

nmap <leader>cn :cn<CR>
nmap <leader>cp :cp<CR>
nmap <leader>cw :cw 10<CR>

nmap Q :registers<CR>

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