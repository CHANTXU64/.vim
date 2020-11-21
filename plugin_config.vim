"""""""""""""""""""""""""""""""
"" => coc
"""""""""""""""""""""""""""""""
let g:coc_global_extensions = ['coc-tsserver', 'coc-clangd',
      \'coc-markdownlint', 'coc-snippets', 'coc-css',
      \'coc-html', 'coc-python', 'coc-cmake']
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
nmap ]c <Plug>(coc-diagnostic-next)
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

let g:Lf_ShortcutB = '<Leader>bb'
let g:Lf_ShortcutF = '<Leader>ff'
nnoremap <silent> <Leader>rg :Leaderf rg<CR>
noremap <leader>fb :<C-U><C-R>=printf('Leaderf buffer %s', '')<CR><CR>
noremap <leader>fm :<C-U><C-R>=printf('Leaderf mru %s', '')<CR><CR>
noremap <leader>ft :<C-U><C-R>=printf('Leaderf bufTag %s', '')<CR><CR>
noremap <leader>fl :<C-U><C-R>=printf('Leaderf line %s', '')<CR><CR>

noremap <C-B> :<C-U><C-R>=printf('Leaderf! rg --current-buffer -e %s ', expand('<cword>'))<CR><CR>
noremap <C-F> :<C-U><C-R>=printf('Leaderf! rg -e %s ', expand('<cword>'))<CR><CR>
" search visually selected text literally
xnoremap gf :<C-U><C-R>=printf('Leaderf! rg -F -e %s ', leaderf#Rg#visual())<CR>
noremap go :<C-U>Leaderf! rg --recall<CR>

" gtags
let g:Lf_GtagsAutoGenerate = 1
let g:Lf_Gtagslabel = 'native-pygments'
noremap <leader>fr :<C-U><C-R>=printf('Leaderf! gtags -r %s --auto-jump', expand('<cword>'))<CR><CR>
noremap <leader>fd :<C-U><C-R>=printf('Leaderf! gtags -d %s --auto-jump', expand('<cword>'))<CR><CR>
noremap <leader>fo :<C-U><C-R>=printf('Leaderf! gtags --recall %s', '')<CR><CR>
noremap <leader>fn :<C-U><C-R>=printf('Leaderf gtags --next %s', '')<CR><CR>
noremap <leader>fp :<C-U><C-R>=printf('Leaderf gtags --previous %s', '')<CR><CR>

let g:Lf_WildIgnore = {
      \ 'dir': ['.svn','.git','.hg','plugged','vendor','node_modules'],
      \ 'file': ['*.sw?','~$*','*.bak','*.exe','*.o','*.so','*.py[co]']
      \}


""""""""""""""""""""""""""""""
" => Neomake
""""""""""""""""""""""""""""""
function! MyOnBattery()
  if has('macunix')
    return match(system('pmset -g batt'), 'Now drawing from 'Battery Power'') != -1
  elseif has('unix')
    return readfile('/sys/class/power_supply/ADP1/online') == ['0']
  endif
  return 0
endfunction
if MyOnBattery()
  call neomake#configure#automake({
        \ 'TextChanged': {},
        \ 'InsertLeave': {},
        \ 'BufWritePost': {'delay': 0},
        \ 'BufWinEnter': {},
        \ }, 5000)
else
  call neomake#configure#automake({
        \ 'TextChanged': {},
        \ 'InsertLeave': {},
        \ 'BufWritePost': {'delay': 0},
        \ 'BufWinEnter': {},
        \ }, 2000)
endif
let g:neomake_javascript_enabled_makers=['semistandard']
let g:neamake_typescript_enabled_makers=['semistandard']
let g:neomake_cpp_enabled_makers=['cpplint']
let g:neomake_error_sign = {
      \ 'text': '✖',
      \ 'texthl': 'NeomakeErrorSign',
      \ }
let g:neomake_warning_sign = {
      \   'text': '‼',
      \   'texthl': 'NeomakeWarningSign',
      \ }
let g:neomake_message_sign = {
      \   'text': '>>',
      \   'texthl': 'NeomakeMessageSign',
      \ }
let g:neomake_info_sign = {
      \ 'text': '>>',
      \ 'texthl': 'NeomakeInfoSign'
      \ }


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
autocmd bufenter * if (winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree()) | q | endif


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
" => easymotion
""""""""""""""""""""""""""""""
nmap s <Plug>(easymotion-bd-jk)
xmap s <Plug>(easymotion-bd-jk)
omap u <Plug>(easymotion-bd-jk)


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
nmap <Leader>v :Vista!!<CR>


""""""""""""""""""""""""""""""
" => airline theme
""""""""""""""""""""""""""""""
let g:airline_theme='sol'


""""""""""""""""""""""""""""""
" => LargeFile
""""""""""""""""""""""""""""""
let g:LargeFile = 100


""""""""""""""""""""""""""""""
" => Lightline
""""""""""""""""""""""""""""""
set laststatus=2
let g:lightline = {
      \ 'colorscheme': 'chant',
      \ 'active': {
      \   'left': [ [ 'mode' ],
      \             [ 'paste', 'spell' ],
      \             [ 'gitbranch', 'readonly', 'filename' ] ],
      \   'right': [ [ 'error' ],
      \              [ 'warning' ],
      \              [ 'lineinfo' ],
      \              [ 'fileformat', 'fileencoding', 'filetype' ] ],
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
      \   'filename': 'LightlineFilename',
      \   'warning': 'GetWarning',
      \   'error': 'GetError',
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
function! GetWarning()
  return GetTotalWarningAndErrorInfo().W
endfunction
function! GetError()
  return GetTotalWarningAndErrorInfo().E
endfunction
function! GetNeomakeWarningAndErrorInfo()
  try
    let neomake_warning_and_error_info = neomake#statusline#LoclistCounts()
  catch
    let neomake_warning_and_error_info = {}
  endtry
  if (IsEmptyKeys(neomake_warning_and_error_info))
    return {'W': 0, 'E': 0}
  else
    try
      let l:a = neomake_warning_and_error_info.W
    catch
      return {'W': 0, 'E': neomake_warning_and_error_info.E}
    endtry
    try
      let l:a = neomake_warning_and_error_info.E
    catch
      return {'W': neomake_warning_and_error_info.W, 'E': 0}
    endtry
    return neomake_warning_and_error_info
  endif
endfunction
function! IsEmptyKeys(Keys)
  for key in keys(a:Keys)
    return 0
  endfor
  return 1
endfunction
function! GetCocWarningAndErrorInfo()
  try
    let coc_warning_and_error_info = b:coc_diagnostic_info
  catch
    return {'W': 0, 'E': 0}
  endtry
  return {'W': b:coc_diagnostic_info.warning, 'E': b:coc_diagnostic_info.error}
endfunction
function! GetTotalWarningAndErrorInfo()
  let neomake_info = GetNeomakeWarningAndErrorInfo()
  let coc_info = GetCocWarningAndErrorInfo()
  let W_count = neomake_info.W + coc_info.W
  if W_count
    let W = 'W:' . W_count
  else
    let W = ''
  endif
  let E_count = neomake_info.E + coc_info.E
  if E_count
    let E = 'E:' . E_count
  else
    let E = ''
  endif
  " return 'W: '.W_count.' E: '.E_count
  return {'W': W, 'E': E}
endfunction


" vim: et ts=2 sts=2 sw=2 tw=80
