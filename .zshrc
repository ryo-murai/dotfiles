# .zshrc

#
# zsh settings
#
bindkey -e

bindkey ";5C" forward-word
bindkey ";5D" backward-word

HISTFILE=~/.zhistory
HISTSIZE=10000
SAVEHIST=10000

function set_prompt () {
  local dir='%F{blue}%B%~%b%f'
  local now='%F{yellow}%T%f'
  local rc='%F{white}=> %(?,%F{white},%F{red})%?%f'
  if [[ -z "$SSH_CLIENT" ]]; then
    local host='%F{green}%n%F{white}(%F{green}%m%F{white})%f'
  else
    local host="%F{green}%n%F{white}(%F{green}%m %F{white}<- %B${${=SSH_CLIENT}[1]}%b%F{white})%f"
  fi
  PROMPT="$now $dir $host $rc"$'\n%# '
}
set_prompt

autoload -U compinit
compinit -u

setopt magic_equal_subst

#
# Environment and aliases
#
export EDITOR=vim

case "$(uname)" in
  Linux | CYGWIN*)
    alias ls='ls --color=auto'
    ;;

  Darwin)
    alias ls='ls -G'
    ;;
esac

alias ll='ls -la'

#
# Functions
#

# Enable ssh agent forwarding if socket exists
function setup_ssh_auth_sock () {
  local agent="$1"
  if [ -S "$agent" ]; then
    export SSH_AUTH_SOCK="$agent"
  elif [ ! -S "$SSH_AUTH_SOCK" ]; then
    export SSH_AUTH_SOCK="$agent"
  elif [ ! -L "$SSH_AUTH_SOCK" ]; then
    ln -snf "$SSH_AUTH_SOCK" "$agent" && export SSH_AUTH_SOCK="$agent"
  fi
}
setup_ssh_auth_sock "$HOME/.ssh/.agent-$(hostname)"


# Enable the proxy settings.
function enable_proxy () {
  local port="$1"
  local host="$2"
  [ -z "$port" ] && port='9090'
  [ -z "$host" ] && host='127.0.0.1'

  export http_proxy="http://$host:$port/"
  export https_proxy="$http_proxy"
  export GRADLE_OPTS="-Dhttp.proxyHost=$host -Dhttp.proxyPort=$port"
}
