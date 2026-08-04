# shellcheck shell=bash
# `~/.profile`: executed by the command interpreter for login shells.
# This file is not read by `bash` if `~/.bash_profile` or `~/.bash_login` exists.

# Add before `.bashrc` is sourced below, so tools it sets on `$PATH`
# are already there for `bashrc.sh`'s tool-activation hooks.
# shellcheck source=home/path.sh
. ~/.path.sh

# If running `bash`,
if [ -n "$BASH_VERSION" ]; then
    # include `.bashrc` if it exists.
    if [ -f ~/.bashrc ]; then
        # shellcheck source=home/bashrc.sh
        . ~/.bashrc
    fi
fi
