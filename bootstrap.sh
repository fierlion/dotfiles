#!/bin/bash
# Sets up a fresh Mac. Every step is safe to re-run.
#
#   ./bootstrap.sh          run every step in order
#   ./bootstrap.sh 04 07    run only the steps you name
set -euo pipefail
cd "$(dirname "$0")"

if [ "$#" -eq 0 ]; then
    steps=(scripts/[0-9][0-9]-*.sh)
else
    steps=()
    for n in "$@"; do
        match=(scripts/"$n"-*.sh)
        [ -e "${match[0]}" ] || { echo "no step $n" >&2; exit 1; }
        steps+=("${match[0]}")
    done
fi

for s in "${steps[@]}"; do
    bash "$s"
done

if [ "$#" -eq 0 ]; then
    printf '\nDone. Quit and reopen iTerm2 so it picks up the Dev profile.\n'
fi
