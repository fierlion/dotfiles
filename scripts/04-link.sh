#!/bin/bash
# Symlinks every file in home/ into $HOME, so edits are tracked in this repo.
# An existing file that isn't already our link is moved to a backup folder.
set -euo pipefail
source "$(dirname "$0")/lib.sh"

step "Dotfiles"

backup="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
for src in "$DOTFILES_DIR"/home/.[!.]*; do
    name="$(basename "$src")"
    dest="$HOME/$name"
    if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
        ok "$name already linked"
        continue
    fi
    if [ -e "$dest" ] || [ -L "$dest" ]; then
        mkdir -p "$backup"
        mv "$dest" "$backup/"
        warn "$name existed; moved to $backup/"
    fi
    ln -s "$src" "$dest"
    ok "$name -> $src"
done
