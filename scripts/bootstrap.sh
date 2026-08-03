#!/usr/bin/env bash

# Installs the CLI tools this dotfiles setup depends on.
set -euo pipefail

is_command() {
    command -v "$1" >/dev/null 2>&1
}

is_apt_package_installed() {
    dpkg -s "$1" >/dev/null 2>&1
}

# LLVM/Clang dev-branch builds from https://apt.llvm.org/,
# since Ubuntu's own repo only carries the last two stable LLVM branches, not the dev branch.
llvm_apt_list=/etc/apt/sources.list.d/apt.llvm.org.list
if [ ! -f "$llvm_apt_list" ]; then
    set -x
    wget -qO- https://apt.llvm.org/llvm-snapshot.gpg.key | sudo tee /etc/apt/trusted.gpg.d/apt.llvm.org.asc
    echo "deb http://apt.llvm.org/$(lsb_release -cs)/ llvm-toolchain-$(lsb_release -cs) main" |
        sudo tee "$llvm_apt_list"
    sudo apt update
    set +x
fi
# `apt.llvm.org` only ever publishes major-version-suffixed packages
# (`clang-23`, not `clang`), so find whichever major version is newest,
# rather than hardcoding one that'll go stale as the dev branch advances.
llvm_version="$(apt-cache search '^clang-[0-9]+$' | sed -E 's/^clang-([0-9]+).*/\1/' | sort -n | tail -1)"

# Install via `apt`, for system packages not available via `mise`/`cargo`/`brew`.
# One package per line, for single-line diffs when adding one.
apt_packages=(
    build-essential
    "clang-$llvm_version"
    "clang-format-$llvm_version"
    "clang-tidy-$llvm_version"
    "clang-tools-$llvm_version"
    "lld-$llvm_version"
    "lldb-$llvm_version"
    "llvm-$llvm_version"
    poppler-utils
    socat # for `claude`'s sandbox
    tree
    unzip
)
for package in "${apt_packages[@]}"; do
    if ! is_apt_package_installed "$package"; then
        set -x
        sudo apt install -y "$package"
        set +x
    fi
done

# `mise` (runtime version manager: `node`, `npm`, ...)
if ! is_command mise; then
    set -x
    curl -fsSL https://mise.run | sh
    set +x
fi
# On a fresh machine, `~/.local/bin` doesn't exist yet,
# since it isn't in `/etc/skel`.
# So `~/.profile`'s `PATH` addition for it never ran at login.
# The line above just created the directory,
# so add it to `PATH` here too.
export PATH="$HOME/.local/bin:$PATH"

# Install via `mise`.
# These are checksummed prebuilt binaries, not the more dangerous `curl | sh`.
mise_packages=(
    atuin
    bat
    bun
    cargo-binstall
    ccache
    claude
    delta
    dua
    fd
    fzf
    gh
    gitui
    just
    lsd
    mold
    ripgrep
    sccache
    sd
    starship
    tokei
    uv
    zig
    zoxide
    # `wild` isn't a `mise` registry alias, but its generic `github` backend
    # works ad hoc for any repo with releases, the same way `ccache` uses
    # `github:ccache/ccache` above. The GitHub repo moved to
    # `wild-linker/wild`; crates.io's `wild` is an unrelated, older,
    # non-binary crate (the actual crate is `wild-linker`).
    github:wild-linker/wild
)
set -x
mise use -g "${mise_packages[@]}"
set +x

# Latest Python, via `uv` (not `mise`, which only manages `uv` itself here).
set -x
uv python install --default --upgrade
set +x

# Install Rust (`rustup`, `cargo`, `rustc`).
if ! is_command rustup; then
    set -x
    curl -fsSL https://sh.rustup.rs | sh -s -- -y
    set +x
fi
set -x
# shellcheck source=/dev/null
. ~/.cargo/env
set +x

# Install via `cargo binstall`, for tools not in `mise`'s registry.
# `package` or `package:binary`, for when the installed binary's name
# differs from the crate name (e.g. `some-crate:some-binary`).
cargo_packages=(
    exa
    procs
    ruplacer
)
for entry in "${cargo_packages[@]}"; do
    package="${entry%%:*}"
    binary="${entry#*:}"
    if ! is_command "$binary"; then
        set -x
        cargo binstall --no-confirm "$package"
        set +x
    fi
done

# Homebrew.
if ! is_command brew; then
    set -x
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    set +x
fi
set -x
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
set +x

# Install via `brew`, for tools not in `mise`'s registry.
brew_packages=(
)
for package in "${brew_packages[@]}"; do
    if ! is_command "$package"; then
        set -x
        brew install "$package"
        set +x
    fi
done

# `gh`
if ! gh auth status >/dev/null 2>&1; then
    set -x
    gh auth login
    set +x
fi

# `atuin`
set -x
atuin login --username khyber
atuin import auto
# These hooks atomically edit files that are symlinked, thus breaking the symlinks.
# But if ran as part of `. install.sh`, then `link.sh` should re-fix them.
atuin hook install claude-code
atuin hook install codex
set +x
