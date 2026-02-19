local lspconfig = require('lspconfig')
local util = require('lspconfig.util')

-- Setup mason with UI icons
require("mason").setup({
    ui = {
        icons = {
            package_installed = "",
            package_pending = "",
            package_uninstalled = "",
        },
    }
})

-- Setup mason-lspconfig without automatic enabling to avoid double servers
require("mason-lspconfig").setup({
    automatic_enable = false,
    ensure_installed = { "lua_ls", "pylsp", "ts_ls", "jsonls", "rust_analyzer", "gopls", "sqls", "emmet_ls", "html", "clangd" }
})

-- Custom on_attach for all LSPs
local on_attach = function(client, bufnr)
    vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

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
    keymap('n', '[d', vim.diagnostic.goto_prev, bufopts)
    keymap('n', ']d', vim.diagnostic.goto_next, bufopts)
    keymap('n', '<space>q', vim.diagnostic.setloclist, bufopts)
end

-- Setup capabilities with snippet and experimental file watching support
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)
capabilities.workspace = capabilities.workspace or {}
capabilities.workspace.didChangeWatchedFiles = { dynamicRegistration = true }
capabilities.textDocument.completion.completionItem.snippetSupport = true

-- Manual lua_ls setup (overrides mason-lspconfig automatic setup)
lspconfig.lua_ls.setup({
    on_attach = on_attach,
    capabilities = capabilities,
    settings = {
        Lua = {
            runtime = { version = 'LuaJIT', path = vim.split(package.path, ';') },
            diagnostics = { globals = { 'vim' }, disable = { 'lowercase-global' } },
            workspace = { library = vim.api.nvim_get_runtime_file("", true), checkThirdParty = false },
            completion = { callSnippet = 'Replace' },
        },
    },
    handlers = {
        ["textDocument/publishDiagnostics"] = function(_, result, ctx, config)
            config = config or {}
            config.virtual_text = config.virtual_text or {
                severity = { min = vim.diagnostic.severity.ERROR, max = vim.diagnostic.severity.HINT },
                severity_sort = true,
            }
            if vim.diagnostic and vim.diagnostic.on_publish_diagnostics then
                vim.diagnostic.on_publish_diagnostics(_, result, ctx, config)
            end
        end,
    },
})

-- Setup other servers after Mason installs
local function setup_servers()
    local installed = require('mason-lspconfig').get_installed_servers()
    for _, server in ipairs(installed) do
        if server ~= "lua_ls" then -- skip lua_ls, manually configured above
            if server == "gopls" then
                lspconfig.gopls.setup {
                    on_attach = on_attach,
                    capabilities = capabilities,
                    cmd = { "gopls" },
                    filetypes = { "go", "gomod", "gowork", "gotmpl" },
                    root_dir = util.root_pattern("go.work", "go.mod", ".git"),
                    settings = {
                        gopls = {
                            completeUnimported = true,
                            usePlaceholders = true,
                            analyses = { unusedparams = true },
                        }
                    }
                }
            elseif server == "emmet_ls" then
                local configs = require("lspconfig.configs")
                if not configs.emmet_ls then
                    configs.emmet_ls = {
                        default_config = {
                            cmd = { 'emmet_ls', '--stdio' },
                            filetypes = {
                                'html', 'css', 'scss', 'javascriptreact', 'typescriptreact', 'haml', 'xml',
                                'xsl', 'pug', 'slim', 'sass', 'stylus', 'less', 'sss', 'hbs', 'handlebars',
                            },
                            root_dir = function() return vim.loop.cwd() end,
                            settings = {},
                        },
                    }
                end
                lspconfig.emmet_ls.setup({ on_attach = on_attach, capabilities = capabilities })
            elseif server == "ocamllsp" then
                lspconfig.ocamllsp.setup({
                    cmd = { "ocamllsp" },
                    filetypes = { "ocaml", "ocaml.menhir", "ocaml.interface", "ocaml.ocamllex", "reason", "dune" },
                    root_dir = lspconfig.util.root_pattern("*.opam", "esy.json", "package.json", ".git", "dune-project",
                        "dune-workspace"),
                    on_attach = on_attach,
                    capabilities = capabilities
                })
            elseif server == "rust_analyzer" then
                -- dont do anything, theres rustaceanvim for that
            else
                -- default server setup for others
                lspconfig[server].setup({
                    on_attach = on_attach,
                    capabilities = capabilities,
                })
            end
        end
    end
end

-- Setup after Mason installs servers
vim.api.nvim_create_autocmd('User', {
    pattern = 'LspInstallPost',
    callback = setup_servers,
    once = true,
})

-- Run setup on startup
setup_servers()
