#!/bin/bash
# Vim plugins, as native packages (no plugin manager), pinned to known commits.
# To update one: check out a newer commit in its folder, test it, then copy the
# hash here.
set -euo pipefail
source "$(dirname "$0")/lib.sh"

step "Vim plugins"

# name|url|commit
PLUGINS="
lsp|https://github.com/yegappan/lsp|c741b2f1afb42b9f267824dac4049674908f4a41
"

for entry in $PLUGINS; do
    name="${entry%%|*}"
    rest="${entry#*|}"
    url="${rest%%|*}"
    commit="${rest#*|}"
    dir="$HOME/.vim/pack/plugins/start/$name"

    if [ ! -d "$dir/.git" ]; then
        git clone --quiet "$url" "$dir"
    fi
    if [ "$(git -C "$dir" rev-parse HEAD)" != "$commit" ]; then
        git -C "$dir" fetch --quiet origin
        git -C "$dir" checkout --quiet "$commit"
    fi
    ok "$name at ${commit:0:7}"
done
