#!/bin/bash

# OS DETECTION
#
OS="$(uname -s)"
case "${OS}" in
  Linux*)     MACHINE=Linux;;
  Darwin*)    MACHINE=Mac;;
  *)          MACHINE="UNKNOWN:${OS}"
esac
echo "ℹ️ Machine type: $MACHINE"

# BOOTSTRAP

if [ -d $HOME/src/dotfiles ] ; then
  echo "✅ Dotfiles repo"
else
  echo "Starting from bare metal, I see. Daring! Let’s go!"
  mkdir -p $HOME/src
  git clone https://github.com/duncan/dotfiles $HOME/src/dotfiles
  if [ -d $HOME/src/dotfiles ] ; then
    echo "✅ Dotfiles repo cloned!"
  else
    echo "⛔️ Dotfiles repo wasn’t cloned successfully!"
    exit 1
  fi
  # Let's execute and exit the status
fi

cd $HOME/src/dotfiles

# FLOX
#
# Since we use Flox (a Nix wrapper)

if [ ! -f /usr/local/bin/flox ] ; then
  curl -L https://flox.dev/downloads/osx/flox.aarch64-darwin.pkg -o /tmp/flox.pkg
  sudo installer -pkg /tmp/flox.pkg -target /
  rm /tmp/flox.pkg
  if  [ -f /usr/local/bin/flox ] ; then
    echo "✅ Flox installed successfully!"
  else
    echo "⛔️ Flox didn’t install successfully!"
    exit 1
  fi
else
  echo "✅ Flox"
fi

# Check if we're using duncan/default environment
if flox envs 2>/dev/null | grep -q "default.*$HOME"; then
  echo "✅ Flox environment default/duncan"
else
  echo "📦 Pulling default environment from FloxHub..."
  flox pull duncan/default 2>/dev/null
  if flox envs 2>/dev/null | grep -q "default.*$HOME"; then
    echo "✅ Default environment pulled successfully!"
  else
    echo "⛔️ Failed to pull default environment!"
    exit 1
  fi
fi

# CLAUDE
#
# Make sure the robot is installed. I wish this was in my Flox default
# environment tho. On the other hand, claude is rapidly evolving so 🤷

NPM_GLOBAL_BIN="$(npm config get prefix)/bin"
if [ -f "$NPM_GLOBAL_BIN/claude" ]; then
  echo "✅ Claude code"
else
  npm install -g @anthropic-ai/claude-code
  if [ -f "$NPM_GLOBAL_BIN/claude" ]; then
    echo "✅ Claude code installed"
  else
    echo "⛔️ Failed to install claude code!"
    exit 1
  fi
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
