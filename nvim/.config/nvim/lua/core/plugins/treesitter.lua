require("nvim-treesitter.config").setup({
    highlight = { enable = true },
    ensure_installed = { "ql", "javascript", "typescript", "tsx", "lua", "python", "cpp", "json", "jsonc", "css", "html" },
})

vim.filetype.add({ extension = { ql = "ql", qll = "ql" } })
vim.api.nvim_create_autocmd("FileType", {
    pattern = "ql",
    callback = function() vim.treesitter.start() end,
})
