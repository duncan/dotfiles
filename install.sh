#!/bin/bash

# BOOTSTRAP

if [ -d $HOME/src/dotfiles ] ; then
  echo "✅ Dotfiles repo accounted for!"
else
  echo "Starting from bare metal, I see. Daring! Let’s go!"
  mkdir -p $HOME/src
  git clone https://github.com/duncan/dotfiles
  if [ -d $HOME/src/dotfiles ] ; then
    echo "✅ Dotfiles repo cloned!"
  else
    echo "⛔️ Dotfiles repo wasn’t cloned successfully!"
    exit -1
  fi
  # Let's execute and exit the status
fi

cd $HOME/src/dotfiles

# FLOX
#
# Since we use Flox (a Nix wrapper)

if [ ! -f /usr/local/bin/flox ] ; then
  curl -L https://flox.dev/downloads/osx/flox.aarch64-darwin.pkg | sudo installer -pkg /dev/stdin -target /
  if  [ -f /usr/local/bin/flox ] ; then
    echo "✅ Flox installed successfully!"
  else
    echo "⛔️ Flox didn’t install successfully!"
    exit -1
  fi
else
  echo "✅ Flox is already installed!"
fi

# DOTFILES
#
# Ok, this is the pretty boring part. Just link things up and we’re done.

ln -nfs `realpath editorconfig` $HOME/.editorconfig
ln -nfs `realpath zshrc` $HOME/.zshrc
ln -nfs `realpath gitconfig` $HOME/.gitconfig
mkdir -p $HOME/.config/zed
ln -nfs `realpath zed.settings.json` $HOME/.config/zed/settings.json

# SAY GOODBYE

echo "🤖 You’re set up, buckaroo. Let’s go and make something awesome!"
