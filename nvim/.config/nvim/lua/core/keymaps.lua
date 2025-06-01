-- lots of Primeagen and emacs inspo here...
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

-- format whole file
vim.keymap.set("n", "<leader>f", vim.lsp.buf.format)

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

-- other keybinds may be found in:
--      * lsp_config
--      * each plugin
