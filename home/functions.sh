# shellcheck shell=bash
# Functions
#
# `export -f` each one so it's usable in subshells, too
# (e.g. `bash -c '...'`, scripts), not just this interactive shell:
# a plain function definition is local to the shell that defines it,
# but `bash`'s environment (which subshells inherit) can carry functions, too,
# if exported explicitly.

rc() {
    # shellcheck source=home/bashrc.sh
    . ~/.bashrc
}

export -f rc

path() {
    echo "$PATH" | tr ':' '\n'
}

export -f path

ls() {
    exa "$@"
}

export -f ls

# Run Claude Code, and everything it starts, inside `claude.slice`,
# so they all share one memory cap (`~/.config/systemd/user/claude.slice`)
# and the kernel kills the biggest job instead of WSL running out of memory.
claude() {
    systemd-run --user --scope --quiet --collect --slice=claude.slice claude "$@"
}

export -f claude
