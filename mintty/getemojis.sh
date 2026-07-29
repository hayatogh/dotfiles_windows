#!/bin/bash
set -euo pipefail

pspath()
{
	local cmd
	if type cygpath &>/dev/null; then
		cygpath "$(powershell.exe -NoProfile "$1")"
	else
		wslpath "$(powershell.exe -NoProfile "$1" | tr -d '\r')"
	fi
}

appdata=$(pspath 'Get-Content Env:APPDATA')
mintty=$appdata/mintty

cd $mintty
rm -rf emojis
mkdir emojis
cd emojis

curl -fsSLo getemojis https://github.com/mintty/mintty/raw/master/tools/getemojis
chmod +x getemojis
./getemojis -d google
