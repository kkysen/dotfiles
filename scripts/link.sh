#!/usr/bin/env bash

# Symlinks the tracked config files into `$HOME`, backing up anything already there.
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

echo_and_run() {
    echo "$@"
    "$@"
}

link() {
    local src="$DOTFILES_DIR/$1"
    local dest="$HOME/$2"
    if [ "$dest" -ef "$src" ]; then
        # Do nothing if they're the same file already (resolving to the same thing).
        return
    fi
    mkdir -p "$(dirname "$dest")"
    if [ -L "$dest" ]; then
        # Remove any symlink since it's not the same file.
        echo_and_run rm "$dest"
    elif [ -e "$dest" ]; then
        if cmp -s "$dest" "$src"; then
            # If it exists with the same content, just remove it.
            # But re-link so that it's the same file, not just the same content.
            echo_and_run rm "$dest"
        else
            # If it exists with a different content, back it up.
            mkdir -p "$(dirname "$BACKUP_DIR/$2")"
            echo_and_run mv "$dest" "$BACKUP_DIR/$2"
        fi
    fi
    echo_and_run ln -s "$src" "$dest"
}

link home/path.sh .path.sh
link home/functions.sh .functions.sh
link home/profile.sh .profile
# `bash` reads only the first one of
# * `~/.bash_profile`
# * `~/.bash_login`
# * `~/.profile`
# that exists, so link the same file to all three.
# Otherwise a pre-existing (even empty) one of these silently shadows the others
# and none of its setup ever runs.
link home/profile.sh .bash_profile
link home/profile.sh .bash_login
link home/bashrc.sh .bashrc
link home/gitconfig .gitconfig
link config/claude/settings.json .claude/settings.json
link config/claude/CLAUDE.md .claude/CLAUDE.md
link config/claude/statusline-command.sh .claude/statusline-command.sh
link config/starship.toml .config/starship.toml
link config/atuin/config.toml .config/atuin/config.toml
link config/systemd/user/rclone-gdrive.service .config/systemd/user/rclone-gdrive.service

# Make the `gdrive` remote the mount needs, which opens a browser to log into Google.
# Only from a terminal, so CI and other non-interactive runs skip it.
if [ -t 0 ] && ! rclone listremotes | grep -qxF gdrive:; then
    echo_and_run rclone config create gdrive drive scope=drive
fi

# Start the Google Drive mount at login.
# Skipped where there's no systemd user instance (e.g. WSL without `systemd=true`).
if systemctl --user daemon-reload 2>/dev/null; then
    if ! systemctl --user is-enabled --quiet rclone-gdrive.service; then
        echo_and_run systemctl --user enable rclone-gdrive.service
    fi
    # Also (re)tries it after an earlier run skipped it for having no `gdrive` remote yet.
    if ! systemctl --user is-active --quiet rclone-gdrive.service; then
        echo_and_run systemctl --user start rclone-gdrive.service
    fi
fi

# `ccache` masquerade symlinks (see `home/path.sh`).
# They must point at the real `ccache` binary, not its `mise` shim,
# since a shim dispatches on its own name, which here is the compiler's.
# `mise which` resolves through `latest`, so this survives `ccache` upgrades.
ccache_dir="$HOME/.local/lib/ccache"
ccache_bin="$(mise which ccache)"
mkdir -p "$ccache_dir"
# Besides the plain names, also the versioned (`gcc-15`, `clang-24`)
# and target-prefixed (`aarch64-linux-gnu-gcc`) ones that are installed.
# `c89` and `c99` don't need one: they're scripts that run `gcc` from `$PATH`.
compilers=(cc c++ gcc g++ clang clang++)
for path in /usr/bin/{gcc,g++,clang,clang++}-[0-9]* /usr/bin/*-linux-gnu-{gcc,g++} /usr/bin/*-linux-gnu-{gcc,g++}-[0-9]*; do
    if [ -x "$path" ]; then
        compilers+=("$(basename "$path")")
    fi
done
for compiler in "${compilers[@]}"; do
    if [ "$(readlink "$ccache_dir/$compiler" 2>/dev/null)" != "$ccache_bin" ]; then
        echo_and_run ln -sfn "$ccache_bin" "$ccache_dir/$compiler"
    fi
done

if [ -d "$BACKUP_DIR" ]; then
    echo
    echo "Pre-existing files backed up under $BACKUP_DIR"
fi
