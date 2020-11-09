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
let g:EasyMotion_keys               = get(g: , 'EasyMotion_keys', 'AOEUHTNS')
let g:EasyMotion_startofline        = get(g: , 'EasyMotion_startofline'        , 1)
let g:EasyMotion_skipfoldedline     = get(g: , 'EasyMotion_skipfoldedline'     , 1)
let g:EasyMotion_use_upper          = get(g: , 'EasyMotion_use_upper'          , 1)
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
