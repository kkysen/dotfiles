# shellcheck shell=sh
# `$PATH` / environment setup shared between `~/.profile` and `~/.bashrc`,
# so each tool's setup lives in exactly one place even though both files need it.

# Both files source this, and this itself gets re-sourced on every `. ~/.bashrc`
# or new non-login shell, but none of the exports below check whether they're
# already on `$PATH` before prepending again, so re-sourcing without this guard
# duplicates every entry once per re-source.
if [ -n "${__DOTFILES_PATH_SH_SOURCED:-}" ]; then
    return
fi
export __DOTFILES_PATH_SH_SOURCED=1

# Do this in reverse order of `$PATH` order.

mkdir -p ~/.local/bin
export PATH="$HOME/.local/bin:$PATH"

# Homebrew
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# `rustup` / `cargo`
# shellcheck source=/dev/null
. ~/.cargo/env

# `mise` shims: makes tools `mise` manages (`bun`, `uv`, `starship`, etc.)
# available immediately, without needing an interactive prompt
# to trigger `mise activate`'s lazy `$PATH` hook.
# `mise` itself recommends this for non-interactive shells and scripts,
# since `mise activate` "doesn't work well for non-interactive situations like scripts":
# <https://mise.jdx.dev/dev-tools/shims.html>
export PATH="$HOME/.local/share/mise/shims:$PATH"
