#!/bin/bash
set -euo pipefail

l=$1 r=$2
base='sed -E '\''s:.*/::'\'
root='sed -E '\''s:.*/::; s/(.+)\.[a-zA-Z0-9]+$/\1/'\'

basel=$(eval $base <<<$l)
baser=$(eval $base <<<$r)
rootl=$(eval $root <<<$l)
rootr=$(eval $root <<<$r)
out="diff_${rootl}_$rootr.html"
if [[ $rootl == $rootr ]]; then
	out="diff_$rootl.html"
fi
if type cygpath &>/dev/null; then
	winmerge='/c/Program Files/WinMerge/WinMergeU.exe'
	pathl=$l
	pathr=$r
else
	winmerge='/mnt/c/Program Files/WinMerge/WinMergeU.exe'
	pathl=$(wslpath -w "$l")
	pathr=$(wslpath -w "$r")
fi

"$winmerge" -noninteractive -dl "$basel" -dr "$baser" -or "$out" "$pathl" "$pathr"
