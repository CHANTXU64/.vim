let s:save_cpo = &cpo
set cpo&vim

" constants
let s:ON_NVIM = has('nvim')
let s:ESC_CODE = char2nr("\<Esc>")
let s:HAS_TIMER = has('timers')

" configurations
let g:clever_f_across_no_line          = get(g:, 'clever_f_across_no_line', 0)
let g:clever_f_ignore_case             = get(g:, 'clever_f_ignore_case', 0)
let g:clever_f_fix_key_direction       = get(g:, 'clever_f_fix_key_direction', 0)
let g:clever_f_smart_case              = get(g:, 'clever_f_smart_case', 0)
let g:clever_f_timeout_ms              = get(g:, 'clever_f_timeout_ms', 0)

augroup plugin-clever-f-finalizer
    autocmd!
augroup END

" initialize the internal state
let s:last_mode = ''
let s:previous_map = {}
let s:previous_pos = {}
let s:first_move = {}
let s:previous_char_num = {}
let s:timestamp = [0, 0]

" keys are mode string returned from mode()
function! clever_f#reset() abort
    let s:previous_map = {}
    let s:previous_pos = {}
    let s:first_move = {}

    " Note:
    " [0, 0] may be invalid because the representation of return value of reltime() depends on implementation.
    let s:timestamp = [0, 0]

    return ''
endfunction

" hidden API for debug
function! clever_f#_reset_all() abort
    call clever_f#reset()
    let s:last_mode = ''
    let s:previous_char_num = {}
    autocmd! plugin-clever-f-finalizer
    unlet! s:moved_forward
endfunction

function! s:is_timedout() abort
    let cur = reltime()
    let rel = reltimestr(reltime(s:timestamp, cur))
    let elapsed_ms = float2nr(str2float(rel) * 1000.0)
    let s:timestamp = cur
    return elapsed_ms > g:clever_f_timeout_ms
endfunction

" Note:
" \x80\xfd` seems to be sent by a terminal.
" Below is a workaround for the sequence.
function! s:getchar() abort
    while 1
        let cn = getchar()
        if type(cn) != type('') || cn !=# "\x80\xfd`"
            return cn
        endif
    endwhile
endfunction

function! clever_f#find_with(map) abort
    if a:map !~# '^[fFtT]$'
        throw "clever-f: Invalid mapping '" . a:map . "'"
    endif

    if &foldopen =~# '\<\%(all\|hor\)\>'
        while foldclosed(line('.')) >= 0
            foldopen
        endwhile
    endif

    let current_pos = getpos('.')[1 : 2]
    let mode = s:mode()

    " When 'f' is run while executing a macro, do not repeat previous
    " character. See #59 for more details
    if current_pos != get(s:previous_pos, mode, [0, 0])
        let back = 0
        let cursor_marker = matchadd('Cursor', '\%#', 999)
        redraw
        try
            let s:previous_map[mode] = a:map
            let s:first_move[mode] = 1
            let cn = s:getchar()
            if cn == s:ESC_CODE
                return "\<Esc>"
            endif
            let s:previous_char_num[mode] = cn
            let s:last_mode = mode

            if g:clever_f_timeout_ms > 0
                let s:timestamp = reltime()
            endif
        finally
            call matchdelete(cursor_marker)
        endtry
    else
        " When repeated

        let back = a:map =~# '\u'
        if g:clever_f_fix_key_direction && s:previous_map[mode] =~# '\u'
            let back = !back
        endif

        " reset and retry if timed out
        if a:map !~ s:previous_map[mode] || (g:clever_f_timeout_ms > 0 && s:is_timedout())
            call clever_f#reset()
            return clever_f#find_with(a:map)
        endif
    endif

    return clever_f#repeat(back)
endfunction

function! clever_f#repeat(back) abort
    let mode = s:mode()
    let pmap = get(s:previous_map, mode, '')
    let prev_char_num = get(s:previous_char_num, mode, 0)

    if pmap ==# ''
        return ''
    endif

    " ignore special characters like \<Left>
    if type(prev_char_num) == type('') && char2nr(prev_char_num) == 128
        return ''
    endif

    if a:back
        let pmap = s:swapcase(pmap)
    endif

    if mode[0] ==? 'v' || mode[0] ==# "\<C-v>"
        let cmd = s:move_cmd_for_visualmode(pmap, prev_char_num)
    else
        let inclusive = mode ==# 'no' && pmap =~# '\l'
        let cmd = printf("%s:\<C-u>call clever_f#find(%s, %s)\<CR>",
                    \    inclusive ? 'v' : '',
                    \    string(pmap), prev_char_num)
    endif

    return cmd
endfunction

" absolutely moved forward?
function! s:moves_forward(p, n) abort
    if a:p[0] != a:n[0]
        return a:p[0] < a:n[0]
    endif

    if a:p[1] != a:n[1]
        return a:p[1] < a:n[1]
    endif

    return 0
endfunction

function! clever_f#find(map, char_num) abort
    let before_pos = getpos('.')[1 : 2]
    let next_pos = s:next_pos(a:map, a:char_num, v:count1)
    if next_pos == [0, 0]
        return
    endif

    let moves_forward = s:moves_forward(before_pos, next_pos)

    " update highlight when cursor moves across lines
    let mode = s:mode()

    let s:moved_forward = moves_forward
    let s:previous_pos[mode] = next_pos
    let s:first_move[mode] = 0
endfunction

function! s:move_cmd_for_visualmode(map, char_num) abort
    let next_pos = s:next_pos(a:map, a:char_num, v:count1)
    if next_pos == [0, 0]
        return ''
    endif

    let m = s:mode()
    call setpos("''", [0] + next_pos + [0])
    let s:previous_pos[m] = next_pos
    let s:first_move[m] = 0

    return '``'
endfunction

function! s:search(pat, flag) abort
    if g:clever_f_across_no_line
        return search(a:pat, a:flag, line('.'))
    else
        return search(a:pat, a:flag)
    endif
endfunction

function! s:generate_pattern(map, char_num) abort
    let char = type(a:char_num) == type(0) ? nr2char(a:char_num) : a:char_num
    let regex = char

    let is_exclusive_visual = &selection ==# 'exclusive' && s:mode()[0] ==? 'v'
    if a:map ==# 't' && !is_exclusive_visual
        let regex = '\_.\ze\%(' . regex . '\)'
    elseif is_exclusive_visual && a:map ==# 'f'
        let regex = '\%(' . regex . '\)\zs\_.'
    elseif a:map ==# 'T'
        let regex = '\%(' . regex . '\)\@<=\_.'
    endif

    return ((g:clever_f_smart_case && char =~# '\l') || g:clever_f_ignore_case ? '\c' : '\C') . regex
endfunction

function! s:next_pos(map, char_num, count) abort
    let mode = s:mode()
    let search_flag = a:map =~# '\l' ? 'W' : 'bW'
    let cnt = a:count
    let pattern = s:generate_pattern(a:map, a:char_num)

    if a:map ==? 't' && get(s:first_move, mode, 1)
        if !s:search(pattern, search_flag . 'c')
            return [0, 0]
        endif
        let cnt -= 1
    endif

    while 0 < cnt
        if !s:search(pattern, search_flag)
            return [0, 0]
        endif
        let cnt -= 1
    endwhile

    return getpos('.')[1 : 2]
endfunction

function! s:swapcase(char) abort
    return a:char =~# '\u' ? tolower(a:char) : toupper(a:char)
endfunction

" Drop forced visual mode character ('nov' -> 'no')
function! s:mode() abort
    let mode = mode(1)
    if mode =~# '^no'
        let mode = mode[0 : 1]
    endif
    return mode
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
