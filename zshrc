if [ -t 1 ] && command -v flox >/dev/null 2>&1 ; then
  eval "$(flox activate -d ~ -m run)"
fi
export PATH="$HOME/.local/bin:$PATH"
