
" name :s:TracyoneGetError
" arg  :command,vim command(not shell command) that want to
"       test execute status
" arg   : err_str,error substring pattern that is expected
" return:return 0 if no error exist,return -1 else
function! te#utils#GetError(command,err_str) abort
    redir => l:msg
    silent! execute a:command
    redir END
    let l:rs=split(l:msg,'\r\n\|\n')
    if get(l:rs,-1,3) ==3  "no error exists
        return 0
    elseif l:rs[-1] =~# a:err_str
        return -1
    else
        return 0
    endif
endfunction


"echo warning messag
"a:0-->err or warn or none,default
func! te#utils#EchoWarning(str,...) abort
    redraw!
    let l:level='WarningMsg'
    if a:0 == 1
        if a:1 ==? 'err'
            let l:level='ErrorMsg'
        elseif a:1 ==? 'warn'
            let l:level='WarningMsg'
        elseif a:1 ==? 'none'
            let l:level='None'
        endif
    endif
    execut 'echohl '.l:level | echo a:str | echohl None
endfunc


" save files in every condition
function! te#utils#SaveFiles() abort
    try 
        update
    catch /^Vim\%((\a\+)\)\=:E212/
        if exists(':SudoWrite')
            call te#utils#EchoWarning('sudo write,please input your password!')
            SudoWrite %
            return 0
        else
            :w !sudo tee %
        endif
    catch /^Vim\%((\a\+)\)\=:E32/   "no file name
        if has('gui_running') ||  has('gui_macvim')
            exec ':emenu File.Save'
            return 0
        endif
        let l:filename=input('NO FILE NAME!Please input the file name: ')
        if l:filename ==# ''
            call te#utils#EchoWarning('You just give a empty name!')
            return 3
        endif
        try 
            exec 'w '.l:filename
        catch /^Vim\%((\a\+)\)\=:E212/
            call te#utils#EchoWarning('sudo write,please input your password!')
            if exists(':SudoWrite')
                SudoWrite %
                return 0
            else
                :w !sudo tee %
            endif
        endtry
    endtry
endfunction

"opt_str can be vim option or variable's name(string)
"toggle list,length must 2
"eg. call te#utils#OptionToggle("background",["dark","light"]
function! te#utils#OptionToggle(opt_str,opt_list) abort
    let l:len=len(a:opt_list)
    if l:len != 2 
        call te#utils#EchoWarning('Invalid argument.','err')
        return 1
    endif
    if exists('&'.a:opt_str)
        let l:leed='&'
        let l:opt_val=eval('&'.a:opt_str)
    elseif exists(a:opt_str)
        let l:leed=''
        let l:opt_val=eval(a:opt_str)
    else
        call te#utils#EchoWarning(a:opt_str.' not found','err')
        return 2
    endif
    if l:opt_val == a:opt_list[0]
        execute 'let '.l:leed.a:opt_str.'='.'"'.a:opt_list[1].'"'
        call te#utils#EchoWarning('Change '.l:leed.a:opt_str.' from '.l:opt_val.' to '.a:opt_list[1])
    elseif l:opt_val == a:opt_list[1]
        execute 'let '.l:leed.a:opt_str.'='.'"'.a:opt_list[0].'"'
        call te#utils#EchoWarning('Change '.l:leed.a:opt_str.' from '.l:opt_val.' to '.a:opt_list[0])
    else
        execute 'let '.l:leed.a:opt_str.'='.'"'.a:opt_list[0].'"'
        call te#utils#EchoWarning('Change '.l:leed.a:opt_str.' from '.l:opt_val.' to '.a:opt_list[0])
    endif
    return 0
endfunction

function! te#utils#SourceRc(path) abort
    let l:ft_orig=&ft
    :call te#utils#EchoWarning('Sourcing '.a:path.' ...')
    execute ':source '.a:path
    :execute "set ft=".l:ft_orig
    :call te#utils#EchoWarning(a:path.' has been sourced.')
endfunction
