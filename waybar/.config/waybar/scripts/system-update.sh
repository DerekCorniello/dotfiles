#!/usr/bin/env sh
# Runs inside kitty: perform the system update, back up package list, then close.
yay -Syu --noconfirm
flatpak update -y
"$HOME/dotfiles/package-backup/backup-packages.sh"
echo "Done. Press Enter to close..."
read _
pkill -SIGRTMIN+8 waybar
