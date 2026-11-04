#!/bin/bash
# Homebrew, from the official installer. It asks for your password once.
set -euo pipefail
source "$(dirname "$0")/lib.sh"

step "Homebrew"

if ! brew_bin >/dev/null; then
    /bin/bash -c "$(curl -fsSL \
        https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
BREW="$(brew_bin)" || die "Homebrew did not install"
eval "$("$BREW" shellenv)"
ok "$(brew --version | head -1) at $(brew --prefix)"
