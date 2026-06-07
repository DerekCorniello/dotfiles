#!/bin/bash

# ensure dir exists
mkdir -p ~/dotfiles/package-backup

# grabs every package
pacman -Qqe > ~/dotfiles/package-backup/pacman-packages.txt
yay -Qqm > ~/dotfiles/package-backup/yay-packages.txt
flatpak list --columns=application > ~/dotfiles/package-backup/flatpak-packages.txt
hyprpm list 2>&1 | sed 's/\x1b\[[0-9;]*m//g' > ~/dotfiles/package-backup/hyprpm-plugins.txt

echo "Packages backed up successfully."
