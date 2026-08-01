# `$PATH` / environment setup shared between `~/.profile` and `~/.bashrc`,
# so each tool's setup lives in exactly one place even though both files need it.

mkdir -p ~/.local/bin
export PATH="$HOME/.local/bin:$PATH"

# `mise` shims: makes tools `mise` manages (`bun`, `uv`, `starship`, etc.)
# available immediately, without needing an interactive prompt
# to trigger `mise activate`'s lazy `$PATH` hook.
# `mise` itself recommends this for non-interactive shells and scripts,
# since `mise activate` "doesn't work well for non-interactive situations like scripts":
# <https://mise.jdx.dev/dev-tools/shims.html>
export PATH="$HOME/.local/share/mise/shims:$PATH"

# `rustup` / `cargo`
. ~/.cargo/env

# Homebrew
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
