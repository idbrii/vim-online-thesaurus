" Vim plugin for looking up words in an online thesaurus
" Author:       Anton Beloglazov <http://beloglazov.info/>
" Version:      0.1.7
" Original idea and code: Nick Coleman <http://www.nickcoleman.org/>

if exists("g:loaded_online_thesaurus")
    finish
endif
let g:loaded_online_thesaurus = 1

let s:save_cpo = &cpo
set cpo&vim

let s:path = expand("<sfile>:p:h")

function! s:FindLastWindow()
    if exists('g:online_thesaurus_window')
        return bufwinnr(g:online_thesaurus_window)
    endif

    return -1
endfunction

function! s:Lookup(word)
    let winnr = s:FindLastWindow()
    if winnr >= 0
        execute winnr . 'wincmd w'
    else
        silent keepalt belowright split thesaurus
        let g:online_thesaurus_window = bufnr('%')
    endif
    setlocal noswapfile nobuflisted nospell nowrap modifiable
    setlocal buftype=nofile bufhidden=hide
    1,$d
    echo "Requesting thesaurus.com to look up the word \"" . a:word . "\"..."
    exec "silent 0r !" . s:path . "/thesaurus-lookup " . a:word
    normal! Vgqgg
    exec 'resize ' . (line('$') - 1)
    setlocal nomodifiable filetype=thesaurus
    nnoremap <silent> <buffer> q :q<CR>
endfunction

if !exists('g:online_thesaurus_map_keys')
    let g:online_thesaurus_map_keys = 1
endif

if g:online_thesaurus_map_keys
    nnoremap <unique> <LocalLeader>K :OnlineThesaurusCurrentWord<CR>
endif

command! OnlineThesaurusCurrentWord :call <SID>Lookup(expand('<cword>'))
command! OnlineThesaurusLookup :call <SID>Lookup(expand('<cword>'))
command! -nargs=1 Thesaurus :call <SID>Lookup(<f-args>)

let &cpo = s:save_cpo
