if [ -x /opt/homebrew/bin/brew ] ; then
  eval "$(/opt/homebrew/bin/brew shellenv zsh)"
fi

if [ -d /opt/homebrew/opt/rustup/bin ] ; then
  export PATH="/opt/homebrew/opt/rustup/bin:$PATH"
fi
export PATH="$HOME/.cargo/bin:$PATH"
