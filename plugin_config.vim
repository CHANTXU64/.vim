"""""""""""""""""""""""""""""""
"" => coc
"""""""""""""""""""""""""""""""
let g:coc_global_extensions = ['coc-tsserver', 'coc-clangd',
      \'coc-markdownlint', 'coc-snippets', 'coc-css', 'coc-tabnine',
      \'coc-html', 'coc-cmake', 'coc-pyright', 'coc-jedi']
nnoremap <silent> <leader>h :call CocActionAsync('doHover')<cr>
nmap gd <Plug>(coc-definition)
nmap gD <Plug>(coc-implementation)
nmap gr <Plug>(coc-references)
vmap <leader>fs <Plug>(coc-format-selected)
nmap <leader>fs <Plug>(coc-format-selected)
nmap <leader>fae <Plug>(coc-format)
nmap <F2> <Plug>(coc-rename)
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
nmap -c <Plug>(coc-diagnostic-next)
nmap [c <Plug>(coc-diagnostic-prev)

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
      \ 'Rg': 1,
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
  \ '<C-K>': ['<C-P>']
  \}
let g:Lf_WindowHeight = 0.30
let g:Lf_FollowLinks = 1

" buffers
let g:Lf_ShortcutB = ']b'
" files
let g:Lf_ShortcutF = ']a'
" Mru
nmap <leader>m :<C-U>LeaderfMruCwd<CR>
nmap <leader>M :<C-U>LeaderfMru<CR>
" bufTag
nmap ]t :<C-U>LeaderfBufTagCword<CR>
xmap ]t :<C-U><C-R>=printf('Leaderf bufTag --input %s', <SID>get_visual_selection())<CR><CR>
map ]T :<C-U>LeaderfBufTag<CR>
nmap ]<C-T> :<C-U>LeaderfBufTagAllCword<CR>
xmap ]<C-T> :<C-U><C-R>=printf('Leaderf bufTag --all --input %s', <SID>get_visual_selection())<CR><CR>
map ]st :<C-U>LeaderfBufTagAll<CR>
" function
nmap ]f :<C-U>LeaderfFunctionCword<CR>
xmap ]f :<C-U><C-R>=printf('Leaderf function --input %s', <SID>get_visual_selection())<CR><CR>
map ]F :<C-U>LeaderfFunction<CR>
nmap ]<C-F> :<C-U>LeaderfFunctionAllCword<CR>
xmap ]<C-F> :<C-U><C-R>=printf('Leaderf function --all --input %s', <SID>get_visual_selection())<CR><CR>
map ]sf :<C-U>LeaderfFunctionAll<CR>
" command
map ]x :<C-U>LeaderfCommand<CR>
" history
nmap q_ :<C-U>LeaderfHistoryCmd<CR>
xmap q_ :<C-U>LeaderfHistoryCmd<CR>
nmap q/ :<C-U>LeaderfHistorySearch<CR>
xmap q/ :<C-U>LeaderfHistorySearch<CR>
" rg
map <silent> <Leader>/ :Leaderf rg<CR>
map <C-B> :<C-U><C-R>=printf('Leaderf! rg --current-buffer -e %s ', expand('<cword>'))<CR><CR>
map ]<C-B> :<C-U><C-R>=printf('Leaderf! rg --all-buffers -e %s ', expand('<cword>'))<CR><CR>
map <C-F> :<C-U><C-R>=printf('Leaderf! rg -e %s ', expand('<cword>'))<CR><CR>
xmap ]# :<C-U><C-R>=printf('Leaderf! rg -F -e %s ', leaderf#Rg#visual())<CR><CR>
" gtags
let g:Lf_GtagsAutoGenerate = 1
let g:Lf_Gtagslabel = 'native-pygments'
map <leader>gr :<C-U><C-R>=printf('Leaderf! gtags -r %s --auto-jump', expand('<cword>'))<CR><CR>
map <leader>gd :<C-U><C-R>=printf('Leaderf! gtags -d %s --auto-jump', expand('<cword>'))<CR><CR>
" recall
map ]rt :<C-U>Leaderf! bufTag --recall<CR>
map ]rf :<C-U>Leaderf! function --recall<CR>
map ]rr :<C-U>Leaderf! rg --recall<CR>
map ]rg :<C-U>Leaderf! gtags --recall<CR>

let g:Lf_WildIgnore = {
      \ 'dir': ['.svn','.git','.hg','plugged','vendor','node_modules'],
      \ 'file': ['*.sw?','~$*','*.bak','*.exe','*.o','*.so','*.py[co]','.DS_Store']
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
" => Signify
""""""""""""""""""""""""""""""
map <Leader>d :SignifyHunkDiff<CR>


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
" => fugitive
""""""""""""""""""""""""""""""
map <Leader>gw :Gwrite<CR>
map <Leader>gd :Git difftool<CR>
map <Leader>ggd :Git difftool -y<CR>


""""""""""""""""""""""""""""""
" => vim-polyglot
""""""""""""""""""""""""""""""
"javascript
let g:javascript_plugin_jsdoc = 1


""""""""""""""""""""""""""""""
" => indentLine
""""""""""""""""""""""""""""""
let g:indentLine_char = '▏'
let g:indentLine_concealcursor = 0


""""""""""""""""""""""""""""""
" => vim-matchup
""""""""""""""""""""""""""""""
" let g:loaded_matchit = 1


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
      \             [ 'gitbranch', 'readonly', 'filename' ] ],
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
      \   'gitbranch': 'FugitiveHead',
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
function! LightlineFilename()
  let filename = expand('%:t') !=# '' ? expand('%:t') : '[No Name]'
  let modified = &modified ? ' +' : ''
  return filename . modified
endfunction
call lightline#coc#register()


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


" vim: et ts=2 sts=2 sw=2 tw=80
