#!/bin/bash

RCDIR="$HOME/dotfiles/rc"

LINKER=ln

cd $RCDIR
PATHS=`find . -type f`

cd ~
for path in $PATHS
do
  mkdir -p `dirname $path`
  $LINKER -svf "${RCDIR}/${path}" $path
done

# 
rm -rf "${HOME}/bin"
$LINKER -svf "$HOME/dotfiles/bin" "$HOME/bin"
