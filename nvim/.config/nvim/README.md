![Neovim](https://img.shields.io/badge/neovim-%2357A143.svg?style=for-the-badge&logo=neovim&logoColor=white)

# 🚀 Derek's Neovim Configuration

A highly optimized, modular Neovim configuration built for modern development. This setup combines performance, aesthetics, and powerful features to create a seamless coding experience.

## ✨ Features

- 🎨 Beautiful OneDark theme with enhanced syntax highlighting
- ⚡ Blazing fast startup time with lazy-loaded plugins
- 🧠 Smart auto-completion with nvim-cmp
- 🔍 Powerful fuzzy finding with Telescope
- 🧰 Language Server Protocol (LSP) support
- 🐙 Git integration with Gitsigns and Fugitive
- 📝 Markdown and LaTeX support
- 🌳 File explorer with built-in tree navigation
- 🔄 Session management and undo tree

## 🏗️ Project Structure

The configuration follows a modular structure with separate files for different concerns:

- `init.lua` - Entry point that loads core configuration
- `lua/core/` - Core configuration files:
  - `init.lua` - Main configuration
  - `keymaps.lua` - Key mappings
  - `options.lua` - Editor options
  - `autocmd.lua` - Auto-commands
  - `plugins/` - Individual plugin configurations

This structure keeps the configuration organized and maintainable, with each file handling a specific aspect of the setup.

## 🎮 Key Bindings

### 🎯 Navigation
- `<leader>pv` - Open file explorer
- `<C-h/j/k/l>` - Navigate between windows
- `<leader><tab>h/j/k/l` - Move buffer focus
- `<C-d>/<C-u>` - Half page navigation
- `zz/zv/zb` - Center/scroll view

### 🔍 Search & Find
- `<leader>pf` - Find files (Telescope)
- `<leader>ps` - Live grep (Telescope)
- `<leader>vh` - Search help tags
- `gd` - Go to definition
- `gr` - Show references
- `K` - Hover documentation

### 💻 Code Actions
- `<leader>ca` - Code actions
- `gD` - Go to declaration
- `gi` - Go to implementation
- `gy` - Go to type definition
- `[d`/`]d` - Navigate diagnostics
- `<leader>f` - Format document

### 🐙 Git Integration
- `<leader>gs` - Git status (Fugitive)
- `<leader>gp` - Git push
- `<leader>gP` - Git pull
- `<leader>gac` - Git add and commit
- `<leader>gc` - Git commit

### 📋 Clipboard
- `<leader>y` - Yank to system clipboard
- `<leader>yy` - Yank line to system clipboard
- `<leader>p` - Paste from system clipboard
- `<leader>P` - Paste above from system clipboard

### 🧩 Plugin Specific
- `<leader>u` - Toggle UndoTree
- `<C-h/j/k/l>` - Navigate Harpoon files
- `<C-zx>` - Cycle Harpoon files
- `<C-xv>` - Open Telescope selection in split

## 🚀 Why Neovim?

### Performance
- **Lightning Fast**: Near-instantaneous startup and navigation
- **Minimal Resource Usage**: Uses a fraction of the memory of traditional IDEs
- **Native Performance**: Written in C and Lua for maximum speed

### Customization
- **Endless Flexibility**: Tailor every aspect to your workflow
- **Version Controlled**: Your entire setup is portable and reproducible
- **Community Plugins**: Access to thousands of community-maintained plugins

### Developer Experience
- **Modal Editing**: More efficient than traditional editing
- **Keyboard-Centric**: Keep your hands on the keyboard
- **Terminal Integration**: Seamless terminal and editor workflow
- **Language Server Protocol**: IDE-like features for any language

### Future-Proof
- **Active Development**: Backed by a vibrant open-source community
- **Lua Configuration**: Modern, maintainable, and powerful
- **Plugin Ecosystem**: Growing collection of high-quality plugins

## 🛠️ Installation

1. Install Neovim 0.9.0 or later
2. Clone this repository to `~/.config/nvim`
3. Start Neovim and let `lazy.nvim` handle plugin installation

## 📦 Dependencies

- [Neovim 0.9.0+](https://github.com/neovim/neovim/releases)
- [ripgrep](https://github.com/BurntSushi/ripgrep) (for live grep)
- [fd](https://github.com/sharkdp/fd) (for file finding)
- [Node.js](https://nodejs.org/) (for LSP support)
- [Git](https://git-scm.com/) (for version control)

## 🤝 Contributing

Feel free to submit issues and enhancement requests. Pull requests are welcome!

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📬 Connect with Me!

[![LinkedIn](https://img.shields.io/badge/LinkedIn-%230A66C2.svg?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/derek-corniello)
[![GitHub](https://img.shields.io/badge/GitHub-%23121011.svg?style=for-the-badge&logo=github&logoColor=white)](https://github.com/derekcorniello)
[![X](https://img.shields.io/badge/X-%231DA1F2.svg?style=for-the-badge&logo=x&logoColor=white)](https://x.com/derekcorniello)
