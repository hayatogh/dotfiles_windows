#!/bin/bash
set -euo pipefail

rm_ln()
{
	(($# == 2)) || return 1
	local target=$1 linkname=$2
	rm -rf "$linkname"
	mkdir -p "$(dirname "$linkname")"
	ln -s "$target" "$linkname"
}
pspath()
{
	local cmd
	if type cygpath &>/dev/null; then
		cygpath "$(powershell.exe -NoProfile "$1")"
	else
		wslpath "$(powershell.exe -NoProfile "$1" | tr -d '\r')"
	fi
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
	[[ ${dotfiles:-} ]] || return 1
	sudo cp $dotfiles/wsl/wsl.conf /etc/wsl.conf
	sudo cp $dotfiles/wsl/fstab /etc/fstab
}
mintty()
{
	[[ ${dotfiles:-} ]] || return 1
	local appdata
	appdata=$(pspath 'Get-Content Env:APPDATA')
	mkdir -p "$appdata/mintty/"
	cp $dotfiles/mintty/* "$appdata/mintty/"
}
pwsh()
{
	[[ ${dotfiles:-} ]] || return 1
	local windoc
	windoc=$(pspath '[Environment]::GetFolderPath("MyDocuments")')
	mkdir -p "$windoc/PowerShell/"
	cp $dotfiles/PowerShell/* "$windoc/PowerShell/"
}
vim()
{
	[[ ${winhome:-} ]] || return 1
	if type rsync &>/dev/null; then
		rsync -rtz --exclude=.git/ --exclude=/.netrwhist --exclude=/.viminfo --exclude=/swap --delete ~/.config/vim/ "$winhome/vimfiles"
	else
		mkdir -p "$winhome/vimfiles/"
		cp -r ~/.config/vim/* "$winhome/vimfiles/"
	fi
}

dotfiles=$(cd $(dirname $0); pwd -P)
winhome=$(pspath 'Get-Content Env:USERPROFILE')
case $(uname -sr) in
*icrosoft*)
	_uname=WSL
	wincloud=/mnt/g/マイドライブ
	;;
*_NT*)
	if [[ -x /usr/bin/pacman ]]; then
		_uname=MSYS
	else
		_uname=GitBash
	fi
	export MSYS=winsymlinks:nativestrict
	wincloud=/g/マイドライブ
	;;
*)
	echo 'Unknown platform'
	exit 1
	;;
esac

case ${1:-} in
mintty) mintty ;;
pwsh) pwsh ;;
vim) vim ;;
esac
case $_uname in
GitBash) ntcloud ;;
MSYS) nt ; ntcloud ;;
WSL) nt ; ntcloud ; wsl ;;
esac
