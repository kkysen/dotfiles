#!/usr/bin/env bash

# Installs the CLI tools this dotfiles setup depends on.
set -euo pipefail

is_command() {
    command -v "$1" >/dev/null 2>&1
}

is_apt_package_installed() {
    dpkg -s "$1" >/dev/null 2>&1
}

# Install via `apt`, for system packages not available via `mise`/`cargo`/`brew`.
# One package per line, for single-line diffs when adding one.
apt_packages=(
    build-essential
    poppler-utils
    socat # for `claude`'s sandbox
    tree
    unzip
)
for package in "${apt_packages[@]}"; do
    if ! is_apt_package_installed "$package"; then
        set -x
        sudo apt install -y "$package"
        set +x
    fi
done

# `mise` (runtime version manager: `node`, `npm`, ...)
if ! is_command mise; then
    set -x
    curl -fsSL https://mise.run | sh
    set +x
fi
# On a fresh machine, `~/.local/bin` doesn't exist yet,
# since it isn't in `/etc/skel`.
# So `~/.profile`'s `PATH` addition for it never ran at login.
# The line above just created the directory,
# so add it to `PATH` here too.
export PATH="$HOME/.local/bin:$PATH"

# Install via `mise`.
# These are checksummed prebuilt binaries, not the more dangerous `curl | sh`.
mise_packages=(
    atuin
    bat
    bun
    cargo-binstall
    claude
    delta
    dua
    fd
    fzf
    gh
    gitui
    just
    lsd
    ripgrep
    sccache
    sd
    starship
    tokei
    uv
    zoxide
)
set -x
mise use -g "${mise_packages[@]}"
set +x

# Install Rust (`rustup`, `cargo`, `rustc`).
if ! is_command rustup; then
    set -x
    curl -fsSL https://sh.rustup.rs | sh -s -- -y
    set +x
fi
set -x
# shellcheck source=/dev/null
. ~/.cargo/env
set +x

# Install via `cargo binstall`, for tools not in `mise`'s registry.
cargo_packages=(
    exa
    procs
    ruplacer
)
for package in "${cargo_packages[@]}"; do
    if ! is_command "$package"; then
        set -x
        cargo binstall --no-confirm "$package"
        set +x
    fi
done

# Homebrew.
if ! is_command brew; then
    set -x
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    set +x
fi
set -x
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
set +x

# Install via `brew`, for tools not in `mise`'s registry.
brew_packages=(
)
for package in "${brew_packages[@]}"; do
    if ! is_command "$package"; then
        set -x
        brew install "$package"
        set +x
    fi
done

# `gh`
if ! gh auth status >/dev/null 2>&1; then
    set -x
    gh auth login
    set +x
fi

# `atuin`
set -x
atuin login --username khyber
atuin import auto
# These hooks atomically edit files that are symlinked, thus breaking the symlinks.
# But if ran as part of `. install.sh`, then `link.sh` should re-fix them.
atuin hook install claude-code
atuin hook install codex
set +x
