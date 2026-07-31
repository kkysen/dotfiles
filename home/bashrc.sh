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
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Notify when a long-running command finishes, e.g.: sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

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

# On WSL, open links in Chrome on the Windows side.
if [ -n "${WSL_DISTRO_NAME:-}" ]; then
    export BROWSER='cmd.exe /c start chrome'
fi

# --- Tool hooks ---
# These assume scripts/bootstrap.sh has already installed everything.
# A missing tool here is a hard error on purpose, not a silent skip.

# mise (runtime version manager: node, npm, ...; also manages uv, bun, claude)
eval "$(mise activate bash)"

# rustup / cargo
. "$HOME/.cargo/env"

# Homebrew
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# zoxide (smarter cd)
eval "$(zoxide init bash)"

# fzf
eval "$(fzf --bash)"

# starship prompt (overrides the fallback PS1 above)
eval "$(starship init bash)"
