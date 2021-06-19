"""""""""""""""""""""""""""""""
"" => coc
"""""""""""""""""""""""""""""""
let g:coc_global_extensions = ['coc-tsserver', 'coc-clangd',
      \'coc-markdownlint', 'coc-snippets', 'coc-css', 'coc-tabnine',
      \'coc-html', 'coc-cmake', 'coc-pyright', 'coc-jedi', 'coc-git',
      \'coc-translator']
nnoremap <silent> <leader>h :call CocActionAsync('doHover')<cr>
nmap gd <Plug>(coc-definition)
nmap gD <Plug>(coc-implementation)
nmap gr <Plug>(coc-references)
vmap <leader>fs <Plug>(coc-format-selected)
nmap <leader>fs <Plug>(coc-format-selected)
nmap <leader>fae <Plug>(coc-format)
nmap <leader>r <Plug>(coc-rename)
autocmd CursorHold * silent call FuncCursorHold()
hi CocHighlightText ctermbg=254
hi CocErrorSign ctermbg=248 ctermfg=9
hi CocErrorFloat ctermbg=253
hi CocWarningSign ctermbg=248
hi CocWarningFloat ctermbg=253
hi CocInfoSign ctermbg=248
hi CocInfoFloat ctermbg=253
hi CocHintSign ctermbg=248
hi CocHintFloat ctermbg=253
imap <C-l> <Plug>(coc-snippets-expand)
nmap [e <Plug>(coc-diagnostic-prev)
nmap -e <Plug>(coc-diagnostic-next)
nmap [d <Plug>(coc-git-prevchunk)
nmap -d <Plug>(coc-git-nextchunk)
nmap <Leader>d <Plug>(coc-git-chunkinfo)

nmap <Leader>n <Plug>(coc-translator-p)
vmap <Leader>n <Plug>(coc-translator-pv)

function! FuncCursorHold()
if exists('*CocActionAsync')
  call CocActionAsync('highlight')
endif
endfunction


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => LeaderF
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:Lf_StlSeparator = { 'left': '', 'right': '' }
let g:Lf_PreviewResult = {
      \ 'File': 0,
      \ 'Buffer': 0,
      \ 'Mru': 0,
      \ 'Tag': 1,
      \ 'BufTag': 1,
      \ 'Function': 1,
      \ 'Rg': 0,
      \ 'Gtags': 1
      \}
let g:Lf_HistoryExclude = {
      \ 'cmd': ['^w!?', '^q!?', '^.\s*$'],
      \ 'search': ['^Plug']
      \}
let g:Lf_NormalMap = {
    \ "_":       [["<C-j>", "j"],
    \             ["<C-k>", "k"]],
    \ "File":    [["<ESC>", ':exec g:Lf_py "fileExplManager.quit()"<CR>']],
    \ "Buffer":  [["<ESC>", ':exec g:Lf_py "bufExplManager.quit()"<CR>']],
    \ "Mru":     [["<ESC>", ':exec g:Lf_py "mruExplManager.quit()"<CR>']],
    \ "Tag":     [["<ESC>", ':exec g:Lf_py "tagExplManager.quit()"<CR>']],
    \ "BufTag":  [["<ESC>", ':exec g:Lf_py "bufTagExplManager.quit()"<CR>']],
    \ "Rg":      [["<ESC>", ':exec g:Lf_py "rgExplManager.quit()"<CR>']],
    \ "Gtags":   [["<ESC>", ':exec g:Lf_py "gtagsExplManager.quit()"<CR>']],
    \ "Function":[["<ESC>", ':exec g:Lf_py "functionExplManager.quit()"<CR>']],
    \ "History": [["<ESC>", ':exec g:Lf_py "historyExplManager.quit()"<CR>']],
    \ "Command": [["<ESC>", ':exec g:Lf_py "commandExplManager.quit()"<CR>']]
    \}
let g:Lf_CommandMap = {
  \ '<C-P>': ['<C-O>'],
  \ '<C-J>': ['<C-N>'],
  \ '<C-K>': ['<C-P>'],
  \ '<Home>': ['<C-A>', '<Home>'],
  \ '<End>': ['<C-E>', '<End>'],
  \ '<Left>': ['<C-B>', '<Left>'],
  \ '<Right>': ['<C-F>', '<Right>'],
  \ '<C-V>': ['<C-\>'],
  \ '<C-]>': ['<C-V>'],
  \ '<C-O>': ['<C-I>']
  \}
let g:Lf_CursorBlink = 0
let g:Lf_WindowHeight = 0.30
let g:Lf_FollowLinks = 1

" buffers
nnoremap <C-B> :<C-U>LeaderfBuffer<CR>
" files
let g:Lf_ShortcutF = ']a'
" Mru
nnoremap <C-M> :<C-U>LeaderfMru<CR>
" bufTag
nnoremap ]t :<C-U>LeaderfBufTagCword<CR>
xnoremap ]t :<C-U><C-R>=printf('Leaderf bufTag --input %s', <SID>get_visual_selection())<CR><CR>
noremap ]T :<C-U>LeaderfBufTag<CR>
nnoremap ]<C-T> :<C-U>LeaderfBufTagAllCword<CR>
xnoremap ]<C-T> :<C-U><C-R>=printf('Leaderf bufTag --all --input %s', <SID>get_visual_selection())<CR><CR>
noremap ]st :<C-U>LeaderfBufTagAll<CR>
" function
nnoremap ]f :<C-U>LeaderfFunctionCword<CR>
xnoremap ]f :<C-U><C-R>=printf('Leaderf function --input %s', <SID>get_visual_selection())<CR><CR>
noremap ]F :<C-U>LeaderfFunction<CR>
nnoremap ]<C-F> :<C-U>LeaderfFunctionAllCword<CR>
xnoremap ]<C-F> :<C-U><C-R>=printf('Leaderf function --all --input %s', <SID>get_visual_selection())<CR><CR>
noremap ]sf :<C-U>LeaderfFunctionAll<CR>
" command
noremap ]x :<C-U>LeaderfCommand<CR>
" history
nnoremap q_ :<C-U>LeaderfHistoryCmd<CR>
xnoremap q_ :<C-U>LeaderfHistoryCmd<CR>
nnoremap q: :<C-U>LeaderfHistoryCmd<CR>
xnoremap q: :<C-U>LeaderfHistoryCmd<CR>
nnoremap q/ :<C-U>LeaderfHistorySearch<CR>
xnoremap q/ :<C-U>LeaderfHistorySearch<CR>
" rg
noremap <silent> <Leader>/ :Leaderf rg --all-buffers<CR>
noremap <silent> <Leader>? :Leaderf rg<CR>
nnoremap # :<C-U><C-R>=printf('Leaderf! rg --current-buffer -e %s ', expand('<cword>'))<CR><CR>
xnoremap # :<C-U><C-R>=printf('Leaderf! rg --current-buffer -e %s ', leaderf#Rg#visual())<CR><CR>
noremap ]<C-B> :<C-U><C-R>=printf('Leaderf! rg --all-buffers -e %s ', expand('<cword>'))<CR><CR>
noremap <C-F> :<C-U><C-R>=printf('Leaderf! rg -e %s ', expand('<cword>'))<CR><CR>
xnoremap ]# :<C-U><C-R>=printf('Leaderf! rg -F -e %s ', leaderf#Rg#visual())<CR><CR>
" gtags
let g:Lf_GtagsAutoGenerate = 1
let g:Lf_Gtagslabel = 'native-pygments'
noremap <leader>gr :<C-U><C-R>=printf('Leaderf! gtags -r %s --auto-jump', expand('<cword>'))<CR><CR>
noremap <leader>gd :<C-U><C-R>=printf('Leaderf! gtags -d %s --auto-jump', expand('<cword>'))<CR><CR>
" recall
noremap ]rt :<C-U>Leaderf! bufTag --recall<CR>
noremap ]rf :<C-U>Leaderf! function --recall<CR>
noremap ]rr :<C-U>Leaderf! rg --recall<CR>
noremap ]rg :<C-U>Leaderf! gtags --recall<CR>

let g:Lf_WildIgnore = {
      \ 'dir': ['.svn','.git','.hg','plugged','vendor','node_modules'],
      \ 'file': ['*.sw?','~$*','*.bak','*.exe','*.o','*.so','*.py[co]',
      \          '.DS_Store']
      \}

function! <SID>get_visual_selection()
    " Why is this not a built-in Vim script function?!
    let [line_start, column_start] = getpos("'<")[1:2]
    let [line_end, column_end] = getpos("'>")[1:2]
    let lines = getline(line_start, line_end)
    if len(lines) == 0
        return ''
    endif
    let lines[-1] = lines[-1][: column_end - (&selection == 'inclusive' ? 1 : 2)]
    let lines[0] = lines[0][column_start - 1:]
    return join(lines, "\n")
endfunction


""""""""""""""""""""""""""""""
" => Nerdtree
""""""""""""""""""""""""""""""
let NERDTreeMapCloseDir = 'n'
let NERDTreeMapCloseChildren = 'N'
let g:NERDTreeMapPreview = 'h'
let NERDTreeShowBookmarks=1
let NERDTreeIgnore = ['\.pyc$', '__pycache__']


""""""""""""""""""""""""""""""
" => Nerdtree-tabs
""""""""""""""""""""""""""""""
nmap <leader>tt :NERDTreeTabsOpen<CR> :NERDTreeSteppedOpen<CR>
nmap <leader>tT :NERDTreeTabsClose<CR>


""""""""""""""""""""""""""""""
" => NERDTree-git
""""""""""""""""""""""""""""""
let g:NERDTreeGitStatusIndicatorMapCustom = {
      \ 'Modified'  : 'M',
      \ 'Staged'    : 'S',
      \ 'Untracked' : 'U',
      \ 'Renamed'   : 'R',
      \ 'Unmerged'  : 'ᶴ',
      \ 'Deleted'   : 'D',
      \ 'Dirty'     : '˜',
      \ 'Clean'     : 'ᵅ',
      \ 'Unknown'   : '?'
      \ }


""""""""""""""""""""""""""""""
" => delimitMate
""""""""""""""""""""""""""""""
let delimitMate_expand_cr = 2
let delimitMate_expand_space = 1
let delimitMate_excluded_regions = 'Comment'
imap <BS> <Plug>delimitMateBS
imap <C-h> <Plug>delimitMateBS


""""""""""""""""""""""""""""""
" => vim-python-pep8-indent
""""""""""""""""""""""""""""""
let g:python_pep8_indent_multiline_string = -2


""""""""""""""""""""""""""""""
" => indentLine
""""""""""""""""""""""""""""""
let g:indentLine_char = '▏'
let g:indentLine_concealcursor = 0


""""""""""""""""""""""""""""""
" => vim-easy-align
""""""""""""""""""""""""""""""
nmap ga <Plug>(EasyAlign)


""""""""""""""""""""""""""""""
" => vista
""""""""""""""""""""""""""""""
let g:vista_sidebar_width = 35
let g:vista_icon_indent = ['╰─▸ ', '├─▸ ']
nmap <Leader>v :Vista coc<CR>


""""""""""""""""""""""""""""""
" => airline theme
""""""""""""""""""""""""""""""
let g:airline_theme='sol'


""""""""""""""""""""""""""""""
" => LargeFile
""""""""""""""""""""""""""""""
let g:LargeFile = 100


""""""""""""""""""""""""""""""
" => Lightline CocExtension
""""""""""""""""""""""""""""""
set laststatus=2
let g:lightline = {
      \ 'colorscheme': 'chant',
      \ 'active': {
      \   'left': [ [ 'mode' ],
      \             [ 'paste', 'spell' ],
      \             [ 'git-status', 'readonly', 'filename' ] ],
      \   'right': [ [ 'coc_info', 'coc_hints', 'coc_errors', 'coc_warnings', 'coc_ok' ],
      \              [ 'coc_status' ],
      \              [ 'lineinfo' ],
      \              [ 'fileformat', 'fileencoding', 'filetype' ] ]
      \ },
      \ 'inactive': {
      \   'left': [ [ 'readonly', 'filename' ] ],
      \   'right': [ [ 'lineinfo' ],
      \              [ 'fileencoding' ] ]
      \ },
      \ 'component': {
      \   'paste': '%{&paste?"P":""}',
      \ },
      \ 'component_function': {
      \   'filename': 'LightlineFilename'
      \ },
      \ 'mode_map': {
      \   'n' : 'N',
      \   'i' : 'I',
      \   'R' : 'R',
      \   'v' : 'V',
      \   'V' : 'V-L',
      \   "\<C-v>": 'V-B',
      \   'c' : 'C',
      \   's' : 'S',
      \   'S' : 'S-L',
      \   "\<C-s>": 'S-B',
      \   't': 'T',
      \ }
      \ }
function! LightlineGitStatus() abort
  let status = get(g:, 'coc_git_status', '')
  " let b_status = get(b:, 'coc_git_status', '')
  return status
endfunction
function! LightlineFilename()
  let filename = expand('%:t') !=# '' ? expand('%:t') : '[No Name]'
  let modified = &modified ? ' +' : ''
  return filename . modified
endfunction

if exists("*lightline#coc#register")
  call lightline#coc#register()
endif


""""""""""""""""""""""""""""""
" => vimspector
""""""""""""""""""""""""""""""
let g:vimspector_enable_mappings = 'VISUAL_STUDIO'


""""""""""""""""""""""""""""""
" => Rainbow
""""""""""""""""""""""""""""""
let g:rainbow_active = 1
let g:rainbow_conf = {
\	'guifgs': ['royalblue3', 'darkorange3', 'seagreen3', 'firebrick'],
\	'ctermfgs': ['darkblue', 'darkyellow', 'darkcyan', 'darkmagenta'],
\}


""""""""""""""""""""""""""""""
" => Sneak
""""""""""""""""""""""""""""""
nmap ; <Plug>Sneak_,
nmap , <Plug>Sneak_;
omap ; <Plug>Sneak_,
omap , <Plug>Sneak_;
xmap ; <Plug>Sneak_,
xmap , <Plug>Sneak_;
hi Sneak ctermbg=lightRed ctermfg=black


""""""""""""""""""""""""""""""
" => semantic-highlight
""""""""""""""""""""""""""""""
let g:semanticPersistCache = 1
let g:semanticEnableFileTypes = [
      \ 'javascript', 'python', 'c', 'cpp', 'typescript', 'rust'
      \ ]
let g:semanticTermColors = [2, 5, 18, 33, 58, 92, 137, 161, 240]


""""""""""""""""""""""""""""""
" => smartim
""""""""""""""""""""""""""""""
let g:smartim_default = 'com.apple.keylayout.ABC'
let g:smartim_disable = 1
function! SmartimToggle()
  if has('mac') && get(g:, 'smartim_disable') == 1
    let g:smartim_disable = 0
    echo 'Smartim enable'
  else
    let g:smartim_disable = 1
    echo 'Smartim disable'
  endif
endfunction
nnoremap <leader>sf :call SmartimToggle()<CR>


""""""""""""""""""""""""""""""
" => other
""""""""""""""""""""""""""""""
" disable netrw
let loaded_netrwPlugin = 1


" vim: et ts=2 sts=2 sw=2 tw=80
