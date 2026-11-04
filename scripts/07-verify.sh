#!/bin/bash
# Checks the finished setup. Safe to run any time; changes nothing.
set -uo pipefail
source "$(dirname "$0")/lib.sh"

step "Verify"

failures=0
check() {
    local label="$1"
    shift
    if "$@" >/dev/null 2>&1; then
        ok "$label"
    else
        fail "$label"
        failures=$((failures + 1))
    fi
}

scratch="$(mktemp -d)"
trap 'rm -rf "$scratch"' EXIT

for tool in cmake ninja clang-format tmux rg fzf; do
    check "$tool on PATH" command -v "$tool"
done
check "clangd from Command Line Tools" xcrun --find clangd

for src in "$DOTFILES_DIR"/home/.[!.]*; do
    name="$(basename "$src")"
    check "~/$name links to this repo" test "$(readlink "$HOME/$name")" = "$src"
done
check "vim lsp plugin installed" test -d "$HOME/.vim/pack/plugins/start/lsp"

# A clean login shell, as a new iTerm window starts one.
clean_zsh() {
    env -i HOME="$HOME" USER="$USER" TERM=xterm-256color SHELL=/bin/zsh \
        zsh -lic "$1"
}
zsh_errors() {
    [ -z "$(clean_zsh exit 2>&1 >/dev/null)" ]
}
check "zsh starts without errors" zsh_errors
path_unique() {
    local dupes
    dupes="$(clean_zsh 'zsh -lic "print -l \$path"' 2>/dev/null | sort | uniq -d)"
    [ -z "$dupes" ]
}
check "PATH has no duplicates in nested shells" path_unique
check "vi is aliased to vim" clean_zsh 'alias vi'

# vim -es would skip ~/.vimrc, so run vim normally with no terminal.
vim_clean() {
    cat >"$scratch/v.vim" <<EOF
call writefile([&belloff, v:errmsg], '$scratch/v.out')
qa!
EOF
    vim --not-a-term -S "$scratch/v.vim" </dev/null >/dev/null 2>&1
    [ "$(sed -n 1p "$scratch/v.out")" = "all" ] &&
        [ -z "$(sed -n 2p "$scratch/v.out")" ]
}
check "vim loads ~/.vimrc without errors, bells off" vim_clean

tmux_conf() {
    tmux -L dotfiles-verify -f "$HOME/.tmux.conf" new-session -d -s v &&
        [ "$(tmux -L dotfiles-verify show -gv bell-action)" = "none" ]
    local status=$?
    tmux -L dotfiles-verify kill-server 2>/dev/null
    return $status
}
check "tmux loads ~/.tmux.conf, bells off" tmux_conf

echo
if [ "$failures" -eq 0 ]; then
    ok "all checks passed"
else
    die "$failures check(s) failed"
fi
