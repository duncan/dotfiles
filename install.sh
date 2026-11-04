#!/bin/bash

set -e

DOTFILES="$(cd "$(dirname "$0")" && pwd -P)"

# PACKAGES
#
# Homebrew on macOS, apt on Ubuntu. Keep the two lists in step with each
# other. Either way, rustup comes from the package manager and manages the
# toolchains itself.

case "$(uname -s)" in
  Darwin)
    if [ ! -x /opt/homebrew/bin/brew ] ; then
      echo "🍺 Homebrew not found; installing it."
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi

    /opt/homebrew/bin/brew bundle --file="$DOTFILES/Brewfile"
    RUSTUP=/opt/homebrew/opt/rustup/bin/rustup
    ;;

  Linux)
    sudo apt-get update
    sudo apt-get install -y curl

    # Ubuntu's own nodejs lags well behind; NodeSource tracks the current
    # release, like Homebrew does. Its nodejs package includes npm.
    if [ ! -f /etc/apt/sources.list.d/nodesource.list ] ; then
      curl -fsSL https://deb.nodesource.com/setup_current.x | sudo -E bash -
    fi

    sudo apt-get install -y zsh git gh git-lfs nodejs ripgrep rustup

    if ! command -v pnpm >/dev/null 2>&1 ; then
      sudo npm install -g pnpm
    fi
    RUSTUP=/usr/bin/rustup

    ZSH="$(command -v zsh)"
    if [ "$(getent passwd "$USER" | cut -d: -f7)" != "$ZSH" ] ; then
      chsh -s "$ZSH"
      echo "🐚 Default shell is now zsh; log out and back in to pick it up."
    fi
    ;;

  *)
    echo "⚠️  Unsupported OS $(uname -s); skipping packages."
    ;;
esac

if [ -x "${RUSTUP:-}" ] && ! "$RUSTUP" default >/dev/null 2>&1 ; then
  "$RUSTUP" default stable
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
