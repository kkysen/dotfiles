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
# Each is guarded so a missing tool never breaks the shell.

# mise (runtime version manager: node, npm, ...)
command -v mise >/dev/null 2>&1 && eval "$(mise activate bash)"

# rustup / cargo
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

# bun
export BUN_INSTALL="$HOME/.bun"
[ -d "$BUN_INSTALL/bin" ] && export PATH="$BUN_INSTALL/bin:$PATH"

# Homebrew (Linuxbrew on Linux, /opt/homebrew or /usr/local on macOS)
for brew_bin in /home/linuxbrew/.linuxbrew/bin/brew /opt/homebrew/bin/brew /usr/local/bin/brew; do
    if [ -x "$brew_bin" ]; then
        eval "$("$brew_bin" shellenv)"
        break
    fi
done
unset brew_bin

# zoxide (smarter cd)
command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init bash)"

# fzf
[ -f ~/.fzf.bash ] && . ~/.fzf.bash

# starship prompt (overrides the fallback PS1 above)
command -v starship >/dev/null 2>&1 && eval "$(starship init bash)"
