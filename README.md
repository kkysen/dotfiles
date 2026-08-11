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

1. `scripts/bootstrap.sh` — installs the CLI tools this config depends on
   (see the `commands` array in `scripts/verify.sh` for the full list),
   mostly via `mise`, plus `rustup`/`cargo`, `brew`, and `apt` for the rest.
   Safe to rerun: it skips anything already installed.
   Also installs `pre-commit` and runs `pre-commit install`,
   wiring up this repo's pre-commit hook for the current checkout (see below).
2. `scripts/link.sh` — symlinks the tracked files into `$HOME`,
   backing up anything already there
   under `~/.dotfiles-backup/<timestamp>/`.
3. `scripts/verify.sh` — checks every installed tool is actually on `$PATH`,
   in login interactive, login non-interactive, and non-login interactive shells;
   then lints every tracked `.sh` file (`bash -n` and `shellcheck`),
   the same as CI's `lint.yml` below.

## Pre-commit hook

`.pre-commit-config.yaml` runs `scripts/verify.sh` before every commit in this repo,
catching `$PATH` regressions and lint issues at commit time instead of only in CI.
Since git hooks live under `.git/` and are never transferred by `clone`/`push`/`pull`,
this has to be activated locally on every checkout;
`scripts/bootstrap.sh` does that automatically via `pre-commit install`,
so a fresh clone gets it for free once `install.sh` has run.

## CI

- `.github/workflows/install-test.yml` runs `install.sh` end to end
  on a clean container on every push, so a broken `$PATH` or symlink doesn't go unnoticed.
- `.github/workflows/lint.yml` runs the same `bash -n`/`shellcheck` pass
  as the tail end of `scripts/verify.sh`.

## Layout

- `home/` — files that map 1:1 onto `$HOME` (`.bashrc`, `.gitconfig`, ...)
- `config/` — files that map onto XDG-style config dirs (e.g. `~/.claude/settings.json`)
- `scripts/` — bootstrap, linking, and verification logic
- `.pre-commit-config.yaml` — wires `scripts/verify.sh` up as a pre-commit hook
- `.github/workflows/` — CI, mirroring `install.sh` and `scripts/verify.sh`'s lint pass
