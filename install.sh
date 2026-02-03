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

# DEPS
#
# Basic dependency checks for tools used by this script.

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1 ; then
    echo "⛔️ Missing required command: $1"
    exit 1
  fi
}

require_cmd curl

# TODO: Replace this with detect if the script is being run from STDIN or not.

# if [ -d $HOME/src/dotfiles ] ; then
#   echo "✅ Dotfiles repo"
# else
#   echo "Starting from bare metal, I see. Daring! Let’s go!"
#   mkdir -p $HOME/src
#   git clone https://github.com/duncan/dotfiles $HOME/src/dotfiles
#   if [ -d $HOME/src/dotfiles ] ; then
#     echo "✅ Dotfiles repo cloned!"
#   else
#     echo "⛔️ Dotfiles repo wasn’t cloned successfully!"
#     exit 1
#   fi
#   # Let's execute and exit the status
# fi

# TODO: Figure out if we’re being executed from STDIN

cd `dirname $0`

# FLOX
#
# Since we use Flox (a Nix wrapper)

ARCH="$(uname -m)"
FLOX_PKG_URL=""

case "${MACHINE}" in
  Mac)
    case "${ARCH}" in
      arm64)  FLOX_PKG_URL="https://flox.dev/downloads/osx/flox.aarch64-darwin.pkg" ;;
      x86_64) FLOX_PKG_URL="" ;;
      *)      FLOX_PKG_URL="" ;;
    esac
    ;;
  Linux)
    FLOX_PKG_URL=""
    ;;
  *)
    FLOX_PKG_URL=""
    ;;
esac

if [ ! -f /usr/local/bin/flox ] ; then
  require_cmd curl
  if [ -z "${FLOX_PKG_URL}" ] ; then
    echo "⛔️ No Flox installer configured for ${MACHINE}/${ARCH}."
    echo "    Please install Flox manually for your platform, then re-run ./install.sh"
    exit 1
  fi
  curl -L "${FLOX_PKG_URL}" -o /tmp/flox.pkg
  if [ "${MACHINE}" = "Mac" ] ; then
    if ! pkgutil --check-signature /tmp/flox.pkg >/tmp/flox.pkg.sig 2>&1 ; then
      echo "⛔️ Flox pkg signature check failed!"
      cat /tmp/flox.pkg.sig
      rm /tmp/flox.pkg /tmp/flox.pkg.sig
      exit 1
    fi
    if ! spctl -a -vv -t install /tmp/flox.pkg >/tmp/flox.pkg.spctl 2>&1 ; then
      echo "⛔️ Flox pkg notarization check failed!"
      cat /tmp/flox.pkg.spctl
      rm /tmp/flox.pkg /tmp/flox.pkg.sig /tmp/flox.pkg.spctl
      exit 1
    fi
    rm /tmp/flox.pkg.sig /tmp/flox.pkg.spctl
  fi
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

require_cmd npm
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

require_cmd realpath
ln -nfs `realpath editorconfig` $HOME/.editorconfig
ln -nfs `realpath zshrc` $HOME/.zshrc
ln -nfs `realpath gitconfig` $HOME/.gitconfig
mkdir -p $HOME/.config
ln -nfs `realpath starship.toml` $HOME/.config/starship.toml
mkdir -p $HOME/.config/zed
ln -nfs `realpath zed.settings.json` $HOME/.config/zed/settings.json

# SAY GOODBYE

echo "🤖 You’re set up, buckaroo. Let’s go and make something awesome!"
