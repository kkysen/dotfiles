# shellcheck shell=sh
# `$PATH` / environment setup shared between `~/.profile` and `~/.bashrc`,
# so each tool's setup lives in exactly one place even though both files need it.

# Both files source this, and this itself gets re-sourced on every `. ~/.bashrc`
# or new non-login shell. It always re-runs in full, so changes to it take effect
# on re-source, and the duplicate `$PATH` entries that re-prepending creates
# are removed at the end.

# Do this in reverse order of `$PATH` order.

mkdir -p ~/.local/bin
export PATH="$HOME/.local/bin:$PATH"

# Homebrew
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# `rustup` / `cargo`: what `~/.cargo/env` does, except that it skips prepending
# when already on `$PATH`, which would leave it out of order on a re-source.
export PATH="$HOME/.cargo/bin:$PATH"

# LLVM: `apt.llvm.org` installs only version-suffixed names (`clang-24`) into `/usr/bin`,
# so several versions can coexist; the unversioned ones (`clang`, `ld.lld`, `llvm-ar`, ...)
# are in `/usr/lib/llvm-<version>/bin`. Put the newest version's on `$PATH`.
llvm_bin="$(printf '%s\n' /usr/lib/llvm-*/bin | sort -V | tail -n 1)"
if [ -d "$llvm_bin" ]; then
    export PATH="$llvm_bin:$PATH"
fi
unset llvm_bin

# `ccache` in front of the C/C++ compilers, via `ccache`'s masquerade mode:
# `scripts/link.sh` makes symlinks named `clang`, `cc`, ... to the real `ccache` here,
# which then runs the next compiler of that name on `$PATH` (e.g. LLVM's above) and caches it.
# Must come before the LLVM directory on `$PATH`, so after it here.
export PATH="$HOME/.local/lib/ccache:$PATH"

# `mise` shims: makes tools `mise` manages (`bun`, `uv`, `starship`, etc.)
# available immediately, without needing an interactive prompt
# to trigger `mise activate`'s lazy `$PATH` hook.
# `mise` itself recommends this for non-interactive shells and scripts,
# since `mise activate` "doesn't work well for non-interactive situations like scripts":
# <https://mise.jdx.dev/dev-tools/shims.html>
export PATH="$HOME/.local/share/mise/shims:$PATH"

# Remove duplicate `$PATH` entries, keeping each one's first occurrence.
# Everything above prepends, so on a re-source the fresh entries come first
# and this leaves `$PATH` in the same order as a first source.
PATH="$(printf '%s' "$PATH" | awk -v RS=: -v ORS=: '!seen[$0]++' | sed 's/:$//')"
export PATH
