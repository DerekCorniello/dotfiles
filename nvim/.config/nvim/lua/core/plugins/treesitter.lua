-- require('nvim-treesitter').setup {
--     install_dir = vim.fs.joinpath(vim.fn.stdpath('data'), 'site'),
-- }
--
-- local ensure_installed = {
--     "javascript", "typescript", "c", "cpp", "lua", "python", "toml"
-- }
--
-- local installed = require('nvim-treesitter').get_installed('parsers')
-- local available = require('nvim-treesitter').get_available()
-- local to_install = {}
-- for _, lang in ipairs(ensure_installed) do
--     if not vim.tbl_contains(installed, lang) and vim.tbl_contains(available, lang) then
--         table.insert(to_install, lang)
--     end
-- end
--
-- if #to_install > 0 then
--     require('nvim-treesitter').install(to_install)
-- end
--
-- vim.api.nvim_create_autocmd('FileType', {
--     pattern = '*',
--     callback = function(args)
--         pcall(vim.treesitter.start, args.buf)
--     end,
-- })

require("nvim-treesitter.configs").setup({
  modules = {},

  ensure_installed = {
    "javascript",
    "typescript",
    "c",
    "cpp",
    "lua",
    "python",
    "toml",
  },

  sync_install = false,
  ignore_install = {},

  auto_install = false,

  highlight = {
    enable = true,
  },

  indent = {
    enable = true,
  },
})
