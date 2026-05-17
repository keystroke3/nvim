return {
  'neovim/nvim-lspconfig',
  dependencies = {
    { 'williamboman/mason.nvim', config = true }, -- NOTE: Must be loaded before dependants
    'WhoIsSethDaniel/mason-tool-installer.nvim',

    { 'j-hui/fidget.nvim',       opts = {} },

    'hrsh7th/cmp-nvim-lsp',
  },
  config = function()
    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
      callback = function(event)
        local map = function(keys, func, desc)
          vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
        end
        vim.diagnostic.config {
          virtual_text = {
            format = function(diagnostic)
              if diagnostic.code then
                return string.format('%s [%s]', diagnostic.message, diagnostic.code)
              else
                return diagnostic.message
              end
            end,
          },
          signs = true,
          underline = true,
        }

        map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
        map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
        map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
        map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
        map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
        map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')
        map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
        map('<leader>c', vim.lsp.buf.code_action, '[C]ode [A]ction')
        map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
          local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
          vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.document_highlight,
          })

          vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.clear_references,
          })

          vim.api.nvim_create_autocmd('LspDetach', {
            group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
            callback = function(event2)
              vim.lsp.buf.clear_references()
              vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
            end,
          })
        end

        if client and client.name == 'gopls' then
          map('<leader>o', function()
            client:exec_cmd { title = 'gc_details', command = 'gopls.gc_details', arguments = { vim.uri_from_bufnr(event.buf) } }
          end, 'Toggle compiler [O]ptimizations')
        end

        if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
          map('<leader>th', function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
          end, '[T]oggle Inlay [H]ints')
        end
      end,
    })

    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

    -- Apply capabilities globally to all servers
    vim.lsp.config('*', { capabilities = capabilities })

    -- require('mason-tool-installer').setup {
    --   ensure_installed = { 'jdtls', 'gopls', 'typescript-language-server', 'clangd', 'rust-analyzer', 'lua-language-server', 'stylua' },
    -- }

    vim.lsp.config('lua_ls', {
      settings = {
        Lua = {
          completion = {
            callSnippet = 'Replace',
          },
        },
      },
    })

    vim.lsp.config('gopls', {
      settings = {
        gopls = {
          usePlaceholders = true,
          renameMovesSubpackages = true,
          staticcheck = true,
          matcher = 'Fuzzy',
          analyses = {
            unusedparams = true,
            fillstruct = true,
          },
        },
      },
    })

    -- vim.lsp.config('ty', {
    --   cmd = { 'ty', 'server' },
    --   filetypes = { 'python' },
    --   root_markers = { 'pyproject.toml', 'setup.py', 'setup.cfg', 'requirements.txt', '.git' },
    -- })

    vim.lsp.config('cspell', {
      cmd = { 'cspell-lsp', '--stdio' },
      root_markers = { '.git', 'cspell.json' },
    })
    vim.lsp.enable 'cspell'

    vim.lsp.config('harper_ls', {
      cmd = { 'harper-ls', '--stdio' },
      filetypes = {
        'markdown',
        'tex',
        'gitcommit',
        'restructuredtext',
        'text',
      },
      settings = {
        ['harper-ls'] = {
          linters = {
            spell_check = true,
            sentence_capitalization = true,
          },
        },
      },
    })
    vim.lsp.config('omnisharp', {
      settings = {
        RoslynExtensionsOptions = {
          EnableAnalyzersSupport = true,
          EnableImportCompletion = true,
        },
      },
    })

    vim.lsp.enable { 'harper_ls', 'jdtls', 'gopls', 'ts_ls', 'clangd', 'rust_analyzer', 'lua_ls', 'basedpyright', 'omnisharp' }
  end,
}
