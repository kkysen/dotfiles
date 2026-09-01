# Global instructions

## Claude Attribution

You must attribute every commit you make to yourself,
no matter how the commit was made, whether through
`git commit -m`, `git commit -F`, or any other way.
You must use a `Co-authored-by:` line at the bottom of each commit.
Note that `Co-authored-by:` is lowercase.
No need for any `Claude-Session:`.

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

Never write a commit message inline on the command line
(`git commit -m "..."` or `git commit -m "$(cat <<'EOF' ... EOF)"`),
even correctly quoted. Composing it as a shell argument
is what causes the backtick-escaping mistake in the first place:
writing `` \` `` is correct in some shell-quoting contexts
(e.g. inside a double-quoted `-m "..."`) and wrong in others
(inside a single-quoted heredoc, where nothing is interpreted so `` \` `` comes through literally).
The two look nearly identical at the point of typing, which is exactly how this keeps happening.

Instead, write the message with the `Write` tool to a scratch file
(e.g. `$TMPDIR/commit-msg.txt`), exactly as it should read, no shell
escaping of any kind since `Write` isn't a shell context at all,
then run `git commit -F <path>` (or `--amend -F <path>`).
This isn't just "be more careful": it removes the shell-quoting step
that caused the mistake, six times in one session, entirely.

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

## Git

Never run `git push` (or push a new branch/tag) unless the user
explicitly asks for it in that specific instance, across all projects.
Committing locally is fine (unless requested not to);
pushing is a separate, always-explicit step,
even right after creating/pushing a repo earlier in the same session.
