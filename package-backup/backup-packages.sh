#!/bin/bash

# ensure dir exists
mkdir -p ~/package-backup

# grabs every package
pacman -Qqe > ~/dotfiles/package-backup/pacman-packages.txt
yay -Qqm > ~/dotfiles/package-backup/yay-packages.txt
flatpak list --columns=application > ~/dotfiles/package-backup/flatpak-packages.txt

echo "Packages backed up successfully."
