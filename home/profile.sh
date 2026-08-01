# `~/.profile`: executed by the command interpreter for login shells.
# This file is not read by `bash` if `~/.bash_profile` or `~/.bash_login` exists.

# Add before `.bashrc` is sourced below, so tools it sets on `$PATH`
# are already there for `bashrc.sh`'s tool-activation hooks.
. ~/.path.sh

# If running `bash`,
if [ -n "$BASH_VERSION" ]; then
    # include `.bashrc` if it exists.
    if [ -f "$HOME/.bashrc" ]; then
        . "$HOME/.bashrc"
    fi
fi
