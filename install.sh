#!/usr/bin/env bash

# Sourced (`. ./install.sh`), not executed, so it can `. ~/.bashrc`
# in your current shell afterward instead of telling you to open a new one.
# Always include the `./`: a bare `. install.sh` makes `source` search `$PATH`
# first, and a `mise` shim named `install.sh` can shadow the real one.

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
    echo "Run this with '. ./install.sh', not './install.sh'," >&2
    echo "so it can update your current shell instead of a subprocess's." >&2
    # shellcheck disable=SC2317 # not unreachable: `return` fails when this is run instead of sourced, falling through to `exit`.
    return 1 2>/dev/null || exit 1
fi

# A subshell tested directly by `if !`/`||` suspends `set -e` for its whole
# body, no matter what's set inside it, so a failing `bootstrap.sh` wouldn't
# stop this from continuing to `link.sh`/`verify.sh` anyway. Run it
# untested, capture its real exit status, then check that separately.
(
    set -euo pipefail
    cd "$(dirname "${BASH_SOURCE[0]}")"

    set -x
    ./scripts/bootstrap.sh
    ./scripts/link.sh
    ./scripts/verify.sh
    set +x
)
status=$?
if [ "$status" -ne 0 ]; then
    return 1
fi

# shellcheck source=home/bashrc.sh
. ~/.bashrc
