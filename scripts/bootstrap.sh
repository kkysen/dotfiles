#!/usr/bin/env bash

# Installs the CLI tools this dotfiles setup depends on.
set -euo pipefail

is_command() {
    command -v "$1" >/dev/null 2>&1
}

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
    bun
    cargo-binstall
    claude
    delta
    fd
    fzf
    gh
    gitui
    ripgrep
    starship
    uv
    zoxide
)
set -x
mise use -g "${mise_packages[@]}"
set +x

# `rustup` (`cargo`, `rustc`)
if ! is_command cargo; then
    set -x
    curl -fsSL https://sh.rustup.rs | sh -s -- -y
    set +x
fi

set -x
# shellcheck source=/dev/null
. "$HOME/.cargo/env"
set +x

# Install via `cargo binstall`, for tools not in `mise`'s registry.
cargo_packages=(
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
