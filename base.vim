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
hi Cursor ctermfg=231 ctermbg=black

nnoremap ' `
xnoremap ' `
onoremap ' `
nnoremap _ :
xnoremap _ :

nnoremap q_ q:
xnoremap q_ q:

nnoremap & :&&<CR>
xnoremap & :&&<CR>

nnoremap 0 ^
xnoremap 0 ^
onoremap 0 ^
nnoremap ^ 0
xnoremap ^ 0
onoremap ^ 0

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
nnoremap T F
nnoremap F T
xnoremap T F
xnoremap F T

nnoremap , ;
nnoremap ; ,
xnoremap , ;
xnoremap ; ,
onoremap , ;
onoremap ; ,

nnoremap Y "+y
xnoremap Y "+y

nnoremap <silent> # yiw/<C-R>"<CR>

xnoremap <silent> * :<C-U>call VisualSelection('', '')<CR>/<C-R>=@/<CR><CR>
xnoremap <silent> # :<C-U>call VisualSelection('', '')<CR>?<C-R>=@/<CR><CR>
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

" 默认虚拟替换
nnoremap R gR

let mapleader = " "
map <space> <nop>

syntax on

set wrap "Wrap lines

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
nmap <Leader><Leader>qq :q!<CR>

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

" Don't redraw while executing macros (good performance config)
set lazyredraw

" For regular expressions turn magic on
set magic

"清屏并暂时关闭查找高亮
nnoremap <silent> <Leader>l :<C-U>nohlsearch<CR>

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

set undofile
set undodir=~/.vimtmp/undo
set dir=~/.vimtmp/swap

"展开当前文件所在目录
cnoremap <expr> %% getcmdtype() == ':' ? expand('%:h').'/' : '%%'

cnoremap <expr> <space><space> getcmdtype() == ':' ? '+' : '  '

cnoremap <C-A> <Home>
cnoremap <C-E> <End>
cnoremap <C-P> <Up>
cnoremap <C-N> <Down>
cnoremap <C-B> <Left>
cnoremap <C-F> <Right>
inoremap <C-B> <Left>
inoremap <C-F> <Right>

" Close all the buffers
map <leader>ba :bufdo bd<CR>

:let g:csv_delim=','

" Don't close window, when deleting a buffer
nmap <silent> <leader>bd :call <SID>BufcloseCloseIt()<CR>:tabclose<CR>gT
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

nmap <C-J> <C-W>j
nmap <C-K> <C-W>k
nmap <C-H> <C-W>h
nmap <BS> <C-W>h
nmap <C-L> <C-W>l
xmap <C-J> <C-W>j
xmap <C-K> <C-W>k
xmap <C-H> <C-W>h
xmap <BS> <C-W>h
xmap <C-L> <C-W>l
nmap <C-W><C-J> <C-W>J
nmap <C-W><C-K> <C-W>K
nmap <C-W><C-H> <C-W>H
nmap <C-W><BS> <C-W>H
nmap <C-W><C-L> <C-W>L

set ttimeoutlen=50
set timeoutlen=1000
set updatetime=200

" Useful mappings for managing tabs
map <C-T> <Nop>
nmap <C-T>n :tabnew<CR>
nmap <C-T>o :tabonly<CR>
nmap <C-T>m :tabmove 
nmap <C-T><C-T> :tabnext<CR>

" Opens a new tab with the current buffer's path
" Super useful when editing files in the same directory
map <leader>te :tabedit <C-R>=expand("%:p:h")<CR>/

" Switch CWD to the directory of the open buffer
map <leader>cd :cd %:p:h<CR>:pwd<CR>

" Return to last edit position when opening files (You want this!)
au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$")
            \ | exe "normal! g'\"" | endif

map <leader>ss :setlocal spell!<CR>

nmap - <Nop>

" Shortcuts using <leader>
map <leader>sa zg
map <leader>s? z=
noremap -s ]s

nmap [b :<C-U>bprevious<CR>
nmap [B :<C-U>bfirst<CR>
nmap -b :<C-U>bnext<CR>
nmap -B :<C-U>blast<CR>
nmap [o :<C-U>lprevious<CR>
nmap [O :<C-U>lfirst<CR>
nmap -o :<C-U>lnext<CR>
nmap -O :<C-U>llast<CR>
nmap [a :<C-U>cprevious<CR>
nmap [A :<C-U>cfirst<CR>
nmap -a :<C-U>cnext<CR>
nmap -A :<C-U>clast<CR>
nmap [t :tabprevious<CR>
nmap [T :tabfirst<CR>
nmap -t :tabnext<CR>
nmap -T :tablast<CR>

nmap [<space> O<Esc>j
nmap -<space> o<Esc>k
nmap [<C-H> kdd
nmap [<BS> kdd
nmap -<C-H> jddk
nmap -<BS> jddk

map <up> <Nop>
map <down> <Nop>
map <left> :vertical resize-3<CR>
map <right> :vertical resize+3<CR>

nmap <leader>cw :cw 10<CR>

nmap Q :registers<CR>

" map <C-U> <C-Y><C-Y><C-Y><C-Y><C-Y><C-Y><C-Y><C-Y><C-Y><C-Y><C-Y><C-Y><C-Y><C-Y><C-Y><C-Y>
" map <C-D> <C-E><C-E><C-E><C-E><C-E><C-E><C-E><C-E><C-E><C-E><C-E><C-E><C-E><C-E><C-E><C-E>

