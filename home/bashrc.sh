# ~/.bashrc: executed by bash(1) for non-login shells.

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# History
HISTCONTROL=ignoreboth
HISTSIZE=-1
HISTFILESIZE=-1
shopt -s histappend
shopt -s checkwinsize

# less: friendlier for non-text input files
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# Colored ls / grep
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# Personal aliases
[ -f ~/.bash_aliases ] && . ~/.bash_aliases

# Programmable completion
if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        . /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        . /etc/bash_completion
    fi
fi

# Fallback prompt, used if starship isn't installed
PS1='\u@\h:\w\$ '

# --- Tool hooks ---
# These assume scripts/bootstrap.sh has already installed everything.
# A missing tool here is a hard error on purpose, not a silent skip.

# mise (runtime version manager: node, npm, ...)
eval "$(mise activate bash)"

# rustup / cargo
. "$HOME/.cargo/env"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Homebrew
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# zoxide (smarter cd)
eval "$(zoxide init bash)"

# fzf
source "$(brew --prefix)/opt/fzf/shell/key-bindings.bash"
source "$(brew --prefix)/opt/fzf/shell/completion.bash"

# starship prompt (overrides the fallback PS1 above)
eval "$(starship init bash)"
