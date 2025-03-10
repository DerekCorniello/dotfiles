#!/bin/bash

# ensure dir exists
mkdir -p ~/package-backup

# grabs every package
pacman -Qqe > ~/package-backup/pacman-packages.txt
yay -Qqm > ~/package-backup/yay-packages.txt
flatpak list --columns=application > ~/package-backup/flatpak-packages.txt

pkill -SIGRTMIN+8 waybar

echo "Packages backed up successfully."
