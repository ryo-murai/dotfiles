# .zshrc

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

setopt share_history
setopt inc_append_history

setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_reduce_blanks

# Completion
autoload -U compinit
compinit -u

setopt magic_equal_subst

zstyle ':completion:*:default' menu select

[ -z "$LS_COLORS" ] && {
  LS_COLORS='rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:mi=01;05;37;41:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=34;42:st=37;44:ex=01;32:'
}
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# Prompt
setopt prompt_subst
autoload -Uz add-zsh-hook

typeset -A emoji
emoji[ok]=$'\U2705'
emoji[error]=$'\U274C'
emoji[git]=$'\U1F500'
emoji[git_changed]=$'\U1F37A'
emoji[git_untracked]=$'\U1F363'
emoji[git_clean]=$'\U2728'
emoji[right_arrow]=$'\U2794'

function vcs_git_indicator () {
  typeset -A git_info
  local git_indicator git_status untracked
  git_status=("${(f)$(git status --porcelain --branch 2> /dev/null)}")
  (( $? == 0 )) && {
    git_info[branch]="${${git_status[1]}#\#\# }"
    shift git_status
    git_info[changed]=${#git_status:#\?\?*}
    git_info[untracked]=$(( $#git_status - ${git_info[changed]} ))
    git_info[clean]=$(( $#git_status == 0 ))

    git_indicator=("${emoji[git]}  %{%F{blue}%}${git_info[branch]}%{%f%}")
    (( ${git_info[clean]}     )) && git_indicator+=("${emoji[git_clean]}")
    (( ${git_info[changed]}   )) && git_indicator+=("${emoji[git_changed]}  %{%F{yellow}%}${git_info[changed]} changed%{%f%}")
    (( ${git_info[untracked]} )) && git_indicator+=("${emoji[git_untracked]}  %{%F{red}%}${git_info[untracked]} untracked%{%f%}")
  }
  _vcs_git_indicator="${git_indicator}"
}

add-zsh-hook precmd vcs_git_indicator

function {
  local dir='%{%F{blue}%B%}%~%{%b%f%}'
  local now='%{%F{yellow}%}%D{%b %e %a %R %Z}%{%f%}'
  local rc="%(?,${emoji[ok]} ,${emoji[error]}  %{%F{red}%}%?%{%f%})"
  local user='%{%F{green}%}%n%{%f%}'
  local host='%{%F{green}%}%m%{%f%}'
  [ "$SSH_CLIENT" ] && local via="${${=SSH_CLIENT}[1]} %{%B%}${emoji[right_arrow]}%{%b%} "
  local git='$_vcs_git_indicator'
  local mark=$'\n%# '
  PROMPT="$dir $user($via$host) $rc $git$mark"
  RPROMPT="$now"
}


#
# Environment
#

export EDITOR=vim

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

# Homebrew
[ -x ~/.homebrew/bin/brew ] && {
  export PATH="$HOME/.homebrew/bin:$PATH"
  export LD_LIBRARY_PATH="/usr/lib:$HOME/.homebrew/lib"
}

# Travis CI
[ -f ~/.travis/travis.sh ] && . ~/.travis/travis.sh

# Node.js
[ -f ~/.nvm/nvm.sh ] && . ~/.nvm/nvm.sh

# Ruby
[ -x ~/.rbenv/bin/rbenv ] && {
  export PATH="$HOME/.rbenv/bin:$PATH"
  eval "$(rbenv init -)"
}

whence gem >/dev/null && {
  export GEM_HOME="$(ruby -rubygems -e 'puts Gem.user_dir')"
  export PATH="$GEM_HOME/bin:$PATH"
}

# PostgreSQL
[ -d ~/.pgdata ] && export PGDATA="$HOME/.pgdata"

# Google Cloud Platform
[ -d ~/Library/google-cloud-sdk ] && {
  . ~/Library/google-cloud-sdk/path.zsh.inc
  . ~/Library/google-cloud-sdk/completion.zsh.inc
  export APPENGINE_SDK_HOME="$HOME/Library/google-cloud-sdk/platform/appengine-java-sdk"
  export APPENGINE_HOME="$APPENGINE_SDK_HOME"
}


#
# Aliases and functions
#

case "$(uname)" in
  Linux | CYGWIN*)
    alias ls='ls --color=auto'
    ;;
  Darwin)
    alias ls='ls -G'
    alias mvim=/Applications/MacVim.app/Contents/MacOS/mvim
    ;;
esac

alias ll='ls -la'

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
function without_proxy () {
  http_proxy= https_proxy= "$@"
}

# Select docker machine
function enable_docker_machine () {
  local machine="$1"
  [ -z "$machine" ] && local machine="$(docker-machine ls -q)"
  eval "$(docker-machine env "$machine")"
}

# OS X Terminal App with sudo privileges
function sudo_term () {
  osascript -e 'do shell script "/Applications/Utilities/Terminal.app/Contents/MacOS/Terminal" with administrator privileges'
}

# OS X Notification
function display_notification () {
  osascript -e 'on run argv
    display notification current date as text with title item 1 of argv
  end run' -- "$*"
}

function with_display_notification () {
  "$@"
  display_notification "($?)" "$@"
}


#
# More
#

# Apply environment specific settings if exists
[ -f ~/.zshrc.local ] && . ~/.zshrc.local

# Set final return value to 0 (shown in prompt)
true
