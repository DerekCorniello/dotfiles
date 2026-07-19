#!/usr/bin/env sh
# Runs inside kitty: perform the system update, back up package list, then close.
fail=0

yay -Syu --noconfirm || { echo "!! yay failed" >&2; fail=1; }
flatpak update -y || { echo "!! flatpak failed" >&2; fail=1; }

if [ "$fail" -eq 0 ]; then
    "$HOME/dotfiles/package-backup/backup-packages.sh"
    count=$("$HOME/.config/waybar/scripts/pacman-count.sh" --wait)
    pkill -SIGRTMIN+8 waybar
    echo "Done ($count updates remaining). Press Enter to close..."
else
    echo "Updates failed — see above. Press Enter to close..."
fi
read _
