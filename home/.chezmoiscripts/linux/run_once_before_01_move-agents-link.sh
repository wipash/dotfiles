#!/bin/sh
set -eu

# The Home Repo link used to live at ~/AGENTS.md.
old="$HOME/AGENTS.md"
new="$HOME/.agents/AGENTS.md"

if [ -L "$old" ] && [ ! -e "$new" ] && [ ! -L "$new" ]; then
    mkdir -p "$HOME/.agents"
    mv "$old" "$new"
fi
