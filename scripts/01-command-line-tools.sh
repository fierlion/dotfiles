#!/bin/bash
# Apple's Command Line Tools: clang, clang++, clangd, lldb, git, make.
# The full Xcode app is not needed.
set -euo pipefail
source "$(dirname "$0")/lib.sh"

step "Command Line Tools"

if ! xcode-select -p >/dev/null 2>&1; then
    echo "  A macOS dialog will ask to install the tools. Click Install."
    xcode-select --install || true
    until xcode-select -p >/dev/null 2>&1; do
        sleep 10
    done
fi
ok "developer directory: $(xcode-select -p)"

for tool in clang++ clangd lldb git; do
    xcrun --find "$tool" >/dev/null 2>&1 || die "$tool not found by xcrun"
done
ok "clang++, clangd, lldb, git"
