# Global instructions

## Prose formatting

Apply this to all prose you write that is monospace and not line-wrapped,
in every project—commit messages, markdown files, code comments—not just commit messages:

- Use semantic line breaks: break at natural clause/sentence boundaries, not at a fixed column width.
  Never re-wrap an unchanged paragraph just because a nearby line changed;
  keep unaffected line breaks exactly where they were, so diffs stay minimal.
- Backtick every file name, path, command, and program name mentioned in prose
  (e.g. `~/.bashrc`, `mise`, `scripts/bootstrap.sh`).
  Do this on a full pass over the whole message, including the first line/subject,
  not just the parts that already look code-ish.
- Don't backtick a proper-noun product name when talking about the product/company itself
  (e.g. "on GitHub", "uses Homebrew"). Only the literal command/file token gets backticks.
- When you do use an em dash, don't put spaces around it: `word—word`, not `word — word`.
- Shell/env variables get their sigil in prose too: `` `$PATH` ``, not `` `PATH` ``.

This has been missed repeatedly specifically on commit messages,
including right after drafting one correctly moments earlier for a different message.
Before running `git commit`, re-read the exact message being passed and check it
against both rules above, as its own step, not just when writing prose elsewhere.

## Code style

Never use em dashes in code: this includes comments, string literals,
and commit messages, not just prose written directly to the user.
Use a colon, comma, semicolon, or a second sentence instead, whichever fits.

### Bash

Declare one variable per `local` line, not `local a=1 b=2` on one line.
`local a=1 b=2` masks failures: `local`'s own exit status wins,
so a failing command substitution in `b`'s value goes undetected. One per line
also keeps diffs minimal when a single variable is added, removed, or changed.

When running commands to find/search things,
use `rg` instead of `grep`, and `fd` instead of `find`.
