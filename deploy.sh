#!/bin/sh
set -euo pipefail

## emacs

# Backup existing configs if they exist
if [ -e "$HOME/.config/emacs" ] && [ ! -L "$HOME/.config/emacs" ]; then
  mv "$HOME/.config/emacs" "$HOME/.config/emacs.bak"
  echo "Backed up ~/.config/emacs -> ~/.config/emacs.bak"
fi

if [ -e "$HOME/.emacs.d" ]; then
  mv "$HOME/.emacs.d" "$HOME/.emacs.d.bak"
  echo "Backed up ~/.emacs.d -> ~/.emacs.d.bak"
fi

# Ensure ~/.config exists
mkdir -p "$HOME/.config"

# Create symlink
ln -sfn "$HOME/dotfiles/emacs" "$HOME/.config/emacs"

echo "Emacs config deployed."

