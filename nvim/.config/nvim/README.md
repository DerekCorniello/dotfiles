![Neovim](https://img.shields.io/badge/neovim-%2357A143.svg?style=for-the-badge&logo=neovim&logoColor=white)

# Neovim Setup Documentation

## Introduction

This document outlines the configuration and plugins used in my Neovim setup.

Updated as of NeoVim 10.1

## Neovim Configuration

### 1. General Settings

- Relative Line Numbers
- Tab size of 4 spaces
- Auto-indent
- Folding

### 2. Plugin Management

Plugins are managed using [lazy.nvim, by folke](https://github.com/folke/lazy.nvim).

Some of the plugins used:
- Visuals: [OneDark, by navarasu](https://github.com/navarasu/onedark.nvim), [treesitter](https://github.com/nvim-treesitter/nvim-treesitter) and [lualine](https://github.com/nvim-lualine/lualine.nvim)
- LSP: [Mason, by williamboman](https://github.com/williamboman/mason.nvim)
- Completion: [CMP, by hrsh7th](https://github.com/hrsh7th/nvim-cmp)
- File Browsing: [Harpoon, by thePrimeagen](https://github.com/ThePrimeagen/harpoon/tree/harpoon2) and [telescope](https://github.com/nvim-telescope/telescope.nvim)
- Git: [Gitsigns, by lewis6991](https://github.com/lewis6991/gitsigns.nvim) and [fugitive, by tpope](https://github.com/tpope/vim-fugitive)
- [UndoTree](https://github.com/mbbill/undotree): Keeps track of your undo history in tree form.
- [Lualine](https://github.com/nvim-lualine/lualine.nvim): Stylized bar at the bottom of the cmdline.
- ...and a whole lot more...

### 3. Key Mappings

Most are from [thePrimeagens setup](https://github.com/ThePrimeagen/init.lua)
Some of the keymaps used that are not included in the above setup:

#### Git Keybindings
- Leader-G: Executes the Git command.
- Leader-gp: Pushes changes to the remote repository.
- Leader-gP: Pulls changes from the remote repository.
- Leader-gac: Adds all changes to the staging area and commits them.
- Leader-gc: Commits changes.
- Leader-gs: Displays the current status of the Git repository.

#### Yank/Pase to System Register Keybindings
- Leader-y: Yanks (copies) the selected text to the system clipboard.
- Leader-y-y: Yanks (copies) the current line to the system clipboard.
- Leader-p-Leader: Pastes the contents of the system clipboard.
- Leader-P: Pastes the contents of the system clipboard above the current line.

#### Other Keybindings
- Leader-p-v: Opens the viewer.
- Leader-p-f: Does a search on files for keyword.
- Leader-p-s: Does a grep search on keyword.
- Leader-f: Formats the file. 
- K/J (in visual mode): Moves the selected text up/down one line with tabbing.
- Leader-u: Toggles UndoTree

#### Movement Keybindings
- Leader-<tab>-hjkl: Moves current buffer in focus using vim motions
- C-hjkl: moves around top 4 files in Harpoon 
- C-zx: moves left and right around the Harpoon files
- C-xv: in Telescope, opens up the selected file in a sp/vsp

## Connect with Me!
[![LinkedIn](https://img.shields.io/badge/LinkedIn-%230A66C2.svg?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/derek-corniello)
[![GitHub](https://img.shields.io/badge/GitHub-%23121011.svg?style=for-the-badge&logo=github&logoColor=white)](https://github.com/derekcorniello)
[![X](https://img.shields.io/badge/X-%231DA1F2.svg?style=for-the-badge&logo=x&logoColor=white)](https://x.com/derekcorniello)
