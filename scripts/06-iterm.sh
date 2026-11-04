#!/bin/bash
# iTerm2: installs the "Dev" profile (bells off) and makes it the default.
# Dev inherits everything else from iTerm's own Default profile.
set -euo pipefail
source "$(dirname "$0")/lib.sh"

step "iTerm2 profile"

profiles="$HOME/Library/Application Support/iTerm2/DynamicProfiles"
guid="$(sed -n 's/.*"Guid": *"\([^"]*\)".*/\1/p' "$DOTFILES_DIR/iterm/dev.json")"

mkdir -p "$profiles"
cp "$DOTFILES_DIR/iterm/dev.json" "$profiles/dev.json"
ok "Dev profile installed"

# iTerm writes its preferences when it quits, which would undo this change.
# (pgrep can miss the app; ask macOS directly. This doesn't launch it.)
running="$(osascript -e 'application id "com.googlecode.iterm2" is running')"
if [ "$running" = "true" ]; then
    warn "iTerm2 is running. To make Dev the default, quit iTerm2 and"
    warn "re-run this step from Terminal.app:  ./bootstrap.sh 06"
else
    defaults write com.googlecode.iterm2 "Default Bookmark Guid" -string "$guid"
    ok "Dev is the default profile"
fi
