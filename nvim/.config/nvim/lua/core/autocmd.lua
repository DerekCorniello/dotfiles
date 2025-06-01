-- Highlight on yank
socal builtin = require('telescope.builtin')
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = "Highlight when yanking text"
  group = highlight_group,
  callback = function()
    vim.highlight.on_yank({
      higroup = 'IncSearch',  -- Uses colorscheme's IncSearch highlight group
      timeout = 250,          -- Highlight duration in milliseconds
    })
  end,
})
