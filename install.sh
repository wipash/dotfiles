#!/bin/bash

set -eufo pipefail

echo ""
echo "🤚  This script will setup .dotfiles for you."
read -n 1 -r -s -p $'    Press any key to continue or Ctrl+C to abort...\n\n'

# Detect distro family
distro_id=""
distro_like=""
if [ -r /etc/os-release ]; then
  # shellcheck disable=SC1091
  . /etc/os-release
  distro_id="${ID:-}"
  distro_like="${ID_LIKE:-}"
fi

is_debian_like=false
case " $distro_id $distro_like " in
  *" debian "*|*" ubuntu "*) is_debian_like=true ;;
esac

# Install Homebrew
if ! command -v brew >/dev/null 2>&1; then
  echo '🍺  Installing Homebrew'
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Locate brew (prefer system-wide, fall back to per-user)
brew_bin=""
for candidate in /home/linuxbrew/.linuxbrew/bin/brew "$HOME/.linuxbrew/bin/brew" /opt/homebrew/bin/brew /usr/local/bin/brew; do
  if [ -x "$candidate" ]; then brew_bin="$candidate"; break; fi
done
if [ -z "$brew_bin" ]; then
  echo "❌  Could not locate brew after install" >&2
  exit 1
fi

# Append shellenv to ~/.bashrc once
shellenv_line="eval \"\$($brew_bin shellenv)\""
if ! grep -Fqx "$shellenv_line" "$HOME/.bashrc" 2>/dev/null; then
  printf '\n%s\n' "$shellenv_line" >> "$HOME/.bashrc"
fi
eval "$($brew_bin shellenv)"

# Build toolchain: apt on Debian-likes. On Fedora atomic (Bazzite) these are
# already in the base image. brew's gcc is not installed eagerly — almost every
# formula ships a bottle, and a system gcc is present in both targets.
if $is_debian_like; then
  sudo apt-get update
  sudo apt-get install -y build-essential procps curl file git
fi

# Install fish via brew (works on every supported distro)
if ! command -v fish >/dev/null 2>&1; then
  echo '🐟  Installing fish'
  brew install fish
fi

fish_bin="$(command -v fish)"

# Ensure fish is in /etc/shells
if ! grep -qxF "$fish_bin" /etc/shells; then
  echo '🐟  Adding fish to /etc/shells'
  echo "$fish_bin" | sudo tee -a /etc/shells
fi

# Set fish as default shell (chsh isn't on Bazzite; fall back to usermod)
if [ "$(getent passwd "$USER" | cut -d: -f7)" != "$fish_bin" ]; then
  echo '🐟  Setting fish as default shell'
  if command -v chsh >/dev/null 2>&1; then
    sudo chsh -s "$fish_bin" "$USER"
  else
    sudo usermod -s "$fish_bin" "$USER"
  fi
fi

# Install chezmoi
command -v chezmoi >/dev/null 2>&1 || \
  (echo '👊  Installing chezmoi' && brew install chezmoi)

# If this script lives inside a chezmoi source repo (i.e. you cloned the repo
# and ran ./install.sh from it), point chezmoi at that clone instead of cloning
# from the remote. Lets you iterate on changes without pushing first.
script_dir="$(cd "$(dirname "$0")" && pwd)"
if [ -f "$script_dir/.chezmoiroot" ] && [ ! -e "$HOME/.local/share/chezmoi" ]; then
  mkdir -p "$HOME/.local/share"
  ln -s "$script_dir" "$HOME/.local/share/chezmoi"
  echo "🔗  Linked ~/.local/share/chezmoi -> $script_dir"
fi

if [ -e "$HOME/.local/share/chezmoi" ]; then
  echo "🚸  chezmoi source present — initializing config and applying"
  chezmoi init --apply
else
  echo "🚀  Initializing and applying dotfiles from remote"
  chezmoi init --apply https://github.com/wipash/dotfiles.git
fi

echo ""
echo "Done."
