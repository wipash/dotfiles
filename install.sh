#!/bin/bash

set -eufo pipefail

echo ""
echo "🤚  This script will setup .dotfiles for you."
read -n 1 -r -s -p $'    Press any key to continue or Ctrl+C to abort...\n\n'


# Install Homebrew
command -v brew >/dev/null 2>&1 || \
  (echo '🍺  Installing Homebrew' && /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" && \
  (echo; echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"') >> /home/sean/.bashrc && \
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)" && \
  sudo apt-get update && sudo apt-get install -y build-essential procps curl file git && \
  brew install gcc)

if ! command -v fish >/dev/null 2>&1; then
  echo '🐟  Installing fish'
  sudo add-apt-repository ppa:fish-shell/release-4 -y
  sudo apt-get -y install fish
fi

# Ensure fish is in /etc/shells
if ! grep -qx '/usr/bin/fish' /etc/shells; then
  echo '🐟  Adding fish to /etc/shells'
  echo '/usr/bin/fish' | sudo tee -a /etc/shells
fi

# Set fish as default shell
if [ "$SHELL" != '/usr/bin/fish' ]; then
  echo '🐟  Setting fish as default shell'
  sudo chsh -s /usr/bin/fish "$USER"
fi

# Install chezmoi
command -v chezmoi >/dev/null 2>&1 || \
  (echo '👊  Installing chezmoi' && brew install chezmoi)

if [ -d "$HOME/.local/share/chezmoi/.git" ]; then
  echo "🚸  chezmoi already initialized"
  echo "    Reinitialize with: 'chezmoi init https://github.com/wipash/dotfiles.git'"
else
  echo "🚀  Initialize dotfiles with:"
  echo "    chezmoi init https://github.com/wipash/dotfiles.git"
fi

echo ""
echo "Done."
