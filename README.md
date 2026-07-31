# dotfiles

Personal shell and tool configuration, kept in sync across machines.

## Fresh machine setup

```sh
git clone https://github.com/kkysen/dotfiles.git ~/work/dotfiles
cd ~/work/dotfiles
./install.sh
```

This does two things:

1. `scripts/bootstrap.sh` — installs the CLI tools this config depends on if
   they're missing: mise, uv, rustup, bun, Homebrew, starship, zoxide, fzf, gh.
   Safe to re-run; every step is skipped if already installed.
2. `scripts/link.sh` — symlinks the tracked files into `$HOME`, backing up
   anything already there under `~/.dotfiles-backup/<timestamp>/`.

Then restart your shell (`exec bash`).

## Layout

- `home/` — files that map 1:1 onto `$HOME` (`.bashrc`, `.bash_aliases`, `.gitconfig`)
- `config/` — files that map onto XDG-style config dirs (e.g. `~/.claude/settings.json`)
- `scripts/` — bootstrap and linking logic
