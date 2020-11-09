scriptencoding utf-8
" EasyMotion - Vim motions on speed!
"
" Author: Kim Silkebækken <kim.silkebaekken+vim@gmail.com>
"         haya14busa <hayabusa1419@gmail.com>
" Source: https://github.com/easymotion/vim-easymotion
"=============================================================================
" Saving 'cpoptions' {{{
let s:save_cpo = &cpo
set cpo&vim
" }}}

let s:TRUE = !0
let s:FALSE = 0
let s:DIRECTION = { 'forward': 0, 'backward': 1, 'bidirection': 2}


" Init: {{{
let s:loaded = s:FALSE
function! EasyMotion#init()
    if s:loaded
        return
    endif
    let s:loaded = s:TRUE
    call EasyMotion#highlight#load()
    " Store previous motion info
    let s:previous = {}
    " Store previous operator-pending motion info for '.' repeat
    let s:dot_repeat = {}
    " Prepare 1-key Migemo Dictionary
    let s:migemo_dicts = {}
    let s:EasyMotion_is_active = 0
    call EasyMotion#reset()
    " Anywhere regular expression: {{{
    let re = '\v' .
        \    '(<.|^$)' . '|' .
        \    '(.>|^$)' . '|' .
        \    '(\l)\zs(\u)' . '|' .
        \    '(_\zs.)' . '|' .
        \    '(#\zs.)'
    " 1. word
    " 2. end of word
    " 3. CamelCase
    " 4. after '_' hoge_foo
    " 5. after '#' hoge#foo
    let g:EasyMotion_re_anywhere = get(g:, 'EasyMotion_re_anywhere', re)

    " Anywhere regular expression within line:
    let re = '\v' .
        \    '(<.|^$)' . '|' .
        \    '(.>|^$)' . '|' .
        \    '(\l)\zs(\u)' . '|' .
        \    '(_\zs.)' . '|' .
        \    '(#\zs.)'
    let g:EasyMotion_re_line_anywhere = get(g:, 'EasyMotion_re_line_anywhere', re)
    "}}}
    " For other plugin
    let s:EasyMotion_is_cancelled = 0
    " 0 -> Success
    " 1 -> Cancel
    let g:EasyMotion_ignore_exception = 0
    return ""
endfunction
"}}}
" Reset: {{{
function! EasyMotion#reset()
    let s:flag = {
        \ 'within_line' : 0,
        \ 'dot_repeat' : 0,
        \ 'regexp' : 0,
        \ 'bd_t' : 0,
        \ 'find_bd' : 0,
        \ 'linewise' : 0,
        \ 'count_dot_repeat' : 0,
        \ }
        " regexp: -> regular expression
        "   This value is used when multi input find motion. If this values is
        "   1, input text is treated as regexp.(Default: escaped)
        " bd_t: -> bi-directional 't' motion
        "   This value is used to re-define regexp only for bi-directional 't'
        "   motion
        " find_bd: -> bi-directional find motion
        "   This value is used to recheck the motion is inclusive or exclusive
        "   because 'f' & 't' forward find motion is inclusive, but 'F' & 'T'
        "   backward find motion is exclusive
        " count_dot_repeat: -> dot repeat with count
        "   https://github.com/easymotion/vim-easymotion/issues/164
    let s:current = {
        \ 'is_operator' : 0,
        \ 'is_search' : 0,
        \ 'dot_repeat_target_cnt' : 0,
        \ 'dot_prompt_user_cnt' : 0,
        \ 'changedtick' : 0,
        \ }
        " \ 'start_position' : [],
        " \ 'cursor_position' : [],

        " is_operator:
        "   Store is_operator value first because mode(1) value will be
        "   changed by some operation.
        " dot_* :
        "   These values are used when '.' repeat for automatically
        "   select marker/label characters.(Using count avoid recursive
        "   prompt)
        " changedtick:
        "   :h b:changedtick
        "   This value is used to avoid side effect of overwriting buffer text
        "   which will change b:changedtick value. To overwrite g:repeat_tick
        "   value(defined tpope/vim-repeat), I can avoid this side effect of
        "   conflicting with tpope/vim-repeat
        " start_position:
        "   Original, start cursor position.
        " cursor_position:
        "   Usually, this values is same with start_position, but in
        "   visualmode and 'n' key motion, this value could be different.
    return ""
endfunction "}}}

" -- JK Motion ---------------------------
function! EasyMotion#JK(visualmode, direction) " {{{
    let s:current.is_operator = mode(1) ==# 'no' ? 1: 0
    let s:flag.linewise = 1

    if g:EasyMotion_startofline
        call s:EasyMotion('^\(\w\|\s*\zs\|$\)', a:direction, a:visualmode ? visualmode() : '', 0)
    else
        let vcol  = EasyMotion#helper#vcol('.')
        let pattern = printf('^.\{-}\zs\(\%%<%dv.\%%>%dv\|$\)', vcol + 1, vcol)
        call s:EasyMotion(pattern, a:direction, a:visualmode ? visualmode() : '', 0)
    endif
    return s:EasyMotion_is_cancelled
endfunction " }}}
" -- User Motion -------------------------
let s:config = {
\   'pattern': '',
\   'visualmode': s:FALSE,
\   'direction': s:DIRECTION.forward,
\   'inclusive': s:FALSE,
\   'accept_cursor_pos': s:FALSE,
\   'overwin': s:FALSE
\ }

function! s:default_config() abort
    let c = copy(s:config)
    let m = mode(1)
    let c.inclusive = m ==# 'no' ? s:TRUE : s:FALSE
    return c
endfunction

" Helper Functions: {{{
" -- Message -----------------------------
function! s:Message(message) " {{{
    if g:EasyMotion_verbose
        echo 'EasyMotion: ' . a:message
    else
        " Make the current message disappear
        echo ''
        " redraw
    endif
endfunction " }}}
function! s:Prompt(message) " {{{
    echohl Question
    echo a:message . ': '
    echohl None
endfunction " }}}
function! s:Throw(message) "{{{
    throw 'EasyMotion: ' . a:message
endfunction "}}}

" -- Save & Restore values ---------------
function! s:SaveValue() "{{{
    if ! s:current.is_search
        call EasyMotion#helper#VarReset('&scrolloff', 0)
    endif
    call EasyMotion#helper#VarReset('&modified', 0)
    call EasyMotion#helper#VarReset('&modifiable', 1)
    call EasyMotion#helper#VarReset('&readonly', 0)
    call EasyMotion#helper#VarReset('&spell', 0)
    call EasyMotion#helper#VarReset('&virtualedit', '')
    " if &foldmethod !=# 'expr'
        call EasyMotion#helper#VarReset('&foldmethod', 'manual')
    " endif
endfunction "}}}
function! s:RestoreValue() "{{{
    call EasyMotion#helper#VarReset('&scrolloff')
    call EasyMotion#helper#VarReset('&modified')
    call EasyMotion#helper#VarReset('&modifiable')
    call EasyMotion#helper#VarReset('&readonly')
    call EasyMotion#helper#VarReset('&spell')
    call EasyMotion#helper#VarReset('&virtualedit')
    " if &foldmethod !=# 'expr'
        call EasyMotion#helper#VarReset('&foldmethod')
    " endif
endfunction "}}}

" -- Draw --------------------------------
function! s:SetLines(lines, key) " {{{
    for [line_num, line] in a:lines
        keepjumps call setline(line_num, line[a:key])
    endfor
endfunction " }}}

" -- Get characters from user input ------
function! s:GetChar(...) abort "{{{
    let mode = get(a:, 1, 0)
    while 1
        " Workaround for https://github.com/osyo-manga/vital-over/issues/53
        try
            let char = call('getchar', a:000)
        catch /^Vim:Interrupt$/
            let char = 3 " <C-c>
        endtry
        if char == 27 || char == 3
            " Escape or <C-c> key pressed
            redraw
            call s:Message('Cancelled')
            return ''
        endif
        " Workaround for the <expr> mappings
        if string(char) !=# "\x80\xfd`"
            return mode == 1 ? !!char
            \    : type(char) == type(0) ? nr2char(char) : char
        endif
    endwhile
endfunction "}}}

" -- Handle Visual Mode ------------------
function! s:GetVisualStartPosition(c_pos, v_start, v_end, search_direction) "{{{
    let vmode = mode(1)
    if vmode !~# "^[Vv\<C-v>]"
        call s:Throw('Unkown visual mode:'.vmode)
    endif

    if vmode ==# 'V' "line-wise Visual
        " Line-wise Visual {{{
        if a:v_start[0] == a:v_end[0]
            if a:search_direction == ''
                return a:v_start
            elseif a:search_direction == 'b'
                return a:v_end
            else
                call s:throw('Unkown search_direction')
            endif
        else
            if a:c_pos[0] == a:v_start[0]
                return a:v_end
            elseif a:c_pos[0] == a:v_end[0]
                return a:v_start
            endif
        endif
        "}}}
    else
        " Character-wise or Block-wise Visual"{{{
        if a:c_pos == a:v_start
            return a:v_end
        elseif a:c_pos == a:v_end
            return a:v_start
        endif

        " virtualedit
        if a:c_pos[0] == a:v_start[0]
            return a:v_end
        elseif a:c_pos[0] == a:v_end[0]
            return a:v_start
        elseif EasyMotion#helper#is_greater_coords(a:c_pos, a:v_start) == 1
            return a:v_end
        else
            return a:v_start
        endif
        "}}}
    endif
endfunction "}}}

" -- Others ------------------------------
function! EasyMotion#attach_active_autocmd() "{{{
    " Reference: https://github.com/justinmk/vim-sneak
    augroup plugin-easymotion-active
        autocmd!
        autocmd InsertEnter,WinLeave,BufLeave <buffer>
            \ let s:EasyMotion_is_active = 0
            \  | autocmd! plugin-easymotion-active * <buffer>
        autocmd CursorMoved <buffer>
            \ autocmd plugin-easymotion-active CursorMoved <buffer>
            \ let s:EasyMotion_is_active = 0
            \  | autocmd! plugin-easymotion-active * <buffer>
    augroup END
endfunction "}}}
function! s:restore_cursor_state(visualmode) "{{{
    " -- Restore original cursor position/selection
    if ! empty(a:visualmode)
        silent exec 'normal! gv'
        keepjumps call cursor(s:current.cursor_position)
    else
        keepjumps call cursor(s:current.original_position)
    endif
endfunction " }}}
" Grouping Algorithms: {{{
let s:grouping_algorithms = {
\   1: 'SCTree'
\ }
" -- Single-key/closest target priority tree {{{
" This algorithm tries to assign one-key jumps to all the targets closest to the cursor.
" It works recursively and will work correctly with as few keys as two.
function! s:GroupingAlgorithmSCTree(targets, keys) "{{{
    " Prepare variables for working
    let targets_len = len(a:targets)
    let keys_len = len(a:keys)

    let groups = {}

    let keys = reverse(copy(a:keys))

    " Semi-recursively count targets {{{
        " We need to know exactly how many child nodes (targets) this branch will have
        " in order to pass the correct amount of targets to the recursive function.

        " Prepare sorted target count list {{{
            " This is horrible, I know. But dicts aren't sorted in vim, so we need to
            " work around that. That is done by having one sorted list with key counts,
            " and a dict which connects the key with the keys_count list.

            let keys_count = []
            let keys_count_keys = {}

            let i = 0
            for key in keys
                call add(keys_count, 0)

                let keys_count_keys[key] = i

                let i += 1
            endfor
        " }}}

        let targets_left = targets_len
        let level = 0
        let i = 0

        while targets_left > 0
            " Calculate the amount of child nodes based on the current level
            let childs_len = (level == 0 ? 1 : (keys_len - 1) )

            for key in keys
                " Add child node count to the keys_count array
                let keys_count[keys_count_keys[key]] += childs_len

                " Subtract the child node count
                let targets_left -= childs_len

                if targets_left <= 0
                    " Subtract the targets left if we added too many too
                    " many child nodes to the key count
                    let keys_count[keys_count_keys[key]] += targets_left

                    break
                endif

                let i += 1
            endfor

            let level += 1
        endwhile
    " }}}
    " Create group tree {{{
        let i = 0
        let key = 0

        call reverse(keys_count)

        for key_count in keys_count
            if key_count > 1
                " We need to create a subgroup
                " Recurse one level deeper
                let groups[a:keys[key]] = s:GroupingAlgorithmSCTree(a:targets[i : i + key_count - 1], a:keys)
            elseif key_count == 1
                " Assign single target key
                let groups[a:keys[key]] = a:targets[i]
            else
                " No target
                continue
            endif

            let key += 1
            let i += key_count
        endfor
    " }}}

    " Finally!
    return groups
endfunction "}}}
" }}}

" -- Coord/key dictionary creation ------- {{{
function! s:CreateCoordKeyDict(groups, ...)
    " Dict structure:
    " 1,2 : a
    " 2,3 : b
    let sort_list = []
    let coord_keys = {}
    let group_key = a:0 == 1 ? a:1 : ''

    for [key, item] in items(a:groups)
        let key = group_key . key
        "let key = ( ! empty(group_key) ? group_key : key)

        if type(item) == type([]) " List
            " Destination coords

            " The key needs to be zero-padded in order to
            " sort correctly
            let dict_key = printf('%05d,%05d', item[0], item[1])
            let coord_keys[dict_key] = key

            " We need a sorting list to loop correctly in
            " PromptUser, dicts are unsorted
            call add(sort_list, dict_key)
        else
            " Item is a dict (has children)
            let coord_key_dict = s:CreateCoordKeyDict(item, key)

            " Make sure to extend both the sort list and the
            " coord key dict
            call extend(sort_list, coord_key_dict[0])
            call extend(coord_keys, coord_key_dict[1])
        endif

        unlet item
    endfor

    return [sort_list, coord_keys]
endfunction
" }}}
" }}}
"}}}
" Core Functions: {{{
function! s:PromptUser(groups) "{{{
    " Recursive
    let group_values = values(a:groups)

    " -- If only one possible match, jump directly to it {{{
    if len(group_values) == 1
        if mode(1) ==# 'no'
            " Consider jump to first match
            " NOTE: matchstr() handles multibyte characters.
            let s:dot_repeat['target'] = matchstr(g:EasyMotion_keys, '^.')
        endif
        redraw
        return group_values[0]
    endif
    " }}}

    " -- Prepare marker lines ---------------- {{{
    let lines = {}

    let coord_key_dict = s:CreateCoordKeyDict(a:groups)

    let prev_col_num = 0
    for dict_key in sort(coord_key_dict[0])

        " Prepare original line and marker line {{{
        let [line_num, col_num] = split(dict_key, ',')

        let line_num = str2nr(line_num)
        let col_num = str2nr(col_num)
        if ! has_key(lines, line_num)
            let current_line = getline(line_num)
            let lines[line_num] = {
                \ 'orig': current_line,
                \ 'marker': current_line,
                \ 'mb_compensation': 0,
                \ }
            " mb_compensation -> multibyte compensation
            let prev_col_num = 0
        endif "}}}

        let col_num = max([prev_col_num + 1,
                        \  col_num - lines[line_num]['mb_compensation']])
        let prev_col_num = col_num
        "}}}

        " Prepare marker characters {{{
        let marker_chars = coord_key_dict[1][dict_key]
        let marker_chars_len = EasyMotion#helper#strchars(marker_chars)
        "}}}

        " Replace {target} with {marker} & Highlight {{{
        let col_add = 0 " Column add byte length
        " Disable two-key-combo feature?
        let marker_max_length = g:EasyMotion_disable_two_key_combo == 1
                                \ ? 1 : 2
        for i in range(min([marker_chars_len, marker_max_length]))
            let marker_char = split(marker_chars, '\zs')[i]
            " EOL {{{
            if strlen(lines[line_num]['marker']) < col_num + col_add
                " Append marker chars if target is EOL
                let lines[line_num]['marker'] .= ' '
            endif "}}}

            let target_col_regexp = '\%' . (col_num + col_add) . 'c.'
            let target_char = matchstr(lines[line_num]['marker'],
                                      \ target_col_regexp)
            let space_len = strdisplaywidth(target_char)
                        \ - strdisplaywidth(marker_char)
            " Substitute marker character
            let substitute_expr = marker_char . repeat(' ', space_len)

            let lines[line_num]['marker'] = substitute(
                \ lines[line_num]['marker'],
                \ target_col_regexp,
                \ escape(substitute_expr,'&'),
                \ '')

            " Highlight targets {{{
            let _hl_group =
            \   (marker_chars_len == 1) ? g:EasyMotion_hl_group_target
            \   : (i == 0) ? g:EasyMotion_hl2_first_group_target
            \   : g:EasyMotion_hl2_second_group_target

            if exists('*matchaddpos')
                call EasyMotion#highlight#add_pos_highlight(
                            \ line_num, col_num + col_add, _hl_group)
            else
                call EasyMotion#highlight#add_highlight(
                    \ '\%' . line_num . 'l' . target_col_regexp,
                    \ _hl_group)
            endif
            "}}}

            " Add marker/target length difference for multibyte compensation
            let lines[line_num]['mb_compensation'] +=
                \ strlen(target_char) - strlen(substitute_expr)
            " Shift column
            let col_add += strlen(marker_char)
        endfor
        "}}}
    endfor

    let lines_items = items(lines)
    " }}}

    " -- Put labels on targets & Get User Input & Restore all {{{
    " Save undo tree
    let undo_lock = EasyMotion#undo#save()
    try
        " Set lines with markers {{{
        call s:SetLines(lines_items, 'marker')
        redraw "}}}

        " Get target character {{{
        call s:Prompt('Target key')
        let char = s:GetChar()
        "}}}

        " Convert uppercase {{{
        if g:EasyMotion_use_upper == 1 && match(g:EasyMotion_keys, '\l') == -1
            let char = toupper(char)
        endif "}}}

        " Jump first target when Enter or Space key is pressed "{{{
        if (char ==# "\<CR>" && g:EasyMotion_enter_jump_first == 1) ||
        \  (char ==# "\<Space>" && g:EasyMotion_space_jump_first == 1)
            " NOTE: matchstr() is multibyte aware.
            let char = matchstr(g:EasyMotion_keys, '^.')
        endif "}}}

        " For dot repeat {{{
        if mode(1) ==# 'no'
            let s:dot_repeat['target'] = char
        endif "}}}

    finally
        " Restore original lines
        call s:SetLines(lines_items, 'orig')

        " Un-highlight targets {{{
        call EasyMotion#highlight#delete_highlight(
            \ g:EasyMotion_hl_group_target,
            \ g:EasyMotion_hl2_first_group_target,
            \ g:EasyMotion_hl2_second_group_target,
            \ )
        " }}}

        " Restore undo tree
        call undo_lock.restore()

        redraw
    endtry "}}}

    " -- Check if we have an input char ------ {{{
    if empty(char)
        call s:Throw('Cancelled')
    endif
    " }}}
    " -- Check if the input char is valid ---- {{{
    if ! has_key(a:groups, char)
        call s:Throw('Invalid target')
    endif
    " }}}

    let target = a:groups[char]

    if type(target) == type([])
        " Return target coordinates
        return target
    else
        " Prompt for new target character
        let s:current.dot_prompt_user_cnt += 1
        return s:PromptUser(target)
    endif
endfunction "}}}

function! s:EasyMotion(regexp, direction, visualmode, is_inclusive, ...) " {{{
    let config = extend(s:default_config(), get(a:, 1, {}))
    " Store s:current original_position & cursor_position {{{
    " current cursor pos.
    let s:current.cursor_position = [line('.'), col('.')]
    " original start position.  This value could be changed later in visual
    " mode
    let s:current.original_position =
        \ get(s:current, 'original_position', s:current.cursor_position)
    "}}}

    let win_first_line = line('w0') " visible first line num
    let win_last_line  = line('w$') " visible last line num

    " Store the target positions list
    " e.g. targets = [ [line, col], [line2, col2], ...]
    let targets = []

    " To avoid side effect of overwriting buffer for tpope/repeat
    " store current b:changedtick. Use this value later
    let s:current.changedtick = b:changedtick

    try
        " -- Reset properties -------------------- {{{
        " Save original value and set new value
        call s:SaveValue()
        " call s:turn_off_hl_error()
        " }}}
        " Setup searchpos args {{{
        let search_direction = (a:direction == 1 ? 'b' : '')
        let search_stopline = a:direction == 1 ? win_first_line : win_last_line

        if s:flag.within_line == 1
            let search_stopline = s:current.original_position[0]
        endif
        "}}}

        " Handle visual mode {{{
        if ! empty(a:visualmode)
            " Decide at where visual mode start {{{
            normal! gv
            let v_start = [line("'<"),col("'<")] " visual_start_position
            let v_end   = [line("'>"),col("'>")] " visual_end_position

            let v_original_pos = s:GetVisualStartPosition(
                \ s:current.cursor_position, v_start, v_end, search_direction)
            "}}}

            " Reselect visual text {{{
            keepjumps call cursor(v_original_pos)
            exec "normal! " . a:visualmode
            keepjumps call cursor(s:current.cursor_position)
            "}}}
            " Update s:current.original_position
            " overwrite original start position
            let s:current.original_position = v_original_pos
        endif "}}}

        " Handle bi-directional t motion {{{
        " chant
        if s:flag.bd_t == 1
            let regexp = s:convert_t_regexp(a:regexp, 0) "forward
        else
            let regexp = a:regexp
        endif
        "}}}

        " Handle dot repeat with count
        if s:flag.count_dot_repeat
            let cursor_char = EasyMotion#helper#get_char_by_coord(s:current.cursor_position)
            if cursor_char =~# regexp
                call add(targets, s:current.cursor_position)
            endif
        endif

        let pos = searchpos(regexp, search_direction . (config.accept_cursor_pos ? 'c' : ''), search_stopline)
        while 1
            " Reached end of search range
            if pos == [0, 0]
                break
            endif

            " Skip folded lines {{{
            if EasyMotion#helper#is_folded(pos[0])
                if search_direction ==# 'b'
                    " FIXME: Hmm... I should use filter()
                    " keepjumps call cursor(foldclosed(pos[0]), 0)
                else
                    keepjumps call cursor(foldclosedend(pos[0]+1), 0)
                endif
            else
                call add(targets, pos)
            endif
            "}}}
            let pos = searchpos(regexp, search_direction, search_stopline)
        endwhile
        "}}}

        " Handle bidirection "{{{
        " For bi-directional t motion {{{
        if s:flag.bd_t == 1
            let regexp = s:convert_t_regexp(a:regexp, 1) "backward
        endif
        "}}}
        " Reconstruct match dict
        if a:direction == 2
            " Backward

            " Jump back cursor_position
            keepjumps call cursor(s:current.cursor_position[0],
                                \ s:current.cursor_position[1])

            let targets2 = []
            if s:flag.within_line == 0
                let search_stopline = win_first_line
            else
                let search_stopline = s:current.cursor_position[0]
            endif
            while 1
                " TODO: refactoring
                let pos = searchpos(regexp, 'b', search_stopline)
                " Reached end of search range
                if pos == [0, 0]
                    break
                endif

                " Skip folded lines {{{
                if EasyMotion#helper#is_folded(pos[0])
                    " keepjumps call cursor(foldclosedend(pos[0]+1), 0)
                    continue
                endif
                "}}}

                call add(targets2, pos)
            endwhile
            " Merge match target dict"{{{
            let t1 = 0 " forward
            let t2 = 0 " backward
            let targets3 = []
            while t1 < len(targets) || t2 < len(targets2)
                " Forward -> Backward -> F -> B -> ...
                if t1 < len(targets)
                    call add(targets3, targets[t1])
                    let t1 += 1
                endif
                if t2 < len(targets2)
                    call add(targets3, targets2[t2])
                    let t2 += 1
                endif
            endwhile
            let targets = targets3
            "}}}
        endif
        "}}}
        " Handle no match"{{{
        let targets_len = len(targets)
        if targets_len == 0
            call s:Throw('No matches')
        endif
        "}}}

        " Attach specific key as marker to gathered matched coordinates
        let g:chant = g:EasyMotion_grouping
        let GroupingFn = function('s:GroupingAlgorithm' . s:grouping_algorithms[g:EasyMotion_grouping])
        let groups = GroupingFn(targets, split(g:EasyMotion_keys, '\zs'))

        " -- Shade inactive source --------------- {{{
        if g:EasyMotion_do_shade && targets_len != 1 && s:flag.dot_repeat != 1
            if a:direction == 1 " Backward
                let shade_hl_re = s:flag.within_line
                                \ ? '^.*\%#'
                                \ : '\%'. win_first_line .'l\_.*\%#'
            elseif a:direction == 0 " Forward
                let shade_hl_re = s:flag.within_line
                                \ ? '\%#.*$'
                                \ : '\%#\_.*\%'. win_last_line .'l'
            else " Both directions
                let shade_hl_re = s:flag.within_line
                                \ ? '^.*\%#.*$'
                                \ : '\_.*'
            endif

            call EasyMotion#highlight#add_highlight(
                \ shade_hl_re, g:EasyMotion_hl_group_shade)
            if g:EasyMotion_cursor_highlight
                let cursor_hl_re = '\%#'
                call EasyMotion#highlight#add_highlight(cursor_hl_re,
                    \ g:EasyMotion_hl_inc_cursor)
            endif
        endif
        " }}}

        if ! empty(a:visualmode)
            keepjumps call winrestview({'lnum' : s:current.cursor_position[0], 'topline' : win_first_line})
        else
            " for adjusting cursorline
            keepjumps call cursor(s:current.cursor_position)
        endif
        "}}}

        " -- Prompt user for target group/character {{{
        let coords = s:PromptUser(groups)
        "}}}

        " -- Update cursor position -------------- {{{
        " First, jump back cursor to original position
        keepjumps call cursor(s:current.original_position)

        " Consider EasyMotion as jump motion :h jump-motion
        normal! m`

        " Update selection for visual mode {{{
        if ! empty(a:visualmode)
            exec 'normal! ' . a:visualmode
        endif
        " }}}

        " For bi-directional motion, checking again whether the motion is
        " inclusive is necessary. This value will might be updated later
        let is_inclusive_check = a:is_inclusive
        " For bi-directional motion, store 'true' direction for dot repeat
        " to handling inclusive/exclusive motion
        if a:direction == 2
            let true_direction =
                \ EasyMotion#helper#is_greater_coords(
                \   s:current.original_position, coords) > 0 ?
                \ 0 : 1
                " forward : backward
        else
            let true_direction = a:direction
        endif

        if s:flag.dot_repeat == 1
            " support dot repeat {{{
            " Use visual mode to emulate dot repeat
            normal! v

            " Deal with exclusive {{{
            if s:dot_repeat.is_inclusive == 0
                " exclusive
                if s:dot_repeat.true_direction == 0 "Forward
                    let coords[1] -= 1
                elseif s:dot_repeat.true_direction == 1 "Backward
                    " Shift visual selection to left by making cursor one key
                    " left.
                    normal! hoh
                endif
            endif "}}}

            " Jump to destination
            keepjumps call cursor(coords[0], coords[1])

            " Execute previous operator
            let cmd = s:dot_repeat.operator
            if s:dot_repeat.operator ==# 'c'
                let cmd .= getreg('.')
            endif
            exec 'normal! ' . cmd
            "}}}
        else
            " Handle inclusive & exclusive {{{
            " Overwrite inclusive flag for special case {{{
            if s:flag.find_bd == 1 && true_direction == 1
                " Note: For bi-directional find motion s(f) & t
                " If true_direction is backward, the motion is 'exclusive'
                let is_inclusive_check = 0 " overwrite
                let s:previous.is_inclusive = 0 " overwrite
            endif "}}}
            if is_inclusive_check
                normal! v
            endif " }}}

            if s:current.is_operator && s:flag.linewise
                " TODO: Is there better solution?
                " Maike it linewise
                normal! V
            endif

            " Adjust screen especially for visual scroll & offscreen search {{{
            " Otherwise, cursor line will move middle line of window
            keepjumps call winrestview({'lnum' : win_first_line, 'topline' : win_first_line})

            " Jump to destination
            keepjumps call cursor(coords[0], coords[1])

            " To avoid side effect of overwriting buffer {{{
            " for tpope/vim-repeat
            " See: :h b:changedtick
            if exists('g:repeat_tick')
                if g:repeat_tick == s:current.changedtick
                    let g:repeat_tick = b:changedtick
                endif
            endif "}}}
        endif

        " Set tpope/vim-repeat {{{
        if s:current.is_operator == 1 &&
                \ !(v:operator ==# 'y' && match(&cpo, 'y') == -1)
            " Store previous info for dot repeat {{{
            let s:dot_repeat.regexp = a:regexp
            let s:dot_repeat.direction = a:direction
            let s:dot_repeat.line_flag = s:flag.within_line
            let s:dot_repeat.is_inclusive = is_inclusive_check
            let s:dot_repeat.operator = v:operator
            let s:dot_repeat.bd_t_flag = s:flag.bd_t " Bidirectional t motion
            let s:dot_repeat.true_direction = true_direction " Check inclusive
            "}}}
            silent! call repeat#set("\<Plug>(easymotion-dotrepeat)")
        endif "}}}

        " Highlight all the matches by n-key find motions {{{
        if s:current.is_search == 1 && s:current.is_operator == 0 && g:EasyMotion_add_search_history
            " It seems let &hlsearch=&hlsearch doesn't work when called
            " in script, so use :h feedkeys() instead.
            " Ref: :h v:hlsearch
            " FIXME: doesn't work with `c` operator
            call EasyMotion#helper#silent_feedkeys(
                                    \ ":let &hlsearch=&hlsearch\<CR>",
                                    \ 'hlsearch', 'n')
        endif "}}}

        call s:Message('Jumping to [' . coords[0] . ', ' . coords[1] . ']')
        let s:EasyMotion_is_cancelled = 0 " Success
        "}}}
    catch /^EasyMotion:.*/
        redraw

        " Show exception message
        " The verbose option will take precedence
        if g:EasyMotion_verbose == 1 && g:EasyMotion_ignore_exception != 1
            echo v:exception
        endif

        let s:previous['regexp'] = a:regexp
        " -- Activate EasyMotion ----------------- {{{
        let s:EasyMotion_is_active = 1
        call EasyMotion#attach_active_autocmd() "}}}

        call s:restore_cursor_state(a:visualmode)
        let s:EasyMotion_is_cancelled = 1 " Cancel
    catch
        call s:Message(v:exception . ' : ' . v:throwpoint)
        call s:restore_cursor_state(a:visualmode)
        let s:EasyMotion_is_cancelled = 1 " Cancel
    finally
        " -- Restore properties ------------------ {{{
        call s:RestoreValue()
        " call s:turn_on_hl_error()
        call EasyMotion#reset()
        " }}}
        " -- Remove shading ---------------------- {{{
        call EasyMotion#highlight#delete_highlight()
        " }}}

        if s:EasyMotion_is_cancelled == 0 " Success
            " -- Landing Highlight ------------------- {{{
            if g:EasyMotion_landing_highlight
                call EasyMotion#highlight#add_highlight(a:regexp,
                                                      \ g:EasyMotion_hl_move)
                call EasyMotion#highlight#attach_autocmd()
            endif "}}}
            " -- Activate EasyMotion ----------------- {{{
            let s:EasyMotion_is_active = 1
            call EasyMotion#attach_active_autocmd() "}}}
        endif
    endtry
endfunction " }}}
"}}}
" }}}

call EasyMotion#init()
" Restore 'cpoptions' {{{
let &cpo = s:save_cpo
unlet s:save_cpo
" }}}
" vim: fdm=marker:et:ts=4:sw=4:sts=4
