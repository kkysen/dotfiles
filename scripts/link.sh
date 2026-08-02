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
link home/profile.sh .profile
link home/bashrc.sh .bashrc
link home/gitconfig .gitconfig
link config/claude/settings.json .claude/settings.json
link config/claude/CLAUDE.md .claude/CLAUDE.md
link config/starship.toml .config/starship.toml
link config/atuin/config.toml .config/atuin/config.toml

if [ -d "$BACKUP_DIR" ]; then
    echo
    echo "Pre-existing files backed up under $BACKUP_DIR"
fi
