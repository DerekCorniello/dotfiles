-- Mason for installing LSP servers (mason-lspconfig is kept for get_installed_servers only)
require("mason").setup({
    ui = {
        icons = {
            package_installed = "",
            package_pending = "",
            package_uninstalled = "",
        },
    }
})

require("mason-lspconfig").setup({
    automatic_enable = false,
    ensure_installed = { "lua_ls", "pylsp", "ts_ls", "jsonls", "rust_analyzer", "gopls", "sqls", "emmet_ls", "html", "clangd" }
})

-- Shared on_attach for all LSPs
local on_attach = function(_, bufnr)
    vim.api.nvim_set_option_value("number", true, { buf = bufnr })

    local bufopts = { noremap = true, silent = true, buffer = bufnr }
    local keymap = vim.keymap.set

    keymap('n', 'gD', vim.lsp.buf.declaration, bufopts)
    keymap('n', 'gd', vim.lsp.buf.definition, bufopts)
    keymap('n', 'K', vim.lsp.buf.hover, bufopts)
    keymap('n', 'gi', vim.lsp.buf.implementation, bufopts)
    keymap('n', 'gr', vim.lsp.buf.references, bufopts)
    keymap('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
    keymap('n', '<space>rn', vim.lsp.buf.rename, bufopts)
    keymap('n', '<space>ca', vim.lsp.buf.code_action, bufopts)
    keymap('n', '<space>f', function() vim.lsp.buf.format({ async = true }) end, bufopts)
    keymap('n', '<space>wa', vim.lsp.buf.add_workspace_folder, bufopts)
    keymap('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
    keymap('n', '<space>wl', function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end, bufopts)
    keymap('n', '<space>D', vim.lsp.buf.type_definition, bufopts)
    keymap('n', '[d', function()
        vim.diagnostic.jump({ count = -1 })
    end, bufopts)
    keymap('n', ']d', function()
        vim.diagnostic.jump({ count = 1 })
    end, bufopts)
    keymap('n', '<space>q', vim.diagnostic.setloclist, bufopts)
end

-- Capabilities with snippet and experimental file watching support
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)
capabilities.workspace = capabilities.workspace or {}
capabilities.workspace.didChangeWatchedFiles = { dynamicRegistration = true }
capabilities.textDocument.completion.completionItem.snippetSupport = true

-- Configure a server by name with the shared base options
local function configure(name, extra)
    local opts = vim.tbl_deep_extend("force", {
        on_attach = on_attach,
        capabilities = capabilities,
    }, extra or {})
    vim.lsp.config(name, opts)
    vim.lsp.enable(name)
end

-- lua_ls: manual config (overrides bundled defaults)
configure("lua_ls", {
    settings = {
        Lua = {
            runtime = { version = 'LuaJIT', path = vim.split(package.path, ';') },
            diagnostics = { globals = { 'vim' }, disable = { 'lowercase-global' } },
            workspace = { library = vim.api.nvim_get_runtime_file("", true), checkThirdParty = false },
            completion = { callSnippet = 'Replace' },
        },
    },
})

-- emmet_ls: not in bundled configs, register it explicitly
vim.lsp.config("emmet_ls", {
    cmd = { "emmet_ls", "--stdio" },
    filetypes = {
        "html", "css", "scss", "javascriptreact", "typescriptreact", "haml", "xml",
        "xsl", "pug", "slim", "sass", "stylus", "less", "sss", "hbs", "handlebars",
    },
    root_dir = function(_, on_dir)
        on_dir(vim.fn.cwd())
    end,
    settings = {},
    on_attach = on_attach,
    capabilities = capabilities,
})
vim.lsp.enable("emmet_ls")

-- gopls: extra settings + root_dir
configure("gopls", {
    cmd = { "gopls" },
    filetypes = { "go", "gomod", "gowork", "gotmpl" },
    root_dir = function(bufnr, on_dir)
        on_dir(vim.fs.root(bufnr, { "go.work", "go.mod", ".git" }))
    end,
    settings = {
        gopls = {
            completeUnimported = true,
            usePlaceholders = true,
            analyses = { unusedparams = true },
        },
    },
})

-- ocamllsp
configure("ocamllsp", {
    cmd = { "ocamllsp" },
    filetypes = { "ocaml", "ocaml.menhir", "ocaml.interface", "ocaml.ocamllex", "reason", "dune" },
    root_dir = function(bufnr, on_dir)
        on_dir(vim.fs.root(bufnr, { "*.opam", "esy.json", "package.json", ".git", "dune-project", "dune-workspace" }))
    end,
})

-- clangd
local function resolve_clangd()
    local mason_clangd = vim.fs.joinpath(vim.fn.stdpath("data"), "mason", "bin", "clangd")
    if vim.uv.fs_stat(mason_clangd) then
        return mason_clangd
    end

    local system_clangd = vim.fn.exepath("clangd")
    if system_clangd ~= "" then
        return system_clangd
    end

    return "clangd"
end

configure("clangd", {
    cmd = {
        resolve_clangd(),
        "--background-index",
        "--background-index-priority=normal",
        "--completion-style=detailed",
        "--limit-results=5000",
        "--limit-references=50000",
        "--ranking-model=decision_forest",
    },
    filetypes = { "c", "cpp", "objc", "objcpp" },
    root_dir = function(bufnr, on_dir)
        on_dir(vim.fs.root(bufnr, { "compile_commands.json", "compile_flags.txt", ".git" }))
    end,
    init_options = { fallbackFlags = {} },
})

-- rust_analyzer: handled by rustaceanvim, skip

-- Wire up any other mason-installed servers after Mason installs them
local function setup_servers()
    for _, server in ipairs(require('mason-lspconfig').get_installed_servers()) do
        if server ~= "lua_ls"
            and server ~= "gopls"
            and server ~= "emmet_ls"
            and server ~= "ocamllsp"
            and server ~= "clangd"
            and server ~= "rust_analyzer"
        then
            vim.lsp.config(server, {
                on_attach = on_attach,
                capabilities = capabilities,
            })
            vim.lsp.enable(server)
        end
    end
end

vim.api.nvim_create_autocmd('User', {
    pattern = 'LspInstallPost',
    callback = setup_servers,
    once = true,
})

setup_servers()
