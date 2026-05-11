#!/bin/bash
set -euo pipefail

dotfiles=$(cd $(dirname $0); pwd -P)
case $(uname -sr) in
*icrosoft*)
	_uname=WSL
	;;
*_NT*)
	if [[ -x /usr/bin/pacman ]]; then
		_uname=MSYS
	else
		_uname=GitBash
	fi
	;;
*)
	echo 'Unknown platform'
	exit 1
	;;
esac

rm_ln()
{
	(($# == 2)) || return 1
	local target=$1 linkname=$2
	rm -rf "$linkname"
	mkdir -p "$(dirname "$linkname")"
	ln -s "$target" "$linkname"
}

nt()
{
	[[ ${winhome:-} ]] || return 1
	rm_ln "$winhome" ~/WinHome
	rm_ln "$winhome/Downloads" ~/Downloads
}
ntcloud()
{
	[[ ${wincloud:-} ]] || return 1
	rm_ln "$wincloud" ~/Drive
}
wsl()
{
	sudo cp $dotfiles/wsl/wsl.conf /etc/wsl.conf
	sudo cp $dotfiles/wsl/fstab /etc/fstab
}

case $_uname in
GitBash|MSYS)
	export MSYS=winsymlinks:nativestrict
	wincloud=/g/マイドライブ
	pspath()
	{
		cygpath "$(powershell.exe -NoProfile "$1")"
	}
	;;
WSL)
	wincloud=/mnt/g/マイドライブ
	pspath()
	{
		wslpath "$(powershell.exe -NoProfile "$1" | tr -d '\r')"
	}
	;;
esac
winhome=$(pspath 'Get-Content Env:USERPROFILE')

if [[ ${1:-} ]]; then
	case ${1:-} in
	mintty)
		appdata=$(pspath 'Get-Content Env:APPDATA')
		mkdir -p "$appdata/mintty/"
		cp $dotfiles/mintty/* "$appdata/mintty/"
		;;
	powershell)
		windoc=$(pspath '[Environment]::GetFolderPath("MyDocuments")')
		mkdir -p "$windoc/PowerShell/"
		cp $dotfiles/PowerShell/* "$windoc/PowerShell/"
		;;
	vim)
		if type rsync &>/dev/null; then
			rsync -rtz --exclude=.git/ --exclude=/.netrwhist --exclude=/.viminfo --exclude=/swap --delete ~/.config/vim/ "$winhome/vimfiles"
		else
			mkdir -p "$winhome/vimfiles/"
			cp -r ~/.config/vim/* "$winhome/vimfiles/"
		fi
		;;
	esac
fi

case $_uname in
GitBash)
	ntcloud
	;;
MSYS)
	nt
	ntcloud
	;;
WSL)
	nt
	ntcloud
	wsl
	;;
esac
