case $(uname -sr) in
*icrosoft*)
	_uname=WSL;;
*Linux*)
	_uname=Linux;;
*_NT*)
	if [[ -x /usr/bin/pacman ]]; then
		_uname=MSYS
	else
		_uname=GitBash
	fi;;
*)
	_uname=Other;;
esac

alias diffw='~/dotfiles_windows/diffw.sh'
case $_uname in
GitBash|MSYS)
	export LANG=$(locale -uU)
	_pathadd /c/Users/$USER/AppData/Local/Microsoft/WinGet/Links
	_pathadd /c/Users/$USER/.cargo/bin
	GOROOT=/c/Go
	GOPATH=/c/Users/$USER/go
	_pathadd $GOROOT/bin
	_pathadd $GOPATH/bin
	export MSYS=winsymlinks:nativestrict

	shopt -s completion_strip_exe
	_pc2=$(sed -E 's/@\\h/& \\[\\e[35m\\]$MSYSTEM/' <<<$_pc2)
	open()
	{
		start "$@"
	}
	;;&
GitBash)
	printf '\e]l;Git Bash\a'
	upgrade()
	{
		git update-git-for-windows -y
	}
	# _load_if_readable /mingw64/share/git/completion/git-prompt.sh
	;;
MSYS)
	upgrade()
	{
		pacman -Syu --noconfirm
		pacman -Qtdq | pacman -Rns --noconfirm - 2>/dev/null
	}
	_load_if_readable /usr/share/git/git-prompt.sh
	;;
WSL)
	LC_CTYPE=en_US.UTF-8

	alias shutdown='wsl.exe --shutdown'
	;;
esac
