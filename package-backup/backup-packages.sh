#!/bin/bash

# ensure dir exists
mkdir -p ~/package-backup

# grabs every package
pacman -Qqe > ~/package-backup/pacman-packages.txt
yay -Qqm > ~/package-backup/yay-packages.txt
flatpak list --columns=application > ~/package-backup/flatpak-packages.txt

echo "Packages backed up successfully."
