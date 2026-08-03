#!/usr/bin/env bash

# Verifies every tool `scripts/bootstrap.sh` installs is actually on `$PATH`,
# in both a login shell (`~/.profile` -> `~/.bashrc`)
# and a non-login interactive shell (`~/.bashrc` sourced directly, skipping `~/.profile`),
# each simulated from a clean environment.
set -euo pipefail

# `apt.llvm.org` packages are all suffixed with the same dev-branch major
# version `scripts/bootstrap.sh` resolves dynamically, so resolve it the
# same way here, rather than hardcoding one that'll go stale.
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
    just
    "lld-$llvm_version"
    "lldb-$llvm_version"
    "llvm-config-$llvm_version"
    lsd
    make
    mise
    pdfimages
    pdftotext
    procs
    rg
    ruplacer
    rustc
    rustup
    sccache
    sd
    socat
    starship
    tokei
    tree
    unzip
    uv
    zig
    zoxide
)

missing=0

check() {
    local flag="$1"
    local label="$2"
    local cmd
    local not_found
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

check -lc "login shell"
check -ic "non-login interactive shell"

if [ "$missing" -ne 0 ]; then
    echo "Some commands aren't on \$PATH. See above." >&2
    exit 1
fi

echo "All commands found in both login and non-login interactive shells."
