# dotfiles

Sets up a fresh macOS Tahoe (26.x) Mac for command-line C++ work. README.md is
the user's guide; this file is how Claude runs it.

## When asked to set up this Mac

1. Check the two prerequisites. Both need a person: Claude can't click the
   installer dialog or type a sudo password.
   - `xcode-select -p` succeeds. If not, ask the user to run
     `xcode-select --install`, click Install, and tell you when it's done.
   - Homebrew exists at `/opt/homebrew/bin/brew` (or `/usr/local/bin/brew` on
     Intel). If not, ask the user to run `./bootstrap.sh 02` in a separate
     Terminal window, since it prompts for their password.
2. Tell the user what step 04 will do before running it: it replaces any
   existing `~/.zshrc`, `~/.zprofile`, `~/.vimrc` and `~/.tmux.conf` with links
   into this repo, moving the old files to `~/.dotfiles-backup/<time>/`. On a
   fresh Mac there is nothing to move.
3. Run the remaining steps one at a time, so a failure is easy to place:
   `./bootstrap.sh 01`, then `02`, `03`, `04`, `05`, `06`, `07`. Steps 01 and 02
   only confirm the prerequisites once they're in place.
4. If a step fails, read its output and the script, fix the cause, and re-run
   that step. Every step is safe to repeat. Don't weaken a check in step 07 to
   make it pass.
5. Report the step 07 checks to the user, then tell them to quit Terminal, open
   iTerm2 (now with the Dev profile, bells off) and run `tmux new -s main`.

Notes on specific steps:
- **03** installs the iTerm2 app. If iTerm2 was installed by hand, `brew` stops
  with "It seems there is already an App"; ask the user whether to delete
  `/Applications/iTerm.app` or drop the `cask "iterm2"` line.
- **05** clones a third-party vim plugin. If the permission system blocks it,
  ask the user to run `! ./bootstrap.sh 05` themselves.
- **06** can only make Dev the default profile while iTerm2 is closed. If it
  warns that iTerm2 is running, ask the user to quit iTerm2, then re-run 06.

## Changing this repo

- Scripts run under macOS's bash 3.2: no associative arrays, `mapfile`, or
  `${var,,}`. Check with `bash -n` and run the step.
- Files in `home/` are the user's live config once linked; change them only
  when asked.
- Keep README.md's step table in step with the scripts.
- Plugin and package versions are pinned on purpose; update them only when asked.
