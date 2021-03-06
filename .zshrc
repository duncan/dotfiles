autoload -Uz vcs_info
precmd_functions+=( vcs_info )
setopt PROMPT_SUBST
setopt AUTO_CD
setopt NO_BEEP
setopt COMPLETE_IN_WORD
setopt APPEND_HISTORY
setopt PROMPT_SP
setopt AUTO_PUSHD
unsetopt MULTIOS
autoload -U compinit && compinit
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
autoload -Uz vcs_info
precmd_functions+=( vcs_info )

zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git:*' formats $'%F{blue}%b%F{yellow}%m%{\x1b[0m%} '
zstyle ':vcs_info:git:*' actionformats $'%F{blue}%b%F{grey}%u%c %F{grey}[%F{yellow}%a %m%F{grey}]%{\x1b[0m%} '

state_color="\033[38;5;33m"

 
icon=⌘


PROMPT='%(?.%F{green}$icon.%F{red}$icon)%f %F{yellow}%~%f $vcs_info_msg_0_%F{yellow}▶︎%f '

typeset -U path

if test -f /usr/local/bin/code; then
  export VISUAL=code
fi

if test -d /opt/homebrew/bin; then 
  export PATH=/opt/homebrew/bin:$PATH
fi

if test -d $HOME/.cargo/bin; then
  export PATH=$HOME/.cargo/bin:$PATH
fi

export PATH=$HOME/bin:$PATH

if test -f /opt/dev/dev.sh; then
  source /opt/dev/dev.sh
else
  if test -d /opt/homebrew/share/chruby; then 
    source /opt/homebrew/share/chruby/chruby.sh
    source /opt/homebrew/share/chruby/auto.sh
  elif test -d /usr/local/share/chruby/chruby; then
    source /usr/local/share/chruby/chruby.sh
    source /usr/local/share/chruby/auto.sh
  fi
fi

if [ -e /Users/duncan/.nix-profile/etc/profile.d/nix.sh ]; then 
  . /Users/duncan/.nix-profile/etc/profile.d/nix.sh 
fi 
