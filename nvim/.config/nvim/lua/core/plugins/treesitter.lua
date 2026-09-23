-- nvim-treesitter `main` branch API: `setup()` takes no highlight/ensure_installed
-- options (those were `master` branch). Parsers are installed via `install()`,
-- and highlighting must be started explicitly per buffer with `vim.treesitter.start()`.
require("nvim-treesitter").setup({})

local parsers = { "ql", "javascript", "typescript", "tsx", "lua", "python", "cpp", "json", "css", "html" }
-- Async no-op for already-installed parsers; installs the missing ones
-- (json/jsonc share the json parser, tsx covers typescriptreact).
require("nvim-treesitter").install(parsers)

-- jsonc buffers use the json parser/queries
vim.treesitter.language.register("json", { "jsonc" })

vim.filetype.add({ extension = { ql = "ql", qll = "ql" } })
vim.api.nvim_create_autocmd("FileType", {
    pattern = "*",
    callback = function(args)
        local buf = args.buf
        if vim.treesitter.highlighter.active[buf] then
            return
        end
        pcall(vim.treesitter.start, buf)
    end,
})
