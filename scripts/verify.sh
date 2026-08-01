#!/usr/bin/env bash

# Verifies every tool `scripts/bootstrap.sh` installs is actually on `$PATH`,
# in both a login shell (`~/.profile` -> `~/.bashrc`)
# and a non-login interactive shell (`~/.bashrc` sourced directly, skipping `~/.profile`),
# each simulated from a clean environment.
set -euo pipefail

commands=(
    mise
    cargo
    rustc
    brew
    uv
    bun
    claude
    starship
    zoxide
    rg
    fd
    delta
    gitui
    cargo-binstall
    fzf
    gh
)

missing=0

check() {
    local flag="$1" label="$2" cmd
    for cmd in "${commands[@]}"; do
        if ! env -i HOME="$HOME" TERM="${TERM:-dumb}" bash "$flag" "command -v $cmd" >/dev/null 2>&1; then
            echo "missing in $label: $cmd" >&2
            missing=1
        fi
    done
}

check -lc "login shell"
check -ic "non-login interactive shell"

if [ "$missing" -ne 0 ]; then
    echo "Some commands aren't on \$PATH. See above." >&2
    exit 1
fi

echo "All commands found in both login and non-login interactive shells."
