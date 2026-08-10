#!/usr/bin/env bash

# Check that every tool `scripts/bootstrap.sh` installs is actually on `$PATH`,
# in login and non-login interactive and non-interactive shells:
# * login, interactive: `~/.profile` -> `~/.bashrc`
# * login, non-interactive: `~/.profile`
# * non-login, interactive: `~/.bashrc`
#
# The fourth combination, non-login non-interactive
# (plain `bash -c`, e.g. cron, `ssh host cmd`),
# is intentionally not checked: it sources neither `~/.profile` nor `~/.bashrc` at all,
# by design, so nothing installed by `mise`/`cargo`/`rustup`/`brew`
# is ever reachable there regardless of what this script installs.
# Only `$BASH_ENV` could change that, and that
# has its own tradeoffs on every non-interactive invocation,
# not something to take on just to make this combination pass.
#
# Then check the syntax of every tracked `.sh` file (`bash -n`)
# and lint them (`shellcheck`), the same as CI's `lint.yml`.
set -euo pipefail

# `apt.llvm.org` packages are all suffixed with the same dev-branch major
# version `scripts/bootstrap.sh` resolves dynamically,
# so resolve it the same way here, rather than hardcoding one that'll go stale.
llvm_version="$(apt-cache search '^clang-[0-9]+$' | sed -E 's/^clang-([0-9]+).*/\1/' | sort -n | tail -1)"

commands=(
    atuin
    bat
    brew
    bun
    cargo
    cargo-binstall
    ccache
    "clang++-$llvm_version"
    "clang-$llvm_version"
    "clang-check-$llvm_version"
    "clang-format-$llvm_version"
    "clang-tidy-$llvm_version"
    claude
    delta
    dua
    exa
    fd
    fzf
    g++
    gcc
    gh
    gitui
    hyperfine
    just
    "lld-$llvm_version"
    "lldb-$llvm_version"
    "llvm-config-$llvm_version"
    ls
    lsd
    make
    mise
    mold
    path
    pdfimages
    pdftotext
    pre-commit
    procs
    python
    python3
    rc
    rg
    ruplacer
    rustc
    rustup
    sccache
    sd
    shellcheck
    socat
    starship
    tokei
    tree
    unzip
    usage
    uv
    wild
    zenith
    zig
    zoxide
)

missing=0

check() {
    local flag="$1"
    local label="$2"
    local cmd
    local not_found
    # shellcheck disable=SC2016 # intentional: this expands inside the spawned `bash`, not here.
    not_found="$(env -i HOME="$HOME" TERM="${TERM:-dumb}" bash "$flag" '
        for cmd in "$@"; do
            command -v "$cmd" >/dev/null 2>&1 || echo "$cmd"
        done
    ' bash "${commands[@]}" 2>/dev/null)"
    if [ -n "$not_found" ]; then
        while IFS= read -r cmd; do
            echo "missing in $label: $cmd" >&2
        done <<<"$not_found"
        missing=1
    fi
}

check -lc "login non-interactive shell"
check -lic "login interactive shell"
check -ic "non-login interactive shell"

if [ "$missing" -ne 0 ]; then
    echo "Some commands aren't on \$PATH. See above." >&2
    exit 1
fi

echo "All commands found in every checked shell."

# Same checks as CI's `lint.yml`.
git ls-files '*.sh' | xargs -n1 bash -n
git ls-files '*.sh' | xargs shellcheck
