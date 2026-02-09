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
mkdir -p "${HOME}/bin"

THIS_DIR=$(cd $(dirname $0) && pwd)

for script in $THIS_DIR/../bin/*
do
  $THIS_DIR/setup_bin.sh $script
done
