require("mason").setup({
    ui = {
        icons = {
            package_installed = "",
            package_pending = "",
            package_uninstalled = "",
        },
    }
})
require("mason-lspconfig").setup({
    ensure_installed = { "lua_ls", "pylsp", "ts_ls", "denols", "jsonls", "rust_analyzer" }
})
local completion_callback = require('cmp_nvim_lsp').on_attach
local capabilities = require("cmp_nvim_lsp").default_capabilities()

require 'lspconfig'.lua_ls.setup {
    capabilities = capabilities,
    on_attach = completion_callback,
    settings = {
        Lua = {
            diagnostics = {
                globals = { 'vim' }
            }
        }
    },
    handlers = {
        ["textDocument/publishDiagnostics"] = function(_, result, ctx, config)
            config = config or {}
            config.virtual_text = config.virtual_text or {
                severity = {
                    min = vim.diagnostic.severity.ERROR,
                    max = vim.diagnostic.severity.HINT,
                },
                severity_sort = true,
            }
            vim.lsp.diagnostic.on_publish_diagnostics(_, result, ctx, config)
        end,
    },
}
require('lspconfig').pylsp.setup {
    capabilities = capabilities,
    on_attach = completion_callback
}

local util = require "lspconfig/util"

require('lspconfig').gopls.setup {
    capabilities = capabilities,
    on_attach = completion_callback,
    cmd = { "gopls" },
    filetypes = { "go", "gomod", "gowork", "gotmpl" },
    root_dir = util.root_pattern { "go.work", "go.mod", ".git" },
    settings = {
        gopls = {
            completeUnimported = true,
            usePlaceholders = true,
            analyses = {
                unusedparams = true,
            }
        }
    }
}

require('lspconfig').ts_ls.setup {
    capabilities = capabilities,
    on_attach = completion_callback,
    filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact", "vue" }
}

require('lspconfig').jsonls.setup {
    capabilities = capabilities,
    on_attach = completion_callback,
}

require('lspconfig').sqls.setup {
    capabilities = capabilities,
    on_attach = completion_callback,
    lowercaseKeywords = false
}

local configs = require 'lspconfig.configs'

capabilities.textDocument.completion.completionItem.snippetSupport = true
if not configs.ls_emmet then
    configs.ls_emmet = {
        default_config = {
            cmd = { 'ls_emmet', '--stdio' },
            filetypes = {
                'html',
                'css',
                'scss',
                'javascriptreact',
                'typescriptreact',
                'haml',
                'xml',
                'xsl',
                'pug',
                'slim',
                'sass',
                'stylus',
                'less',
                'sss',
                'hbs',
                'handlebars',
            },
            root_dir = function(fname)
                return vim.loop.cwd()
            end,
            settings = {},
        },
    }
end

require('lspconfig').ls_emmet.setup {
    capabilities = capabilities,
    on_attach = completion_callback,
}

require('lspconfig').html.setup {
    capabilities = capabilities,
    on_attach = completion_callback,
}

require('lspconfig').clangd.setup {
    capabilities = capabilities,
    on_attach = completion_callback,
    cmd = {
        "clangd",
        "--fallback-style=webkit"
    }
}
