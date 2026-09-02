require("nvim-treesitter.config").setup({
    highlight = { enable = true },
    ensure_installed = { "ql", "javascript", "lua", "python", "cpp" },
})

vim.filetype.add({ extension = { ql = "ql", qll = "ql" } })
vim.api.nvim_create_autocmd("FileType", {
    pattern = "ql",
    callback = function() vim.treesitter.start() end,
})
