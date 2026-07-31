#!/usr/bin/env bash

# Installs the CLI tools this dotfiles setup depends on.
set -euxo pipefail

# mise (runtime version manager: node, npm, ...)
if ! command -v mise >/dev/null 2>&1; then
    curl -fsSL https://mise.run | sh
fi

# uv (Python package/venv manager)
if ! command -v uv >/dev/null 2>&1; then
    curl -fsSL https://astral.sh/uv/install.sh | sh
fi

# rustup (cargo, rustc)
if ! command -v cargo >/dev/null 2>&1; then
    curl -fsSL https://sh.rustup.rs | sh -s -- -y
fi
# shellcheck source=/dev/null
. "$HOME/.cargo/env"

# bun
if ! command -v bun >/dev/null 2>&1; then
    curl -fsSL https://bun.sh/install | bash
fi
export PATH="$HOME/.bun/bin:$PATH"

# Claude Code
if ! command -v claude >/dev/null 2>&1; then
    curl -fsSL https://claude.ai/install.sh | bash
fi

# Homebrew
if ! command -v brew >/dev/null 2>&1; then
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# starship, zoxide, ripgrep, fd-find, git-delta, gitui, via cargo-binstall (prebuilt binaries, no compiling)
if ! command -v cargo-binstall >/dev/null 2>&1; then
    cargo install cargo-quickinstall
    cargo quickinstall cargo-binstall
fi
cargo binstall --no-confirm starship zoxide ripgrep fd-find git-delta gitui

# fzf + gh, via brew
for tool in fzf gh; do
    if ! command -v "$tool" >/dev/null 2>&1; then
        brew install "$tool"
    fi
done
