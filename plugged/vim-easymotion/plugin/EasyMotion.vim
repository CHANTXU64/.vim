scriptencoding utf-8
" EasyMotion - Vim motions on speed!
"
" Author: Kim Silkebækken <kim.silkebaekken+vim@gmail.com>
"         haya14busa <hayabusa1419@gmail.com>
" Source: https://github.com/easymotion/vim-easymotion
" == Script initialization {{{
if expand("%:p") ==# expand("<sfile>:p")
  unlet! g:EasyMotion_loaded
endif
if exists('g:EasyMotion_loaded') || &compatible || version < 703
    finish
endif

let g:EasyMotion_loaded = 1
" }}}

" == Saving 'cpoptions' {{{
let s:save_cpo = &cpo
set cpo&vim
" }}}

" == Default configuration {{{
" -- Option ------------------------------ {{{
let g:EasyMotion_keys               = get(g: , 'EasyMotion_keys', 'aoeuhtns')
let g:EasyMotion_do_shade           = get(g: , 'EasyMotion_do_shade'           , 1)
let g:EasyMotion_grouping           = get(g: , 'EasyMotion_grouping'           , 1)
let g:EasyMotion_startofline        = get(g: , 'EasyMotion_startofline'        , 1)
let g:EasyMotion_skipfoldedline     = get(g: , 'EasyMotion_skipfoldedline'     , 1)
let g:EasyMotion_use_upper          = get(g: , 'EasyMotion_use_upper'          , 0)
let g:EasyMotion_enter_jump_first   = get(g: , 'EasyMotion_enter_jump_first'   , 0)
let g:EasyMotion_space_jump_first   = get(g: , 'EasyMotion_space_jump_first'   , 0)
let g:EasyMotion_landing_highlight  = get(g: , 'EasyMotion_landing_highlight'  , 0)
let g:EasyMotion_cursor_highlight   = get(g: , 'EasyMotion_cursor_highlight'   , 1)
let g:EasyMotion_add_search_history = get(g: , 'EasyMotion_add_search_history' , 1)
let g:EasyMotion_force_csapprox     = get(g: , 'EasyMotion_force_csapprox'     , 0)
let g:EasyMotion_verbose            = get(g: , 'EasyMotion_verbose'            , 1)
let g:EasyMotion_disable_two_key_combo     =
    \ get(g: , 'EasyMotion_disable_two_key_combo' , 0)

"}}}

" }}}

" -- JK Motion {{{
noremap <silent><Plug>(easymotion-bd-jk) :<C-u>call EasyMotion#JK(0,2)<CR>
xnoremap <silent><Plug>(easymotion-bd-jk) <Esc>:<C-u>call EasyMotion#JK(1,2)<CR>
"}}}

" == Restore 'cpoptions' {{{
let &cpo = s:save_cpo
unlet s:save_cpo
" }}}
" vim: fdm=marker:et:ts=4:sw=4:sts=4
