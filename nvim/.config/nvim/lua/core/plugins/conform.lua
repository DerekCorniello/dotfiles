-- Single formatter per filetype. Prettier reads each repo's own config,
-- so save, <space>f, `make fmt`, and the pre-commit hook all agree.
-- This module is loaded by lazy.nvim's `config` for conform.nvim only
-- (see core/init.lua) -- do NOT require it from core/plugins/init.lua,
-- or it runs before the plugin is on 'runtimepath'.
local ok, conform = pcall(require, "conform")
if not ok then
    vim.notify("conform.nvim not yet loaded, skipping setup", vim.log.levels.WARN)
    return
end
conform.setup({
    formatters_by_ft = {
        typescript = { "prettier" },
        typescriptreact = { "prettier" },
        javascript = { "prettier" },
        javascriptreact = { "prettier" },
        json = { "prettier" },
        jsonc = { "prettier" },
        css = { "prettier" },
        html = { "prettier" },
    },
    format_on_save = {
        timeout_ms = 500,
        lsp_format = "fallback",
    },
})
