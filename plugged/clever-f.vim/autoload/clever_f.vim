let s:save_cpo = &cpo
set cpo&vim

" constants
let s:ON_NVIM = has('nvim')
let s:ESC_CODE = char2nr("\<Esc>")
let s:HAS_TIMER = has('timers')

" configurations
let g:clever_f_across_no_line          = get(g:, 'clever_f_across_no_line', 0)
let g:clever_f_ignore_case             = get(g:, 'clever_f_ignore_case', 0)
let g:clever_f_use_migemo              = get(g:, 'clever_f_use_migemo', 0)
let g:clever_f_fix_key_direction       = get(g:, 'clever_f_fix_key_direction', 0)
let g:clever_f_show_prompt             = get(g:, 'clever_f_show_prompt', 0)
let g:clever_f_smart_case              = get(g:, 'clever_f_smart_case', 0)
let g:clever_f_chars_match_any_signs   = get(g:, 'clever_f_chars_match_any_signs', '')
let g:clever_f_timeout_ms              = get(g:, 'clever_f_timeout_ms', 0)
let g:clever_f_repeat_last_char_inputs = get(g:, 'clever_f_repeat_last_char_inputs', ["\<CR>"])
let g:clever_f_highlight_timeout_ms    = get(g:, 'clever_f_highlight_timeout_ms', 0)

" below variable must be set before loading this script
let g:clever_f_clean_labels_eagerly    = get(g:, 'clever_f_clean_labels_eagerly', 1)

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

" highlight characters to which the cursor can be moved directly
" Note: public function for test
function! clever_f#_mark_direct(forward, count) abort
    let line = getline('.')
    let [_, l, c, _] = getpos('.')

    if (a:forward && c >= len(line)) || (!a:forward && c == 1)
        " there is no matching characters
        return []
    endif

    if g:clever_f_ignore_case
        let line = tolower(line)
    endif

    let char_count = {}
    let matches = []
    let indices = a:forward ? range(c, len(line) - 1, 1) : range(c - 2, 0, -1)
    for i in indices
        let ch = line[i]
        " only matches to ASCII
        if ch !~# '^[\x00-\x7F]$' | continue | endif
        let ch_lower = tolower(ch)

        let char_count[ch] = get(char_count, ch, 0) + 1
        if g:clever_f_smart_case && ch =~# '\u'
            " uppercase characters are doubly counted
            let char_count[ch_lower] = get(char_count, ch_lower, 0) + 1
        endif

        if char_count[ch] == a:count ||
            \ (g:clever_f_smart_case && char_count[ch_lower] == a:count)
            " NOTE: should not use `matchaddpos(group, [...position])`,
            " because the maximum number of position is 8
            let m = matchaddpos('CleverFDirect', [[l, i + 1]])
            call add(matches, m)
        endif
    endfor
    return matches
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
    let in_macro = clever_f#reg_executing() !=# ''

    " When 'f' is run while executing a macro, do not repeat previous
    " character. See #59 for more details
    if current_pos != get(s:previous_pos, mode, [0, 0]) || in_macro
        let should_redraw = !in_macro
        let back = 0
        " block-NONE does not work on Neovim
        try
            if g:clever_f_mark_direct && should_redraw
                let direct_markers = clever_f#_mark_direct(a:map =~# '\l', v:count1)
                redraw
            endif
            if g:clever_f_show_prompt
                echon 'clever-f: '
            endif
            let s:previous_map[mode] = a:map
            let s:first_move[mode] = 1
            let cn = s:getchar()
            if cn == s:ESC_CODE
                return "\<Esc>"
            endif
            if index(map(deepcopy(g:clever_f_repeat_last_char_inputs), 'char2nr(v:val)'), cn) == -1
                let s:previous_char_num[mode] = cn
            else
                if has_key(s:previous_char_num, s:last_mode)
                    let s:previous_char_num[mode] = s:previous_char_num[s:last_mode]
                else
                    echohl ErrorMsg | echo 'Previous input not found.' | echohl None
                    return ''
                endif
            endif
            let s:last_mode = mode

            if g:clever_f_timeout_ms > 0
                let s:timestamp = reltime()
            endif

            if g:clever_f_show_prompt && should_redraw
                redraw!
            endif
        endtry
    else
        " When repeated

        let back = a:map =~# '\u'
        if g:clever_f_fix_key_direction && s:previous_map[mode] =~# '\u'
            let back = !back
        endif

        " reset and retry if timed out
        if g:clever_f_timeout_ms > 0 && s:is_timedout()
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

if exists('*xor')
    function! clever_f#xor(a, b) abort
        return xor(a:a, a:b)
    endfunction
else
    function! clever_f#xor(a, b) abort
        return a:a && !a:b || !a:a && a:b
    endfunction
endif

if exists('*reg_executing')
    function! clever_f#reg_executing() abort
        return reg_executing()
    endfunction
else
    " reg_executing() was introduced at Vim 8.2.0020 and Neovim 0.4.0
    function! clever_f#reg_executing() abort
        return ''
    endfunction
endif

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
