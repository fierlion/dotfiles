#!/bin/bash
# Command-line tools and iTerm2, from the Brewfile.
set -euo pipefail
source "$(dirname "$0")/lib.sh"

step "Packages (Brewfile)"

command -v brew >/dev/null || die "Homebrew missing; run step 02 first"
if brew bundle check --file "$DOTFILES_DIR/Brewfile" >/dev/null 2>&1; then
    ok "everything in the Brewfile is installed"
else
    brew bundle install --file "$DOTFILES_DIR/Brewfile"
    ok "Brewfile installed"
fi
