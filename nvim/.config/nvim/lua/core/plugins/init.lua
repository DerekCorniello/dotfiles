require("core.plugins.autopairs")
require("core.plugins.cmp")
-- NOTE: do NOT require core.plugins.conform here. conform.nvim is
-- lazy-loaded by lazy.nvim (BufWritePre); requiring it eagerly runs before
-- the plugin is on 'runtimepath', so require("conform") fails and poisons
-- the later lazy `config` with "loop or previous error loading module".
require("core.plugins.gitsigns")
require("core.plugins.go_config")
require("core.plugins.harpoon")
require("core.plugins.lsp_config")
require("core.plugins.lualine")
require("core.plugins.onedark")
require("core.plugins.telescope")
require("core.plugins.ufo")
require("core.plugins.undotree")
require("core.plugins.web_tools")
