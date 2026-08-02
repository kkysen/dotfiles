#!/usr/bin/env bash

# Verifies every tool `scripts/bootstrap.sh` installs is actually on `$PATH`,
# in both a login shell (`~/.profile` -> `~/.bashrc`)
# and a non-login interactive shell (`~/.bashrc` sourced directly, skipping `~/.profile`),
# each simulated from a clean environment.
set -euo pipefail

commands=(
    brew
    bun
    cargo
    cargo-binstall
    claude
    delta
    fd
    fzf
    gh
    gitui
    mise
    rg
    rustc
    rustup
    starship
    uv
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
