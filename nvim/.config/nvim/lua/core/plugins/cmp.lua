local cmp = require('cmp')
local luasnip = require('luasnip')

-- Load friendly-snippets
require('luasnip.loaders.from_vscode').lazy_load()

-- Better autopairs integration
local cmp_autopairs = require('nvim-autopairs.completion.cmp')
cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())

cmp.setup({
    snippet = {
        expand = function(args)
            luasnip.lsp_expand(args.body)
        end,
    },
    
    mapping = cmp.mapping.preset.insert({
        ['<C-n>'] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
        ['<C-p>'] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
        ['<C-l>'] = cmp.mapping.scroll_docs(4),
        ['<C-h>'] = cmp.mapping.scroll_docs(-4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-y>'] = cmp.mapping.confirm({ select = true }),
        ['<C-e>'] = cmp.mapping.abort(),
    }),
    
    sources = {
        { name = 'nvim_lsp', max_item_count = 15 },
        { name = 'nvim_lsp_signature_help' },
        { name = 'luasnip' },
        { name = 'path' },
        { name = 'buffer', keyword_length = 3 },
    },
    
    window = {
        completion = cmp.config.window.bordered(),
        documentation = {
            max_height = 15,
            max_width = 60,
        },
    },
    
    formatting = {
        fields = { 'kind', 'abbr' },
        format = function(_, vim_item)
            local kind_icons = {
                Text = 'T', Method = 'F', Function = 'F', Constructor = 'C',
                Field = 'F', Variable = 'V', Class = 'C', Interface = 'I',
                Module = 'M', Property = 'P', Unit = 'U', Value = 'V',
                Enum = 'E', Keyword = 'K', Snippet = 'S', Color = 'C',
                File = 'F', Reference = 'R', Folder = 'D', EnumMember = 'E',
                Constant = 'C', Struct = 'S', Event = 'E', Operator = 'O',
                TypeParameter = 'T',
            }
            vim_item.kind = string.format('%s', kind_icons[vim_item.kind] or '?')
            return vim_item
        end,
    },
    
    experimental = {
        ghost_text = true,
    },
})
