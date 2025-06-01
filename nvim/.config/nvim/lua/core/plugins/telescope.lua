require('telescope').setup {
    defaults = {
        file_ignore_patterns = { ".git" },
    }
}

local builtin = require('telescope.builtin')
vim.keymap.set("n", "<leader>,", builtin.buffers, { desc = "Switch Buffer", })
vim.keymap.set("n", "<leader>/", builtin.current_buffer_fuzzy_find, { desc = "Search Buffer", })
vim.keymap.set("n", "<leader>:", builtin.command_history, { desc = "Command History", })
vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find Files", })
vim.keymap.set("n", "<leader>fr", builtin.oldfiles, { desc = "Recent Files", })
vim.keymap.set("n", "<leader>fR", builtin.resume, { desc = "Resume Search", })
vim.keymap.set("n", "<leader>sg", builtin.live_grep, { desc = "Grep (root dir)", })
vim.keymap.set("n", "<leader>sb", builtin.current_buffer_fuzzy_find, { desc = "Buffer Search", })
vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "Help Pages", })
vim.keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "Key Maps", })
vim.keymap.set("n", "<leader>sf", builtin.find_files, { desc = "Find Files", })
vim.keymap.set("n", "<leader>sw", builtin.grep_string, { desc = "Word Under Cursor", })
vim.keymap.set("n", "<leader>sd", function() builtin.diagnostics({ bufnr = 0 }) end, { desc = "Document diagnostics", })
vim.keymap.set("n", "<leader>sD", builtin.diagnostics, { desc = "Workspace diagnostics", })
vim.keymap.set("n", "<leader>sr", builtin.resume, { desc = "Resume last search", })
