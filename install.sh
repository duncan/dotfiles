#/bin/bash

cd `dirname $0`

# LINK DOTFILES
ln -nfs `realpath editorconfig` $HOME/.editorconfig
ln -nfs `realpath zshrc` $HOME/.zshrc
