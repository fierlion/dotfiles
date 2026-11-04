# Login shells: every new iTerm window and tmux pane. Environment and PATH
# live here, after macOS's /etc/zprofile has run path_helper.

# Keep PATH entries unique. tmux panes inherit PATH and run this file again.
typeset -U path

# Homebrew: /opt/homebrew on Apple silicon, /usr/local on Intel.
for brew in /opt/homebrew/bin/brew /usr/local/bin/brew; do
    if [[ -x $brew ]]; then
        eval "$($brew shellenv)"
        break
    fi
done
unset brew

# (N/) drops a folder that doesn't exist, so a new Mac gets a clean PATH.
path=(
    $HOME/.local/bin(N/)
    $HOME/sdk/go/bin(N/)
    $path
)

export EDITOR=vim
export VISUAL=vim
