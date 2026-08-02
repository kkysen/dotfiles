#!/usr/bin/env bash

# Sourced (`. install.sh`), not executed, so it can `. ~/.bashrc`
# in your current shell afterward instead of telling you to open a new one.

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
    echo "Run this with '. install.sh', not './install.sh'," >&2
    echo "so it can update your current shell instead of a subprocess's." >&2
    return 1 2>/dev/null || exit 1
fi

if ! (
    set -euxo pipefail
    cd "$(dirname "${BASH_SOURCE[0]}")"
    ./scripts/bootstrap.sh
    ./scripts/link.sh
    ./scripts/verify.sh
); then
    return 1
fi

. ~/.bashrc
