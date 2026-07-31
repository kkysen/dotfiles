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

# uv (Python package/venv manager)
if ! is_command uv; then
    curl -fsSL https://astral.sh/uv/install.sh | sh
fi

# rustup (cargo, rustc)
if ! is_command cargo; then
    curl -fsSL https://sh.rustup.rs | sh -s -- -y
fi
# shellcheck source=/dev/null
. "$HOME/.cargo/env"

# bun
if ! is_command bun; then
    curl -fsSL https://bun.sh/install | bash
fi
export PATH="$HOME/.bun/bin:$PATH"

# Claude Code
if ! is_command claude; then
    curl -fsSL https://claude.ai/install.sh | bash
fi

# Homebrew
if ! is_command brew; then
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# starship, zoxide, ripgrep, fd-find, git-delta, gitui, via cargo-binstall (prebuilt binaries, no compiling)
if ! is_command cargo-quickinstall; then
    cargo install cargo-quickinstall
fi
if ! is_command cargo-binstall; then
    cargo quickinstall cargo-binstall
fi
cargo binstall --no-confirm starship zoxide ripgrep fd-find git-delta gitui

# fzf + gh, via brew
for tool in fzf gh; do
    if ! is_command "$tool"; then
        brew install "$tool"
    fi
done
