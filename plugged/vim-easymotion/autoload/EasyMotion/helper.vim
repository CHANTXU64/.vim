"=============================================================================
" FILE: autoload/EasyMotion/helper.vim
" AUTHOR: haya14busa
" License: MIT license
"=============================================================================
scriptencoding utf-8
" Saving 'cpoptions' {{{
let s:save_cpo = &cpo
set cpo&vim
" }}}

function! EasyMotion#helper#is_greater_coords(coords1, coords2) "{{{
    " [line_num, col_num] < [line_num, col_num]
    "
    " coords1 < coords2  : return 1
    " coords1 > coords2  : return -1
    " coords1 == coords2 : return 0
    if a:coords1 == a:coords2 | return 0 | endif

    if a:coords1[0] < a:coords2[0]
        return 1
    elseif a:coords1[0] > a:coords2[0]
        return -1
    endif

    " Same line
    if a:coords1[1] < a:coords2[1]
        return 1
    elseif a:coords1[1] > a:coords2[1]
        return -1
    endif
endfunction "}}}

function! EasyMotion#helper#is_folded(line) "{{{
    " Return false if g:EasyMotion_skipfoldedline == 1
    " and line is start of folded lines
    let _foldclosed = foldclosed(a:line)
    return _foldclosed != -1 &&
        \ (g:EasyMotion_skipfoldedline == 1 || a:line != _foldclosed)
endfunction "}}}
function! EasyMotion#helper#VarReset(var, ...) "{{{
    if ! exists('s:var_reset')
        let s:var_reset = {}
    endif

    if a:0 == 0 && has_key(s:var_reset, a:var)
        " Reset var to original value
        " setbufvar( or bufname): '' or '%' can be used for the current buffer
        call setbufvar('%', a:var, s:var_reset[a:var])
    elseif a:0 == 1
        " Save original value and set new var value

        let new_value = a:0 == 1 ? a:1 : ''

        " Store original value
        let s:var_reset[a:var] = getbufvar("", a:var)

        " Set new var value
        call setbufvar('%', a:var, new_value)
    endif
endfunction "}}}

" EasyMotion#helper#strchars() {{{
if exists('*strchars')
    function! EasyMotion#helper#strchars(str)
        return strchars(a:str)
    endfunction
else
    function! EasyMotion#helper#strchars(str)
        return strlen(substitute(a:str, ".", "x", "g"))
    endfunction
endif "}}}

function! EasyMotion#helper#vcol(expr) abort
    let col_num = col(a:expr)
    let line = getline(a:expr)
    let before_line = col_num > 2 ? line[: col_num - 2]
    \   : col_num is# 2 ? line[0]
    \   : ''
    let vcol_num = 1
    for c in split(before_line, '\zs')
        let vcol_num += c is# "\t" ? s:_virtual_tab2spacelen(vcol_num) : len(c)
    endfor
    return vcol_num
endfunction

function! s:_virtual_tab2spacelen(col_num) abort
    return &tabstop - ((a:col_num - 1) % &tabstop)
endfunction

" Restore 'cpoptions' {{{
let &cpo = s:save_cpo
unlet s:save_cpo
" }}}
" vim: fdm=marker:et:ts=4:sw=4:sts=4
