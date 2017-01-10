
let s:keymap_var = {
\  'init':   'te#key#init()',
\  'exit':   'te#key#exit()',
\  'accept': 'te#key#accept',
\  'lname':  'keymap',
\  'sname':  'keymap',
\  'type':   'line',
\  'sort':   0,
\}

if exists('g:ctrlp_ext_vars') && !empty(g:ctrlp_ext_vars)
  let g:ctrlp_ext_vars = add(g:ctrlp_ext_vars, s:keymap_var)
else
  let g:ctrlp_ext_vars = [s:keymap_var]
endif

function! te#key#init()
    return g:keymap_list
endfunction

function! te#key#getmap()
    let s = ''
    redir => s
    silent map <Space>
    redir END
    let l:temp = split(s, "\n")[1:]
endfunction
	 
function! te#key#accept(mode, str)
    call ctrlp#exit()
    " command
    if  matchstr(a:str,'\(\t\)\@<=[^<]') ==# ''
        exe matchstr(a:str, '\(\t\)\@<=.*\(<[cC][rR]>\)\@=')
    else
        exec "normal".feedkeys(escape(matchstr(a:str, '\(\t\)\@<=.*$'),'<'))
    endif
endfunction

function! te#key#exit()
endfunction

function! te#key#command()
  call ctrlp#init(te#key#id())
endfunction

let s:id = g:ctrlp_builtins + len(g:ctrlp_ext_vars)
function! te#key#id()
  return s:id
endfunction
