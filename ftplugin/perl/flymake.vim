""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"          FILE:  flymake-perl.vim
" Last Modified:  2012/05/22.
"        AUTHOR:  Yusuke Watase (ym), ywatase@gmail.com
"       VERSION:  1.0
"       CREATED:  2010/04/22 12:28:48
"   DESCRIPTION:  flymake for perl. put this file to .vim/ftplugin/perl
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Only do this when not done yet for this buffer
if exists("b:did_flymake_perl_ftplugin")
	finish
endif
let b:did_flymake_perl_ftplugin = 1

function! RunMake ()
	let l:include_path = []
	let l:archname = system('perl -MConfig -e '."'".'print $Config{archname}'."'")

	""" Regex
	" under MyApp/t
	let l:regex_under_t = '^.\{-}\%(/t/\%(lib/t/\)\?\)\@='
	" under MyApp/{extlib,lib,local,bin,script,scripts,root}
	let l:regex_under_other  = '^.*/\%(\%(ext\)\?lib\|local\|bin\|scripts\?\|root\)\@='

	if expand('%:p') =~ l:regex_under_t
		let l:result = matchstr(expand('%:p'), l:regex_under_t)
		let l:dir = simplify(l:result . '/t/lib')
		if isdirectory(l:dir)
			call add(l:include_path, l:dir)
		endif 
	elseif expand('%:p') =~ l:regex_under_other
		let l:result = matchstr(expand('%:p'), l:regex_under_other)
	else
		let l:result = expand('%:p:h')
	endif
	let l:dir = simplify(l:result . '/lib')
	if isdirectory(l:dir)
		call add(l:include_path, l:dir)
	endif 
	let l:dir = simplify(l:result . '/extlib/lib/perl5')
	if isdirectory(l:dir)
		call add(l:include_path, l:dir)
	endif 
	let l:dir = simplify(l:result . '/extlib/lib/perl5/'.l:archname)
	if isdirectory(l:dir)
		call add(l:include_path, l:dir)
	endif 
	let l:dir = simplify(l:result . '/local/lib/perl5')
	if isdirectory(l:dir)
		call add(l:include_path, l:dir)
	endif 
	let l:dir = simplify(l:result . '/local/lib/perl5/'.l:archname)
	if isdirectory(l:dir)
		call add(l:include_path, l:dir)
	endif 
	let l:cmd_parse_result = 'perl -pe '. "'" . '/at\s(\S+)\sline\s(\d+)/;print qq{$1:$2:};' . "'"
	execute ':setlocal makeprg=' . escape('perl ' . join(map(copy(l:include_path), '"-I ".v:val'),' ') . ' -cw % 2>&1 \| ' . l:cmd_parse_result , ' \();$|')
	execute ':setlocal path='. join(add(map(copy(l:include_path), 'escape(v:val, " ,")'), &l:path), ',')
	setlocal errorformat=%f:%l:%m
	make
endfunction

autocmd! BufWritePost <buffer> :call RunMake()
