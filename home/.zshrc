# Interactive shells. Environment and PATH are in ~/.zprofile.

# ---- Options ---------------------------------------------------------------
setopt NO_BEEP               # no bell from the line editor
setopt INTERACTIVE_COMMENTS  # allow # comments in commands typed at the prompt

# ---- History ---------------------------------------------------------------
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt EXTENDED_HISTORY      # record when each command ran
setopt SHARE_HISTORY         # tmux panes see each other's commands
setopt HIST_IGNORE_DUPS      # skip a command identical to the previous one
setopt HIST_IGNORE_SPACE     # a command typed with a leading space isn't saved
setopt HIST_REDUCE_BLANKS

# ---- Line editing ----------------------------------------------------------
# zsh switches to vi keys when $EDITOR mentions vi; keep the emacs-style
# bindings (Ctrl-A, Ctrl-E, Ctrl-R) that were in use before EDITOR was set.
bindkey -e

# ---- Completion ------------------------------------------------------------
# Loads zsh's own completions (git, tmux, ...) and Homebrew's (brew, ninja,
# rg).
autoload -Uz compinit && compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'  # case-insensitive

# ---- fzf -------------------------------------------------------------------
# Ctrl-R fuzzy history search, Ctrl-T insert a file path, Alt-C cd into a
# directory. Needs a terminal: zsh -i run from a script has none.
if (( $+commands[fzf] )) && [[ -t 0 ]]; then
    source <(fzf --zsh)
fi

# ---- Aliases ---------------------------------------------------------------
# vi runs whichever vim is first on PATH, so it stays in step if vim is
# upgraded.
alias vi=vim
