![Arch Linux](https://img.shields.io/badge/Arch%20Linux-1f76b3?style=for-the-badge&logo=archlinux)
![Last Commit](https://img.shields.io/github/last-commit/DerekCorniello/dotfiles?style=for-the-badge)

# Dotfiles for Arch Linux

This repository contains my personal dotfiles and configurations for a customized Arch Linux setup. These files are intended to help me set up my development environment quickly and easily.

## Included Configurations

- **`gitconfig`**: Configuration for Git, including my preferred aliases and settings.
- **`hypr`**: Configuration for the Hyprland Wayland compositor.
- **`kitty`**: Configuration for the Kitty terminal UI.
- **`nvim`**: Neovim configuration with my plugin setup and custom keybindings (also check out [my NeoVim setup](https://www.github.com/DerekCorniello/NeoVim-Setup).
- **`tmux`**: Configuration for tmux with my preferred panes, windows, and keybindings.
- **`waybar`**: Configuration for Waybar to display system information on my Wayland desktop.
- **`zshrc`**: Zsh configuration with Oh My Zsh and my preferred plugins and themes.

## Installation

To install these dotfiles on your system, you can clone the repository and symlink the files into your home directory.

### Steps:

1. Clone the repository:

   ```bash
   git clone https://github.com/yourusername/dotfiles.git
   cd dotfiles
   ```

2. Symlink the configuration files to your home directory:

   ```bash
   stow gitconfig
   stow hypr
   stow kitty
   stow nvim
   stow tmux
   stow waybar
   stow zshrc
   ```

   > **Note**: This assumes you have [GNU Stow](https://www.gnu.org/software/stow/) installed. If you don't, you can manually copy the files into your home directory or use another symlink manager.

3. Install required dependencies (if not already installed):

   - Hyprland (hyprlock, hypridle, hyprpaper, hyprland)
   - Kitty
   - Neovim
   - tmux
   - Waybar
   - Zsh and Oh My Zsh

## Customizing

Feel free to modify the configurations to fit your needs. Each file is modular and can be edited independently.

## Connect with Me!
[![LinkedIn](https://img.shields.io/badge/LinkedIn-%230A66C2.svg?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/derek-corniello)
[![GitHub](https://img.shields.io/badge/GitHub-%23121011.svg?style=for-the-badge&logo=github&logoColor=white)](https://github.com/derekcorniello)
[![X](https://img.shields.io/badge/X-%231DA1F2.svg?style=for-the-badge&logo=x&logoColor=white)](https://x.com/derekcorniello)
