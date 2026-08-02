#!/usr/bin/env bash

set -euxo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

./scripts/bootstrap.sh
./scripts/link.sh
./scripts/verify.sh

echo
echo "Done. Run 'exec bash' (or open a new shell) to pick up the changes."
