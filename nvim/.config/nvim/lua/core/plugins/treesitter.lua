-- nvim-treesitter `main` branch API: `setup()` takes no highlight/ensure_installed
-- options (those were `master` branch). Parsers are installed via `install()`,
-- and highlighting must be started explicitly per buffer with `vim.treesitter.start()`.
require("nvim-treesitter").setup({})

-- Use the checked-out Mux grammar while developing it. On another machine,
-- nvim-treesitter falls back to a published grammar revision.
local mux_grammar_path = vim.fn.expand("~/code/mux/tree-sitter-mux")
local mux_parser = {
    install_info = {
        url = "https://github.com/muxlang/tree-sitter-mux",
        revision = "9d89fb021c15b70b967ef8574c7e28d640d2b705",
        queries = "queries",
    },
    tier = 2,
}
if vim.uv.fs_stat(mux_grammar_path) then
    local revision = vim.fn.systemlist({ "git", "-C", mux_grammar_path, "rev-parse", "HEAD" })[1]
    if revision and revision:match("^[%x]+$") then
        mux_parser.install_info = { path = mux_grammar_path, revision = revision, queries = "queries" }
    end
end
local function register_mux_parser()
    require("nvim-treesitter.parsers").mux = mux_parser
end
register_mux_parser()
vim.api.nvim_create_autocmd("User", { pattern = "TSUpdate", callback = register_mux_parser })

local parsers = { "mux", "ql", "javascript", "typescript", "tsx", "lua", "python", "cpp", "json", "css", "html" }
-- Async no-op for already-installed parsers; installs the missing ones
-- (json/jsonc share the json parser, tsx covers typescriptreact).
require("nvim-treesitter").install(parsers)

-- jsonc buffers use the json parser/queries
vim.treesitter.language.register("json", { "jsonc" })

vim.filetype.add({ extension = { mux = "mux", ql = "ql", qll = "ql" } })
vim.treesitter.language.register("mux", { "mux" })
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
