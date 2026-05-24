-- Auto-detect .mux files and set filetype
vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
  pattern = "*.mux",
  callback = function()
    vim.bo.filetype = "mux"
  end,
})
