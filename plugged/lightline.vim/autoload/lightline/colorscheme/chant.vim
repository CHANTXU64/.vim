" =============================================================================
" Filename: autoload/lightline/colorscheme/chant.vim
" Author: chant
" License: MIT License
" Last Change: 2020/11/21 00:00:00.
" =============================================================================

" Common colors
let s:blue = [ '#8ac6f2', 117 ]
let s:purple = [ '#c678dd', 176 ]
let s:red1   = [ '#e06c75', 168 ]
let s:red2   = [ '#be5046', 9 ]
let s:yellow = [ '#ff8700', 202 ]

let s:p = {'normal': {}, 'inactive': {}, 'insert': {}, 'replace': {}, 'visual': {}, 'tabline': {}}

let s:fg    = [ '#000000', 0 ]
let s:bg    = [ '#fafafa', 255 ]
let s:gray1 = [ '#494b53', 251 ]
let s:gray2 = [ '#f0f0f0', 255 ]
let s:gray3 = [ '#d0d0d0', 248 ]
let s:green = [ '#95e454', 40 ]
let s:orange = [ '#e5786d', 173 ]

let s:p.inactive.left   = [ [ s:bg,  s:gray3 ], [ s:bg, s:gray3 ] ]
let s:p.inactive.middle = [ [ s:gray3, s:gray2 ] ]
let s:p.inactive.right  = [ [ s:bg, s:gray3 ] ]

" Common
let s:p.normal.left    = [ [ s:fg, s:green, 'bold' ], [ s:fg, s:gray3 ], [ s:fg, s:gray1 ] ]
let s:p.normal.middle  = [ [ s:fg, s:gray2 ] ]
let s:p.normal.right   = [ [ s:bg, s:red2 ], [ s:bg, s:yellow ], [ s:fg, s:gray3, 'bold' ], [ s:fg, s:gray1 ] ]
let s:p.insert.right   = [ [ s:bg, s:red2 ], [ s:bg, s:yellow ], [ s:fg, s:gray3, 'bold' ], [ s:fg, s:gray1 ] ]
let s:p.insert.left    = [ [ s:fg, s:blue, 'bold' ], [ s:fg, s:gray3 ], [ s:fg, s:gray3 ] ]
let s:p.replace.right  = [ [ s:bg, s:red2 ], [ s:bg, s:yellow ], [ s:fg, s:gray3, 'bold' ], [ s:fg, s:gray1 ] ]
let s:p.replace.left   = [ [ s:bg, s:red1, 'bold' ], [ s:fg, s:gray3 ], [ s:fg, s:gray3 ] ]
let s:p.visual.right   = [ [ s:bg, s:red2 ], [ s:bg, s:yellow ], [ s:fg, s:gray3, 'bold' ], [ s:fg, s:gray1 ] ]
let s:p.visual.left    = [ [ s:fg, s:orange, 'bold' ], [ s:fg, s:gray3 ], [ s:fg, s:gray3 ] ]
let s:p.tabline.left   = [ [ s:fg, s:gray3 ] ]
let s:p.tabline.tabsel = [ [ s:fg, s:blue, 'bold' ] ]
let s:p.tabline.middle = [ [ s:gray3, s:gray2 ] ]
let s:p.tabline.right  = [ [ s:gray2, s:gray3 ] ]

let g:lightline#colorscheme#chant#palette = lightline#colorscheme#flatten(s:p)
