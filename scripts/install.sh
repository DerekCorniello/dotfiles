#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status

DOTFILES_REPO="https://github.com/DerekCorniello/dotfiles.git"
DOTFILES_DIR="$HOME/dotfiles"

if [[ $EUID -eq 0 ]]; then
    echo "Please run this script as a normal user, not root."
    exit 1
fi

echo "Installing essential packages..."
sudo pacman -Sy --needed git stow flatpak

if [ ! -d "$DOTFILES_DIR" ]; then
    echo "Cloning dotfiles repository..."
    git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
else
    echo "Dotfiles repository already exists, pulling latest changes..."
    cd "$DOTFILES_DIR" && git pull
fi

cd "$DOTFILES_DIR"

if ! command -v yay &>/dev/null; then
    echo "Installing yay..."
    git clone https://aur.archlinux.org/yay-bin.git
    cd yay-bin
    makepkg -si --noconfirm
    cd ..
    rm -rf yay-bin
fi

echo "Installing packages from package-backup..."
if [ -f package-backup/pacman-packages.txt ]; then
    xargs --no-run-if-empty -a package-backup/pacman-packages.txt sudo pacman -S --needed --noconfirm
fi

if [ -f package-backup/yay-packages.txt ]; then
    xargs --no-run-if-empty -a package-backup/yay-packages.txt yay -S --needed --noconfirm
fi

if [ -f package-backup/flatpak-packages.txt ]; then
    xargs --no-run-if-empty -a package-backup/flatpak-packages.txt flatpak install --latest -y
fi

echo "Ensuring critical packages are installed..."
sudo pacman -S --needed --noconfirm networkmanager blueman

echo "Stowing dotfiles..."
stow */

echo "Setup complete! Please restart your session."
