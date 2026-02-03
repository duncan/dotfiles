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

install_flox_pkg() {
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
}

get_latest_flox_version() {
  local url="https://api.github.com/repos/flox/flox/releases/latest"
  local version=""
  local json=""

  json="$(curl -fsSL "${url}")" || return 1
  version="$(
    printf '%s' "${json}" \
      | grep -Eo '"tag_name"[[:space:]]*:[[:space:]]*"v?[0-9]+\.[0-9]+\.[0-9]+"' \
      | head -n 1 \
      | sed -E 's/.*"tag_name"[[:space:]]*:[[:space:]]*"v?([0-9]+\.[0-9]+\.[0-9]+)".*/\1/'
  )"

  printf '%s' "${version}"
}

normalize_version() {
  printf '%s' "$1" | sed -E 's/^v//'
}

version_lt() {
  local IFS=.
  local -a a=($1) b=($2)
  local i ai bi

  for i in 0 1 2 ; do
    ai="${a[$i]:-0}"
    bi="${b[$i]:-0}"
    if [ "${ai}" -lt "${bi}" ] ; then
      return 0
    fi
    if [ "${ai}" -gt "${bi}" ] ; then
      return 1
    fi
  done
  return 1
}

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

cd "$(dirname "$0")"

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
  install_flox_pkg
  if  [ -f /usr/local/bin/flox ] ; then
    echo "✅ Flox installed successfully!"
  else
    echo "⛔️ Flox didn’t install successfully!"
    exit 1
  fi
else
  echo "✅ Flox"
fi

if [ -x /usr/local/bin/flox ] ; then
  INSTALLED_FLOX_VERSION="$(flox --version 2>/dev/null | grep -Eo '[0-9]+\.[0-9]+\.[0-9]+' | head -n 1)"
  if [ -n "${INSTALLED_FLOX_VERSION}" ] ; then
    LATEST_FLOX_VERSION="$(get_latest_flox_version || true)"
    INSTALLED_FLOX_VERSION="$(normalize_version "${INSTALLED_FLOX_VERSION}")"
    LATEST_FLOX_VERSION="$(normalize_version "${LATEST_FLOX_VERSION}")"
    if [ -n "${LATEST_FLOX_VERSION}" ] && version_lt "${INSTALLED_FLOX_VERSION}" "${LATEST_FLOX_VERSION}" ; then
      echo "⚠️  Flox is out of date: ${INSTALLED_FLOX_VERSION} < ${LATEST_FLOX_VERSION}"
      echo "    Upgrading now..."
      install_flox_pkg
      UPDATED_FLOX_VERSION="$(flox --version 2>/dev/null | grep -Eo '[0-9]+\.[0-9]+\.[0-9]+' | head -n 1)"
      UPDATED_FLOX_VERSION="$(normalize_version "${UPDATED_FLOX_VERSION}")"
      if [ -n "${UPDATED_FLOX_VERSION}" ] && ! version_lt "${UPDATED_FLOX_VERSION}" "${LATEST_FLOX_VERSION}" ; then
        echo "✅ Flox updated: ${UPDATED_FLOX_VERSION}"
      else
        echo "⚠️  Flox update may have failed. Installed: ${UPDATED_FLOX_VERSION:-unknown}, Latest: ${LATEST_FLOX_VERSION}"
      fi
    elif [ -z "${LATEST_FLOX_VERSION}" ] ; then
      echo "⚠️  Could not determine latest Flox version from GitHub releases; skipping update check."
    fi
  fi
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

# DOTFILES
#
# Ok, this is the pretty boring part. Just link things up and we’re done.

require_cmd realpath
ln -nfs "$(realpath editorconfig)" "$HOME/.editorconfig"
ln -nfs "$(realpath zshrc)" "$HOME/.zshrc"
ln -nfs "$(realpath gitconfig)" "$HOME/.gitconfig"
mkdir -p "$HOME/.config"
ln -nfs "$(realpath starship.toml)" "$HOME/.config/starship.toml"
mkdir -p "$HOME/.config/zed"
ln -nfs "$(realpath zed.settings.json)" "$HOME/.config/zed/settings.json"

# SAY GOODBYE

echo "🤖 You’re set up, buckaroo. Let’s go and make something awesome!"
