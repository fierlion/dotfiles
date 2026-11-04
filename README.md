# dotfiles

Dotfile setup for tmux, vim and the standard C++ toolchain on macOS Tahoe
(26.x): iTerm2 and tmux, vim with clangd, CMake and Ninja, with every bell
switched off.

## Fresh Mac, with Claude Code

Do this in **Terminal.app**, not iTerm2: step 06 configures iTerm2, and that
only works while iTerm2 is closed. Steps 1 to 3 need you; Claude can't click
installer dialogs or type your password.

1. **Install Apple's Command Line Tools.** A dialog opens; click **Install**
   and wait for it to finish. This gives you `git`, `clang` and `clangd`.

       xcode-select --install

2. **Clone this repo.**

       git clone https://github.com/fierlion/dotfiles.git ~/Projects/dotfiles
       cd ~/Projects/dotfiles

3. **Install Homebrew.** It asks for your password.

       ./bootstrap.sh 02

4. **Install Claude Code and log in.** It needs a Pro, Max, Team or
   Enterprise plan. `claude` opens your browser to log in, then asks whether
   to trust this folder.

       curl -fsSL https://claude.ai/install.sh | bash
       export PATH="$HOME/.local/bin:$PATH"   # until step 04 links .zprofile
       claude

5. **Ask Claude:**

   > Set up this Mac by following the README.

   Claude reads `CLAUDE.md`, runs steps 01 to 07 one at a time, and asks you
   to approve each command. It explains step 04 before it replaces any
   dotfiles.

6. Quit Terminal, open iTerm2, and run `tmux new -s main`.

## Fresh Mac, without Claude

Do steps 1 and 2 above, then run everything from Terminal.app:

    ./bootstrap.sh

Then quit Terminal, open iTerm2, and run `tmux new -s main`.

## What each step does

Every step checks before it changes anything, so re-running is safe.
Run a single step with `./bootstrap.sh 04`, or several with `./bootstrap.sh 04 07`.

| Step | Script | Does |
| --- | --- | --- |
| 01 | `command-line-tools.sh` | Installs Apple's Command Line Tools if missing: clang, clangd, lldb, git. The full Xcode app isn't needed. |
| 02 | `homebrew.sh` | Installs Homebrew with the official installer if missing. |
| 03 | `packages.sh` | `brew bundle` from the `Brewfile`: cmake, ninja, clang-format, tmux, ripgrep, fzf, iTerm2. |
| 04 | `link.sh` | Symlinks each file in `home/` into `~`. Existing files go to `~/.dotfiles-backup/<time>/`. |
| 05 | `vim-plugins.sh` | Clones vim plugins at pinned commits into `~/.vim/pack/plugins/start/`. |
| 06 | `iterm.sh` | Installs the iTerm2 **Dev** profile (bells off, everything else inherited from Default) and makes it the default. |
| 07 | `verify.sh` | Checks the result: tools on PATH, links, a clean zsh start, PATH without duplicates, vim and tmux configs loading with bells off. |

## What you get

| File | Highlights |
| --- | --- |
| `home/.zprofile` | Homebrew on PATH, unique PATH entries in nested tmux shells, `EDITOR=vim` |
| `home/.zshrc` | No bell, 50k shared history, completion, fzf on Ctrl-R / Ctrl-T, `vi` = `vim` |
| `home/.vimrc` | clangd via LSP, build and test keys, clang-format, fzf, ripgrep; leader is Space |
| `home/.tmux.conf` | 24-bit colour, no Esc delay, vi copy mode, `\|` and `-` splits, no bells |

Vim keys, with the leader on Space:

| Keys | Action |
| --- | --- |
| `Space b` | Build with CMake; errors go to the quickfix list (`]q` / `[q`) |
| `Space t` / `Space T` | Build and run this exercise's tests (all, or the name under the cursor) in the tmux pane beside vim |
| `Space d` | Build and start lldb with a breakpoint on the cursor line |
| `Space p` / `Space g` | Fuzzy-find a file / search the word under the cursor |
| `Space f`, `gcc` | Format with clang-format / toggle a comment |
| `gd`, `K`, `gr`, `]d` / `[d` | Definition, hover, references, next / previous diagnostic (clangd) |
| `Space k` | Look up the word under the cursor on cppreference.com |

## Changing things

The files in `~` are links into this repo, so edit either and commit here.
To add a Homebrew package, add a line to the `Brewfile` and run `./bootstrap.sh 03`.
To update a vim plugin, check out a newer commit in its folder under
`~/.vim/pack/plugins/start/`, test it, and copy the hash into
`scripts/05-vim-plugins.sh`.

## Undoing it

Delete the links in `~` and move your old files back from
`~/.dotfiles-backup/<time>/`. Remove the iTerm2 profile by deleting
`~/Library/Application Support/iTerm2/DynamicProfiles/dev.json`.

## If something goes wrong

- **Dev isn't the default iTerm2 profile.** iTerm2 was open during step 06, and
  it saves its own settings when it quits. Quit iTerm2, then run
  `./bootstrap.sh 06` from Terminal.app. Or choose Settings > Profiles > Dev >
  Other Actions > Set as Default.
- **Step 03 fails on iTerm2 with "It seems there is already an App".** iTerm2
  was installed by hand. Either delete `/Applications/iTerm.app` and re-run, or
  remove the `cask "iterm2"` line.
- **A vim LSP mapping reports an unknown command.** The pinned plugin commit
  changed its command names. Run `:help lsp` in vim to find the new name.
