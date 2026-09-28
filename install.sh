#!/bin/bash

set -e

DOTFILES="$(cd "$(dirname "$0")" && pwd -P)"

ln -nfs "$DOTFILES/editorconfig" "$HOME/.editorconfig"
ln -nfs "$DOTFILES/zshrc" "$HOME/.zshrc"
ln -nfs "$DOTFILES/zprofile" "$HOME/.zprofile"
ln -nfs "$DOTFILES/gitconfig" "$HOME/.gitconfig"

mkdir -p "$HOME/.config/zed"
ln -nfs "$DOTFILES/zed.settings.json" "$HOME/.config/zed/settings.json"

# SAY GOODBYE

echo "🤖 You’re set up, buckaroo. Let’s go and make something awesome!"
