-- Highlight on yank
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank({
      higroup = 'IncSearch',  -- Uses your colorscheme's IncSearch highlight group (usually yellow/orange)
      timeout = 250,          -- Highlight duration in milliseconds
    })
  end,
  group = highlight_group,
  pattern = '*',
})
