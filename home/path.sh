# `$PATH` / environment setup shared between `~/.profile` and `~/.bashrc`,
# so each tool's setup lives in exactly one place even though both files need it.

mkdir -p ~/.local/bin
export PATH="$HOME/.local/bin:$PATH"

# `rustup` / `cargo`
. ~/.cargo/env

# Homebrew
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
