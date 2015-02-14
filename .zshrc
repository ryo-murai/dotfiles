# .zshrc

#
# Environment and aliases
#
export EDITOR=vim

alias ll='ls -la'

case "$(uname)" in
  Linux | CYGWIN*)
    alias ls='ls --color=auto'
    ;;

  Darwin)
    alias ls='ls -G'

    export LS_COLORS='rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:mi=01;05;37;41:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=34;42:st=37;44:ex=01;32:'
    ;;
esac

# Enable ssh agent forwarding if socket exists
function {
  local agent="$HOME/.ssh/.agent-$(hostname)"
  if [ -S "$agent" ]; then
    export SSH_AUTH_SOCK="$agent"
  elif [ ! -S "$SSH_AUTH_SOCK" ]; then
    export SSH_AUTH_SOCK="$agent"
  elif [ ! -L "$SSH_AUTH_SOCK" ]; then
    ln -snf "$SSH_AUTH_SOCK" "$agent" && export SSH_AUTH_SOCK="$agent"
  fi
}


#
# Functions
#

# tmux: attach or create session
function t () {
  tmux has-session 2> /dev/null && tmux attach || tmux
}

# Enable proxy settings (call in ~/.zshrc.local)
function enable_proxy () {
  local port="$1"
  local host="$2"
  [ -z "$port" ] && port='9090'
  [ -z "$host" ] && host='127.0.0.1'

  export http_proxy="http://$host:$port/"
  export https_proxy="$http_proxy"
  export JAVA_OPTS="-Dhttp.proxyHost=$host -Dhttp.proxyPort=$port -Dhttps.proxyHost=$host -Dhttps.proxyPort=$port"
}

# Prefix for command without proxy
function without_proxy() {
  http_proxy= https_proxy= "$@"
}

# Docker: enter into the container
function docker-enter () {
  local container="$1"
  if [ -z "$container" ]; then
    echo "Usage: $0 CONTAINER [COMMAND ARGS...]"
    echo
    docker ps
    return 1
  fi
  shift
  sudo nsenter -m -u -i -n -p -t "$(docker inspect --format {{.State.Pid}} "$container")" "$@"
}

# OS X Terminal App with sudo privileges
function sudo-term () {
  osascript -e 'do shell script "/Applications/Utilities/Terminal.app/Contents/MacOS/Terminal" with administrator privileges'
}


#
# General settings
#

# Key bindings
bindkey -e

# ctrl+arrow
# - iterm
bindkey '^[[1;5A' history-beginning-search-backward
bindkey '^[[1;5B' history-beginning-search-forward
bindkey '^[[1;5D' backward-word
bindkey '^[[1;5C' forward-word
# - iterm-linux-tmux
bindkey '^[OA' history-beginning-search-backward
bindkey '^[OB' history-beginning-search-forward
bindkey '^[OD' backward-word
bindkey '^[OC' forward-word

# alt+arrow
# - iterm
# - iterm-linux-tmux
#bindkey '^[^[[A'
#bindkey '^[^[[B'
bindkey '^[^[[D' beginning-of-line
bindkey '^[^[[C' end-of-line

# pageup, pagedown
# - putty
bindkey "^[[5~" history-beginning-search-backward
bindkey "^[[6~" history-beginning-search-forward


# History
HISTFILE=~/.zhistory
HISTSIZE=10000
SAVEHIST=10000

# Completion
autoload -U compinit
compinit -u

setopt magic_equal_subst

zstyle ':completion:*:default' menu select
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# Prompt
autoload vcs_info
precmd () { vcs_info }
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:*' formats       '%F{white}-> %F{green}%b%f'
zstyle ':vcs_info:*' actionformats '%F{white}-> %F{green}%b%F{white}:%F{green}%a%f'

setopt prompt_subst
setopt transient_rprompt

function {
  local dir='%F{blue}%B%~%b%f'
  local now='%F{yellow}%T%f'
  local rc='%F{white}=> %(?,%F{white},%F{red})%?%f'
  if [[ -z "$SSH_CLIENT" ]]; then
    local host='%F{green}%n%F{white}(%F{green}%m%F{white})%f'
  else
    local host="%F{green}%n%F{white}(%F{green}%m %F{white}<- %B${${=SSH_CLIENT}[1]}%b%F{white})%f"
  fi
  PROMPT="$now $dir $host"$' $vcs_info_msg_0_\n%# '
  RPROMPT="$rc"
}


#
# More
#

# Enable nvm if exists
[ -f ~/.nvm/nvm.sh ] && . ~/.nvm/nvm.sh

# Add homebrew to path if exists
[ -x ~/.homebrew/bin/brew ] && PATH="$HOME/.homebrew/bin:$PATH"

# Add rubygems to path if exists
if which ruby >/dev/null && which gem >/dev/null; then
  export GEM_HOME="$(ruby -rubygems -e 'puts Gem.user_dir')"
  export PATH="$GEM_HOME/bin:$PATH"
fi

# added by travis gem
[ -f ~/.travis/travis.sh ] && source ~/.travis/travis.sh


# Apply environment specific settings if exists
[ -f ~/.zshrc.local ] && . ~/.zshrc.local

# Set final return value to 0 (shown in prompt)
true
