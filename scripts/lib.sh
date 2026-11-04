# Shared helpers, sourced by every step. Written for macOS's bash 3.2.

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export DOTFILES_DIR

step() { printf '\n\033[1;34m==> %s\033[0m\n' "$*"; }
ok()   { printf '\033[32m  ok\033[0m  %s\n' "$*"; }
warn() { printf '\033[33mwarn\033[0m  %s\n' "$*"; }
fail() { printf '\033[31mfail\033[0m  %s\n' "$*"; }
die()  { fail "$*"; exit 1; }

# Homebrew lives in /opt/homebrew on Apple silicon, /usr/local on Intel.
brew_bin() {
    local b
    for b in /opt/homebrew/bin/brew /usr/local/bin/brew; do
        if [ -x "$b" ]; then
            echo "$b"
            return 0
        fi
    done
    return 1
}

# Later steps run in fresh processes, so put brew on PATH whenever it exists.
if BREW="$(brew_bin)"; then
    eval "$("$BREW" shellenv)"
fi
