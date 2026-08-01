#!/usr/bin/env bash

# Installs the CLI tools this dotfiles setup depends on.
set -euxo pipefail

is_command() {
    command -v "$1" >/dev/null 2>&1
}

# `mise` (runtime version manager: `node`, `npm`, ...)
if ! is_command mise; then
    curl -fsSL https://mise.run | sh
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
    uv
    bun
    claude
    starship
    zoxide
    ripgrep
    fd
    delta
    gitui
    cargo-binstall
    fzf
    gh
)
mise use -g "${mise_packages[@]}"

# `rustup` (`cargo`, `rustc`)
if ! is_command cargo; then
    curl -fsSL https://sh.rustup.rs | sh -s -- -y
fi
# shellcheck source=/dev/null
. "$HOME/.cargo/env"

# Install via `cargo binstall`, for tools not in `mise`'s registry.
cargo_packages=(
)
for package in "${cargo_packages[@]}"; do
    if ! is_command "$package"; then
        cargo binstall --no-confirm "$package"
    fi
done

# Homebrew.
if ! is_command brew; then
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# Install via `brew`, for tools not in `mise`'s registry.
brew_packages=(
)
for package in "${brew_packages[@]}"; do
    if ! is_command "$package"; then
        brew install "$package"
    fi
done
