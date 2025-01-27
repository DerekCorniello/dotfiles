vim.o.showmode = false
vim.opt.nu = true
vim.opt.relativenumber = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.smartindent = true

vim.opt.wrap = true

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("USERPROFILE") .. "/.vim/undodir"
vim.opt.undofile = true

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.termguicolors = true

vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

vim.opt.updatetime = 50

vim.opt.completeopt = { 'menuone', 'noselect', 'noinsert' }
vim.opt.shortmess = vim.opt.shortmess + { c = true }
vim.api.nvim_set_option('updatetime', 300)

vim.o.foldcolumn = '0' -- '0' is on, '1' is off
vim.o.foldlevel = 99   -- Using ufo provider need a large value, feel free to decrease the value
vim.o.foldlevelstart = 99
vim.o.foldenable = true

-- remaps space to leader
vim.g.mapleader = " "

-- opens viewer
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

-- moves selected text with tabbing
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- joins next line keeping cursor at one point
vim.keymap.set("n", "J", "mzJ`z")

-- keeps cursor in middle of screen
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- deletes highlighted word to void register and preserves register
vim.keymap.set("x", "<leader>d", [["_dP]])

-- yanks to system register
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]])
vim.keymap.set("v", "<C-c>", [["+y]])
vim.keymap.set("n", "<leader>yy", [["+Y]])

vim.keymap.set({ "n", "v" }, "<leader>p<leader>", [["+p]])
vim.keymap.set({ "n", "v" }, "<leader>P", [["+P]])

-- format whole package
vim.keymap.set("n", "<leader>f", vim.lsp.buf.format)

-- replaces word that you are on
vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])

-- git keybinds
vim.keymap.set("n", "<leader>G", vim.cmd.Git);
vim.keymap.set("n", "<leader>gp", function()
    vim.cmd.Git({ 'push' })
end)
vim.keymap.set("n", "<leader>gP", function()
    vim.cmd.Git({ 'pull' })
end)
vim.keymap.set("n", "<leader>gac", function()
    vim.cmd.Git({ 'add -A' })
    vim.cmd.Git({ 'commit' })
end)
vim.keymap.set("n", "<leader>gc", function()
    vim.cmd.Git({ 'commit' })
end)
vim.keymap.set("n", "<leader>gs", function()
    vim.cmd.Git({ 'status' })
end)

-- maps for go json tag
vim.keymap.set("n", "<leader>goj", function()
    vim.cmd("GoTagAdd json <CR>")
end)

vim.keymap.set('n', '<leader><tab>', '<c-w>p')
vim.keymap.set('t', '<leader><tab>', '<c-\\><c-n><c-w>w')

-- Move across tabs
vim.keymap.set('n', '<leader><tab>h', '<c-w>h')
vim.keymap.set('n', '<leader><tab>j', '<c-w>j')
vim.keymap.set('n', '<leader><tab>k', '<c-w>k')
vim.keymap.set('n', '<leader><tab>l', '<c-w>l')

vim.keymap.set({"n", "v"}, "<leader>ew", ':lua vim.diagnostic.open_float()<CR>')
vim.keymap.set({"n", "v"}, "<leader>def", "<cmd>lua require('goto-preview').goto_preview_definition()<CR>")
vim.keymap.set({"n", "v"}, "<leader>dec", "<cmd>lua require('goto-preview').goto_preview_declaration()<CR>")
vim.keymap.set({"n", "v"}, "<leader>ref", function()
  require('goto-preview').goto_preview_references()
  vim.schedule(function()
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", true)
  end)
end)

vim.keymap.set('n', '<CR>', '<CR>') -- Unmaps Enter in normal mode

vim.keymap.set('n', '<C-M>', '<C-w>L')
vim.keymap.set('n', '<C-N>', '<C-w>K')
