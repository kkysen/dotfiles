#!/usr/bin/env bash
# Symlinks the tracked config files into $HOME, backing up anything already there.
set -euxo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

link() {
    local src="$DOTFILES_DIR/$1" dest="$HOME/$2"
    mkdir -p "$(dirname "$dest")"
    if [ -L "$dest" ]; then
        rm "$dest"
    elif [ -e "$dest" ]; then
        mkdir -p "$(dirname "$BACKUP_DIR/$2")"
        mv "$dest" "$BACKUP_DIR/$2"
        echo "Backed up $dest -> $BACKUP_DIR/$2"
    fi
    ln -s "$src" "$dest"
    echo "Linked $dest -> $src"
}

link home/bashrc.sh .bashrc
link home/bash_aliases.sh .bash_aliases
link home/gitconfig .gitconfig
link config/claude/settings.json .claude/settings.json

if [ -d "$BACKUP_DIR" ]; then
    echo
    echo "Pre-existing files backed up under $BACKUP_DIR"
fi
