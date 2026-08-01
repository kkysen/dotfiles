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
    mkdir -p "$(dirname "$dest")"
    if [ -L "$dest" ]; then
        echo_and_run rm "$dest"
    elif [ -e "$dest" ]; then
        if cmp -s "$dest" "$src"; then
            echo_and_run rm "$dest"
        else
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
link config/starship.toml .config/starship.toml

if [ -d "$BACKUP_DIR" ]; then
    echo
    echo "Pre-existing files backed up under $BACKUP_DIR"
fi
