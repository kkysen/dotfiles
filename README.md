# dotfiles

Personal shell and tool configuration, kept in sync across machines.

## Fresh machine setup

```sh
git clone https://github.com/kkysen/dotfiles.git
. ./dotfiles/install.sh
```

`install.sh` must be sourced (`. ./install.sh`), not executed (`./install.sh`),
so it can `. ~/.bashrc` in your current shell at the end
instead of telling you to open a new one.
Always include the `./`: a bare `. install.sh` makes `source` search `$PATH`
first, and a `mise` shim named `install.sh` (from a tool that happens
to bundle its own `install.sh`) can shadow the real one.

This does three things:

1. `scripts/bootstrap.sh` — installs the CLI tools
   this config depends on: `mise`, `uv`, `rustup`, `bun`, `claude`,
   `brew`, `starship`, `zoxide`, `fzf`, `gh`, `delta`, and `gitui`.
   Safe to rerun: it skips anything already installed.
2. `scripts/link.sh` — symlinks the tracked files into `$HOME`,
   backing up anything already there
   under `~/.dotfiles-backup/<timestamp>/`.
3. `scripts/verify.sh` — checks every installed tool is actually on `$PATH`,
   in both a login shell and a non-login interactive shell.

## Layout

- `home/` — files that map 1:1 onto `$HOME` (`.bashrc`, `.gitconfig`)
- `config/` — files that map onto XDG-style config dirs (e.g. `~/.claude/settings.json`)
- `scripts/` — bootstrap and linking logic
