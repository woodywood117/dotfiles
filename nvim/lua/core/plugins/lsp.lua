return {
  { -- LSP Configuration & Plugins
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs and related tools to stdpath for neovim
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',

      -- Useful status updates for LSP.
      -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
      { 'j-hui/fidget.nvim', opts = {} },
    },
    config = function()
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('framework-lsp-attach', { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc)
            vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          local opensig = function()
            local cmp = require 'cmp'
            cmp.close()
            vim.lsp.buf.signature_help()
          end
          vim.keymap.set('i', '<C-S>', opensig, { desc = 'Show signature help' })
          vim.keymap.set('n', '<leader>lr', '<cmd>LspRestart<CR>', { silent = true, desc = '[L]sp [R]estart' })

          local border = 'single'
          vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, { border = border, max_width = 100, max_height = 30 })
          vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = border, max_width = 100, max_height = 30 })
          vim.diagnostic.config { float = { border = border } }
          require('lspconfig.ui.windows').default_options = { border = border }

          map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
          map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
          map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
          map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
          map('<leader>wds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
          map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')
          map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
          map('<leader>rl', '<cmd>LspRestart<CR>', '[R]estart [L]SP')
          map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
          map('K', vim.lsp.buf.hover, 'Hover Documentation')
          map('<C-S>', vim.lsp.buf.signature_help, 'Signature Documentation')
          map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client.server_capabilities.documentHighlightProvider then
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              callback = vim.lsp.buf.clear_references,
            })
          end
        end,
      })

      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())
      local servers = {
        clangd = {},
        gopls = {},
        rust_analyzer = {},
        tsserver = {},
        html = {
          -- on_attach = on_attach,
          capabilities = capabilities,
          filetypes = { 'html', 'templ' },
        },
        htmx = {
          -- on_attach = on_attach,
          capabilities = capabilities,
          filetypes = { 'html', 'templ' },
        },
        tailwindcss = {
          -- on_attach = on_attach,
          capabilities = capabilities,
          filetypes = { 'html', 'templ', 'javascript', 'typescript' },
          init_options = { userLanguages = { templ = 'html' } },
        },
        lua_ls = {
          settings = {
            Lua = {
              runtime = { version = 'LuaJIT' },
              workspace = {
                checkThirdParty = false,
                library = {
                  '${3rd}/luv/library',
                  unpack(vim.api.nvim_get_runtime_file('', true)),
                },
              },
              completion = {
                callSnippet = 'Replace',
              },
            },
          },
        },
      }

      -- Ensure the servers and tools above are installed
      --    :Mason
      --  You can press `g?` for help in this menu
      require('mason').setup()

      local ensure_installed = vim.tbl_keys(servers or {})
      vim.list_extend(ensure_installed, {
        'stylua',
        'clangd',
        'clang-format',
        'codelldb',
        'delve',
      })
      require('mason-tool-installer').setup { ensure_installed = ensure_installed }

      require('mason-lspconfig').setup {
        handlers = {
          function(server_name)
            local server = servers[server_name] or {}
            server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
            require('lspconfig')[server_name].setup(server)
          end,
        },
      }
    end,
  },

  { -- Autoformat
    'stevearc/conform.nvim',
    opts = {
      notify_on_error = false,
      format_on_save = {
        timeout_ms = 500,
        lsp_fallback = true,
      },
      formatters_by_ft = {
        lua = { 'stylua' },
        c = { 'clang-format' },
      },
      formatters = {
        clang_format = {
          args = { '-style=webkit' },
        },
      },
    },
    dependencies = {
      'p00f/clangd_extensions.nvim',
      'mason.nvim',
    },
  },
}
