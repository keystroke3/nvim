return {
  {
    'folke/snacks.nvim',
    priority = 1000,
    lazy = false,
    opts = {
      input = {
        enabled = true,
        win = {
          style = 'input',
          relative = 'cursor',
          row = -3,
          col = 0,
        },
      },
    },
  },
  {
    'coder/claudecode.nvim',
    dependencies = { 'folke/snacks.nvim' },
    config = true,
    keys = {
      { '<leader>a',  nil,                              desc = 'AI/Claude Code' },
      { '<leader>ac', '<cmd>ClaudeCode<cr>',            desc = 'Toggle Claude' },
      { '<leader>af', '<cmd>ClaudeCodeFocus<cr>',       desc = 'Focus Claude' },
      { '<leader>ar', '<cmd>ClaudeCode --resume<cr>',   desc = 'Resume Claude' },
      { '<leader>aC', '<cmd>ClaudeCode --continue<cr>', desc = 'Continue Claude' },
      { '<leader>am', '<cmd>ClaudeCodeSelectModel<cr>', desc = 'Select Claude model' },
      { '<leader>ab', '<cmd>ClaudeCodeAdd %<cr>',       desc = 'Add current buffer' },
      { '<leader>as', '<cmd>ClaudeCodeSend<cr>',        mode = 'v',                  desc = 'Send to Claude' },
      {
        '<leader>as',
        '<cmd>ClaudeCodeTreeAdd<cr>',
        desc = 'Add file',
        ft = { 'NvimTree', 'neo-tree', 'oil', 'minifiles', 'netrw' },
      },
      -- Diff management
      { '<leader>aa', '<cmd>ClaudeCodeDiffAccept<cr>', desc = 'Accept diff' },
      { '<leader>ad', '<cmd>ClaudeCodeDiffDeny<cr>',   desc = 'Deny diff' },
    },
  },
  {
    'milanglacier/minuet-ai.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      require('minuet').setup {
        cmp = { enable_auto_complete = false },
        blink = { enable_auto_complete = false },
        provider = 'openai_compatible',
        provider_options = {
          openai_compatible = {
            model = 'qwen2.5-coder-1.5b-instruct-mlx',
            api_key = 'TERM',
            end_point = 'http://localhost:1234/v1/chat/completions',
            name = 'LMStudio',
            stream = true,
            optional = {
              max_tokens = 256,
              top_p = 0.9,
            },
          },
        },
        virtualtext = {
          auto_trigger_ft = {},
          keymap = {
            accept = '<A-a>',
            accept_line = '<A-l>',
            next = '<A-n>',
            prev = '<A-p>',
            dismiss = '<A-e>',
          },
        },
      }
    end,
  },
  {
    'nickjvandyke/opencode.nvim',
    version = '*',
    config = function()
      vim.g.opencode_opts = {}
      vim.o.autoread = true
    end,
    keys = {
      { '<leader>i',  nil,                                                                  desc = 'AI/opencode' },
      { '<leader>ic', function() require('opencode').ask('@this: ') end,                   desc = 'Ask opencode' },
      { '<leader>if', function() require('opencode').select() end,                         desc = 'Select opencode menu' },
      { '<leader>ir', function() require('opencode').command('session.select') end,        desc = 'Resume opencode session' },
      { '<leader>iC', function() require('opencode').command('session.new') end,           desc = 'New opencode session' },
      { '<leader>ib', function() require('opencode').ask('@buffer ') end,                  desc = 'Ask with buffer context' },
      { '<leader>is', function() return require('opencode').operator('@this ') end,        desc = 'Send to opencode (operator)', expr = true },
      { '<leader>is', function() require('opencode').ask('@this ') end,                    desc = 'Send selection to opencode', mode = 'v' },
      { '<leader>ia', function() require('opencode').command('session.undo') end,          desc = 'Undo opencode change' },
      { '<leader>iR', function() require('opencode').command('session.redo') end,          desc = 'Redo opencode change' },
      { '<leader>ix', function() require('opencode').command('session.interrupt') end,     desc = 'Interrupt opencode' },
      { '<leader>iu', function() require('opencode').command('session.half.page.up') end,  desc = 'Scroll opencode up' },
      { '<leader>id', function() require('opencode').command('session.half.page.down') end, desc = 'Scroll opencode down' },
    },
  },
}
