#!/bin/bash

set -e

DOTFILES="$(cd "$(dirname "$0")" && pwd -P)"

# HOMEBREW

if [ -x /opt/homebrew/bin/brew ] ; then
  /opt/homebrew/bin/brew bundle --file="$DOTFILES/Brewfile"
else
  echo "⚠️  Homebrew not found; skipping Brewfile."
fi

# LINKS
#
# Existing files that aren't already links get moved aside rather than
# clobbered, so nothing is lost on a machine that's been set up by hand.

link() {
  local src="$DOTFILES/$1"
  local dest="$2"

  mkdir -p "$(dirname "$dest")"
  if [ -e "$dest" ] && [ ! -L "$dest" ] ; then
    local backup="$dest.$(date +%Y%m%d%H%M%S).bak"
    mv "$dest" "$backup"
    echo "📦 Backed up $dest to $backup"
  fi
  ln -nfs "$src" "$dest"
}

link editorconfig "$HOME/.editorconfig"
link zshrc "$HOME/.zshrc"
link zprofile "$HOME/.zprofile"
link gitconfig "$HOME/.gitconfig"
link gitignore "$HOME/.config/git/ignore"
link zed.settings.json "$HOME/.config/zed/settings.json"

# SAY GOODBYE

echo "🤖 You’re set up, buckaroo. Let’s go and make something awesome!"
