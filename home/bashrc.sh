# `~/.bashrc`: executed by `bash`(1) for non-login shells.

# `home/functions.sh` exports its functions (`export -f`) specifically so
# they're usable in non-interactive subshells and scripts too, not just here,
# so source it before the interactive-only guard below, unlike everything after it.
. ~/.functions.sh

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

# `less`: friendlier for non-text input files
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# Colored `grep`
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# Personal aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Notify when a long-running command finishes, e.g. `sleep 10; alert`
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Programmable completion
if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        . /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        . /etc/bash_completion
    fi
fi

# Fallback prompt, used if `starship` isn't installed
PS1='\u@\h:\w\$ '

# On WSL, open links in Chrome on the Windows side.
if [ -n "${WSL_DISTRO_NAME:-}" ]; then
    export BROWSER='cmd.exe /c start chrome'
fi

# --- Tool hooks ---
# These assume `scripts/bootstrap.sh` has already installed everything.
# A missing tool here is a hard error on purpose, not a silent skip.

# `~/.profile` sources `~/.path.sh` before sourcing this file,
# but non-login shells (e.g. a new terminal tab, `tmux`) skip `~/.profile` entirely
# and source this file directly, so re-source it here too. `mise` below needs it on `$PATH`.
. "$HOME/.path.sh"

# `mise` (runtime version manager: `node`, `npm`, ...; also manages `uv`, `bun`, `claude`).
eval "$(mise activate bash)"

# `zoxide` (smarter `cd`)
eval "$(zoxide init bash)"

# `fzf`
eval "$(fzf --bash)"

# `starship` prompt (overrides the fallback `PS1` above)
eval "$(starship init bash)"

# `atuin` (shell history search/sync)
# `--disable-up-arrow` because Ctrl + R already does the same,
# and overriding the up arrow gets in the way of a lot of quick uses.
# `--disable-ai` so that typing `?` doesn't launch AI
# while I'm trying to type something else.
eval "$(atuin init bash --disable-up-arrow --disable-ai)"

# Completions
eval "$(bat --completion bash)"
eval "$(rustup completions bash cargo)"
eval "$(delta --generate-completion bash)"
eval "$(dua completions bash)"
eval "$(gh completion -s bash)"
eval "$(just --completions bash)"
eval "$(procs --gen-completion-out bash)"
eval "$(rg --generate complete-bash)"
eval "$(rustup completions bash)"
eval "$(uv generate-shell-completion bash)"
