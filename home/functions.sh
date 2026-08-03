# Functions
#
# `export -f` each one so it's usable in subshells, too
# (e.g. `bash -c '...'`, scripts), not just this interactive shell:
# a plain function definition is local to the shell that defines it,
# but `bash`'s environment (which subshells inherit) can carry functions, too,
# if exported explicitly.

rc() {
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
