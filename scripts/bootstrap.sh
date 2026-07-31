#!/usr/bin/env bash

# Installs the CLI tools this dotfiles setup depends on.
set -euxo pipefail

# mise (runtime version manager: node, npm, ...)
curl -fsSL https://mise.run | sh

# uv (Python package/venv manager)
curl -fsSL https://astral.sh/uv/install.sh | sh

# rustup (cargo, rustc)
curl -fsSL https://sh.rustup.rs | sh -s -- -y
# shellcheck source=/dev/null
. "$HOME/.cargo/env"

# bun
curl -fsSL https://bun.sh/install | bash
export PATH="$HOME/.bun/bin:$PATH"

# Homebrew
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# starship + zoxide, via cargo-binstall (prebuilt binaries, no compiling)
cargo install cargo-quickinstall
cargo quickinstall cargo-binstall
cargo binstall --no-confirm starship zoxide

# fzf + gh, via brew
for tool in fzf gh; do
    brew install "$tool"
done
