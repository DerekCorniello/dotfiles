local undotree = require('undotree')

undotree.setup({
  float_diff = false,  -- using float window previews diff, set this `true` will disable layout option
  layout = "left_bottom", -- "left_bottom", "left_left_bottom"
  position = "left", -- "right", "bottom"
  ignore_filetype = { 'undotree', 'undotreeDiff', 'qf', 'TelescopePrompt', 'spectre_panel', 'tsplayground' },
  window = {
    winblend = 30,
  },
  keymaps = {
    move_next = 'j',
    move_prev = 'k',
    move2parent = 'gj',
    action_enter = '<cr>',
    enter_diffbuf = 'p',
    quit = 'q',
  },
})

vim.keymap.set('n', '<leader>u', undotree.toggle, { noremap = true, silent = true })
