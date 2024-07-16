# shellcheck disable=SC2148

eval "$(direnv hook bash)"

# shellcheck disable=SC1091
if [ -n "$BASH_VERSION" ] && ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi
