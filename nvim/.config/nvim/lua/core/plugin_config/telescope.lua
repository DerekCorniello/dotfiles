local builtin = require('telescope.builtin')
require('telescope').setup {
    defaults = {
        file_ignore_patterns = { ".git" },
        n = {
            ["<C-j>"] = "actions.select_vertical",
            ["<C-l>"] = "actions.select_horizontal"
        },
        i = {
            ["<C-j>"] = "actions.select_vertical",
            ["<C-l>"] = "actions.select_horizontal"
        }
    }
}
vim.keymap.set('n', '<leader>pf', builtin.find_files, {})
vim.keymap.set('n', '<leader>ps', function()
    builtin.grep_string({ search = vim.fn.input("Grep > ") });
end)
