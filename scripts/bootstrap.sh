#!/usr/bin/env bash

# Installs the CLI tools this dotfiles setup depends on.
set -euxo pipefail

is_command() {
    command -v "$1" >/dev/null 2>&1
}

# mise (runtime version manager: node, npm, ...)
if ! is_command mise; then
    curl -fsSL https://mise.run | sh
fi
# On a fresh machine, `~/.local/bin` doesn't exist yet,
# since it isn't in `/etc/skel`.
# So `~/.profile`'s `PATH` addition for it never ran at login.
# The line above just created the directory,
# so add it to `PATH` here too.
export PATH="$HOME/.local/bin:$PATH"

# uv, bun, claude, starship, zoxide, ripgrep, fd, git-delta, and
# gitui, via mise (checksummed prebuilt binaries, not curl | sh
# or a cargo build).
#
# cargo-binstall is included too, kept installed for ad hoc
# `cargo binstall <tool>` use later, for tools not in mise's registry.
mise use -g uv bun claude starship zoxide ripgrep fd delta gitui cargo-binstall

# rustup (cargo, rustc)
if ! is_command cargo; then
    curl -fsSL https://sh.rustup.rs | sh -s -- -y
fi
# shellcheck source=/dev/null
. "$HOME/.cargo/env"

# Homebrew
if ! is_command brew; then
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# fzf + gh, via brew
for tool in fzf gh; do
    if ! is_command "$tool"; then
        brew install "$tool"
    fi
done
