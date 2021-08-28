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
if [ "$SPIN" ]; then
  icon=꩜
else
  icon=⌘
fi
PROMPT=$'%(?.%{$(echo $state_color)%}$icon.%F{red}$icon e%?)%f $vcs_info_msg_0_%(!.%F{red}#.%{\x1b[1;38;5;33m%}%%)%{\x1b[0m%} '

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
  if test -d /usr/local/share/chruby; then 
    source /usr/local/share/chruby/chruby.sh
    source /usr/local/share/chruby/auto.sh
  elif test -d /opt/homebrew/share/chruby; then 
    source /opt/homebrew/share/chruby/chruby.sh
    source /opt/homebrew/share/chruby/auto.sh
  fi
fi

if [ -e /Users/duncan/.nix-profile/etc/profile.d/nix.sh ]; then 
  . /Users/duncan/.nix-profile/etc/profile.d/nix.sh 
fi 

if [ $SPIN ]; then
  # on spin, there's a bunch of intersting stuff in /etc/zsh/zshrc.default.inc.zsh 

  alias journalctl="/usr/bin/journalctl --no-hostname"
  alias sc=systemctl
  alias jc=journalctl

  # Simplifies tailing multiple services simultaneously
  # `jctail a b c` is the same as running
  # `journalctl --quiet --follow __SYSTEMD_UNIT=a + _SYSTEMD_UNIT=b + _SYSTEMD_UNIT=c`
  jctail() {
      local services=""
      for service in "$@"; do
          if [ -n "${services}" ]; then
              services="${services} +"
          fi
          services="${services} _SYSTEMD_UNIT=${service}"
      done

      journalctl --quiet --follow ${=services}
  }

  __spin_warned_failures=0
  __spin_warn_failed_first_run=1
  warn_failed_units() {
    if [[ -v SPIN_DISABLE_FAILED_UNITS_WARNING ]]; then
      return
    fi

    nfailed="$(systemctl show | grep -Po "(?<=^NFailedUnits=)(\d+)$")"
    new_failures=$((nfailed - __spin_warned_failures))
    if [[ "${new_failures}" -gt 0 ]]; then
      units=units
      have=have
      if [[ "${new_failures}" -eq 1 ]]; then
        units=unit
        have=has
      fi
      if [[ -v __spin_warn_failed_first_run ]]; then
        >&2 echo "\x1b[1;31m꩜  ${new_failures} ${units} ${have} failed. Run \x1b[1;34mman spin.failed-unit\x1b[1;31m for help.\x1b[0m"
      else
        >&2 echo "\x1b[1;31m꩜  ${new_failures} new failed ${units} (${nfailed} total). Run \x1b[1;34mman spin.failed-unit\x1b[1;31m for help.\x1b[0m"
      fi
    fi
    __spin_warned_failures="${nfailed}"
    unset __spin_warn_failed_first_run
  }

  __spin_previous_state=
  __spin_notify_system_state_first_run=1
  notify_system_state() {
    local state
    state="$(systemctl show | grep -oP '(?<=^SystemState=)(.*)$')"
    case "${state}" in
      initializing|starting)                 state_color="\033[38;5;45m" ;;
      degraded|stopping|maintenance|offline) state_color="\033[1;31m" ;;
      running|unknown|*)                     state_color="\033[38;5;33m" ;;
    esac
    if [[ "${state}" != "${__spin_previous_state}" ]]; then
      if [[ -v __spin_notify_system_state_first_run ]]; then
        case "${state}" in
          running) ;;
          # we will have just printed about the failed unit, so
          # it won't surprise anyone to find out that the system
          # is degraded.
          degraded) ;;
          starting)
            >&2 echo "${state_color}꩜  \x1b[0msystem is still initializing (See \033[1;34msystemctl\x1b[0m)"
            ;;
          *)
            >&2 echo "${state_color}꩜  \x1b[0msystem is in state: ${state_color}${state}\x1b[0m"
            ;;
        esac
      else
        case "${state}" in
          running)
            >&2 echo "${state_color}꩜ \x1b[0m system is up and ${state_color}${state}\x1b[0m"
            ;;
          degraded)
            # TODO: make a `help degraded`
            >&2 echo "${state_color}꩜ \x1b[0m system state changed to ${state_color}${state}\x1b[0m (\x1b[1;34mman spin\x1b[0m for guidance)"
            ;;
          *)
            >&2 echo "${state_color}꩜ \x1b[0m system state changed to ${state_color}${state}\x1b[0m"
            ;;
        esac
      fi
    fi
    __spin_previous_state="${state}"
    unset __spin_notify_system_state_first_run
  }

  precmd_functions+=(warn_failed_units notify_system_state)
fi

[[ -f /opt/dev/sh/chruby/chruby.sh ]] && type chruby >/dev/null 2>&1 || chruby () { source /opt/dev/sh/chruby/chruby.sh; chruby "$@"; }
