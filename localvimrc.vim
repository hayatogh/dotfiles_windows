" Mintty
let &t_SI ..= g:Passthrough("\e[<r")
let &t_EI ..= g:Passthrough("\e[<s\e[<0t")
let &t_te ..= g:Passthrough("\e[<0t\e[<s")

fu! s:FontSizeSet(amount)
	call echoraw(g:Passthrough("\e]7770;" .. a:amount .. "\x7"))
endfu
fu! s:FontSizeGet()
	let l:ret = ""
	call <SID>FontSizeSet('?')
	while 1
		let l:c = getcharstr()
		let l:ret ..= l:c
		if l:c ==# "\x7"
			break
		endif
	endwhile
	echo l:ret[7:-2]
endfu
com! FontSizeGet call <SID>FontSizeGet()
com! FontSizeReset call <SID>FontSizeSet('')
nno <silent> <Esc>=              <Cmd>call <SID>FontSizeSet('')<CR>
nno <silent> <Esc>+              <Cmd>call <SID>FontSizeSet('+1')<CR>
nno <silent> <Esc>-              <Cmd>call <SID>FontSizeSet('-1')<CR>
nno <silent> <C-ScrollWheelUp>   <Cmd>call <SID>FontSizeSet('+1')<CR>
nno <silent> <C-ScrollWheelDown> <Cmd>call <SID>FontSizeSet('-1')<CR>

if has('win32')
	se shell=pwsh
	se t_Co=256
	sil! vun <C-X>
endif

if has('gui_win32')
	se clipboard=unnamed
	se guicursor=a:blinkon0
	se guifont=Consolas:h11
	se guioptions=!Mr
	se lines=30 columns=86
	se nomousehide
	let s:guifont_default_size = split(split(&guifont, '[^\\]\zs,')[0], '[^\\]\zs:')[1][1:]
	fu! s:FontSizeSet(amount)
		let l:font = split(split(&guifont, '[^\\]\zs,')[0], '[^\\]\zs:')
		let l:size = l:font[1][1:]
		if a:amount ==# ""
			let l:size = s:guifont_default_size
		else
			let l:size = eval(l:size .. a:amount)
			if l:size == 0
				let l:size = 1
			endif
		endif
		let l:font[1] = l:font[1][0] .. l:size
		let &guifont = join(l:font, ':')
	endfu
	fu! s:CopyOSC52(list)
	endfu

	nno <silent> <M-Space> <Cmd>simalt ~<CR>
	cno <M-/> <C-\>e<SID>RegexRubout('\v[^/\\]*(/\|\\)? *$')<CR>
	cno <M-w> <C-\>e<SID>RegexRubout('\v[^ ]* *$')<CR>
	nno <M-m> <C-W>-
	nno <M-p> <C-W>+
	nno <silent> <M-=> <Cmd>call <SID>FontSizeSet('')<CR>
	nno <silent> <M-+> <Cmd>call <SID>FontSizeSet('+1')<CR>
	nno <silent> <M--> <Cmd>call <SID>FontSizeSet('-1')<CR>
	nno <silent> <C-=> <Cmd>call <SID>FontSizeSet('')<CR>

	aug vimrc
		au ColorScheme * hi Cursor guifg=fg guibg=Red
		au ColorScheme * hi CursorIM guifg=Black guibg=Blue
		au ColorScheme * hi TabLineFill guibg=#808080
		au ColorScheme * hi TrailingWhiteSpace guibg=darkred
		au ColorScheme * hi IdeographicSpace guibg=DarkGreen
	aug END
endif

if has('win32unix')
	let g:ale_enabled = 0
endif
