#!/usr/bin/env bash
# Installs the CLI tools this dotfiles setup depends on.
set -euo pipefail

log() { printf '\n==> %s\n' "$1"; }

# mise (runtime version manager: node, npm, ...)
log "Installing mise"
curl -fsSL https://mise.run | sh

# uv (Python package/venv manager)
log "Installing uv"
curl -fsSL https://astral.sh/uv/install.sh | sh

# rustup (cargo, rustc)
log "Installing rustup"
curl -fsSL https://sh.rustup.rs | sh -s -- -y
# shellcheck source=/dev/null
. "$HOME/.cargo/env"

# bun
log "Installing bun"
curl -fsSL https://bun.sh/install | bash
export PATH="$HOME/.bun/bin:$PATH"

# Homebrew
log "Installing Homebrew"
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# starship + zoxide, via cargo
for tool in starship zoxide; do
    log "Installing $tool (cargo)"
    cargo install "$tool"
done

# fzf + gh, via brew
for tool in fzf gh; do
    log "Installing $tool (brew)"
    brew install "$tool"
done

log "Bootstrap complete"
