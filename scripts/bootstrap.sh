#!/usr/bin/env bash
# Installs the CLI tools this dotfiles setup depends on.
# Idempotent: every step is skipped if the tool is already installed.
set -euo pipefail

log() { printf '\n==> %s\n' "$1"; }

# mise (runtime version manager: node, npm, ...)
if ! command -v mise >/dev/null 2>&1; then
    log "Installing mise"
    curl -fsSL https://mise.run | sh
fi

# uv (Python package/venv manager)
if ! command -v uv >/dev/null 2>&1; then
    log "Installing uv"
    curl -fsSL https://astral.sh/uv/install.sh | sh
fi

# rustup (cargo, rustc)
if ! command -v cargo >/dev/null 2>&1; then
    log "Installing rustup"
    curl -fsSL https://sh.rustup.rs | sh -s -- -y
fi
# shellcheck source=/dev/null
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

# bun
if ! command -v bun >/dev/null 2>&1; then
    log "Installing bun"
    curl -fsSL https://bun.sh/install | bash
    export PATH="$HOME/.bun/bin:$PATH"
fi

# Homebrew (Linuxbrew on Linux, /opt/homebrew or /usr/local on macOS)
if ! command -v brew >/dev/null 2>&1; then
    log "Installing Homebrew"
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    for brew_bin in /home/linuxbrew/.linuxbrew/bin/brew /opt/homebrew/bin/brew /usr/local/bin/brew; do
        if [ -x "$brew_bin" ]; then
            eval "$("$brew_bin" shellenv)"
            break
        fi
    done
fi

# starship + zoxide, built via cargo
for tool in starship zoxide; do
    if ! command -v "$tool" >/dev/null 2>&1; then
        log "Installing $tool (cargo)"
        cargo install "$tool"
    fi
done

# fzf + gh, via brew
for tool in fzf gh; do
    if ! command -v "$tool" >/dev/null 2>&1; then
        log "Installing $tool (brew)"
        brew install "$tool"
    fi
done

log "Bootstrap complete"
