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
    let s:EasyMotion_is_active = 0
    call EasyMotion#reset()

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
        \ 'regexp' : 0,
        \ 'bd_t' : 0,
        \ 'find_bd' : 0,
        \ 'linewise' : 0,
        \ }
        " regexp: -> regular expression
        "   This value is used when multi input find motion. If this values is
        "   1, input text is treated as regexp.(Default: escaped)
        " bd_t: -> bi-directional 't' motion
        "   This value is used to re-define regexp only for bi-directional 't'
        "   motion
    let s:current = {
        \ 'is_operator' : 0,
        \ 'is_search' : 0,
        \ 'dot_prompt_user_cnt' : 0,
        \ 'changedtick' : 0,
        \ }

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

function! s:GroupingAlgorithmOriginal(targets, keys)
    " Split targets into groups (1 level)
    let targets_len = len(a:targets)
    " let keys_len = len(a:keys)

    let groups = {}

    let i = 0
    let root_group = 0
    try
        while root_group < targets_len
            let groups[a:keys[root_group]] = {}

            for key in a:keys
                let groups[a:keys[root_group]][key] = a:targets[i]

                let i += 1
            endfor

            let root_group += 1
        endwhile
    catch | endtry

    " Flatten the group array
    if len(groups) == 1
        let groups = groups[a:keys[0]]
    endif

    return groups
endfunction

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
"}}}
" Core Functions: {{{
function! s:PromptUser(groups) "{{{
    " Recursive
    let group_values = values(a:groups)

    " -- If only one possible match, jump directly to it {{{
    if len(group_values) == 1
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
        let marker_max_length = 2
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
        let char = s:GetChar()
        "}}}

        " Convert uppercase {{{
        if g:EasyMotion_use_upper == 1 && match(g:EasyMotion_keys, '\l') == -1
            let char = toupper(char)
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

        let regexp = a:regexp
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
        let groups = s:GroupingAlgorithmOriginal(targets, split(g:EasyMotion_keys, '\zs'))

        if ! empty(a:visualmode)
            keepjumps call winrestview({'lnum' : s:current.cursor_position[0], 'topline' : win_first_line})
        else
            " for adjusting cursorline
            keepjumps call cursor(s:current.cursor_position)
        endif

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

        let s:EasyMotion_is_cancelled = 0 " Success
        "}}}
    catch /^EasyMotion:.*/
        redraw

        let s:previous['regexp'] = a:regexp
        " -- Activate EasyMotion ----------------- {{{
        let s:EasyMotion_is_active = 1
        call EasyMotion#attach_active_autocmd() "}}}

        call s:restore_cursor_state(a:visualmode)
        let s:EasyMotion_is_cancelled = 1 " Cancel
    catch
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
            " -- Activate EasyMotion ----------------- {{{
            let s:EasyMotion_is_active = 1
            call EasyMotion#attach_active_autocmd() "}}}
        endif
    endtry
endfunction " }}}
" }}}

call EasyMotion#init()
" Restore 'cpoptions' {{{
let &cpo = s:save_cpo
unlet s:save_cpo
" }}}
" vim: fdm=marker:et:ts=4:sw=4:sts=4
