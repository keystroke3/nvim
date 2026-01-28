return {
  'mfussenegger/nvim-dap',
  dependencies = {
    'leoluz/nvim-dap-go',
    'rcarriga/nvim-dap-ui',
    'theHamsta/nvim-dap-virtual-text',
    'nvim-neotest/nvim-nio',
    'williamboman/mason.nvim',
  },
  config = function()
    local dap = require 'dap'
    local ui = require 'dapui'

    require('dapui').setup()
    require('dap-go').setup {
      dap_configurations = {
        {
          type = 'go',
          name = 'Debug (Build Flags)',
          request = 'launch',
          program = '${file}',
          buildFlags = require('dap-go').get_build_flags,
        },
        {
          type = 'go',
          name = 'Debug (Build Flags & Arguments)',
          request = 'launch',
          program = '${file}',
          args = require('dap-go').get_arguments,
          buildFlags = require('dap-go').get_build_flags,
        },
      },
    }
    require('nvim-dap-virtual-text').setup {
      display_callback = function(variable)
        local name = string.lower(variable.name)
        local value = string.lower(variable.value)
        if name:match 'secret' or name:match 'api' or value:match 'secret' or value:match 'api' then
          return '*****'
        end

        if #variable.value > 15 then
          return ' ' .. string.sub(variable.value, 1, 15) .. '... '
        end

        return ' ' .. variable.value
      end,
    }

    vim.keymap.set('n', '<leader>b', dap.toggle_breakpoint, { desc = 'Toggle breakpoint' })

    vim.keymap.set('n', '<space>?', function()
      require('dapui').eval(nil, { enter = true })
    end)

    vim.keymap.set('n', '<F1>', dap.continue)
    vim.keymap.set('n', '<F2>', dap.step_into)
    vim.keymap.set('n', '<F3>', dap.step_over)
    vim.keymap.set('n', '<F4>', dap.step_out)
    vim.keymap.set('n', '<F5>', dap.step_back)
    vim.keymap.set('n', '<F13>', dap.restart)
    vim.keymap.set('n', '<leader>dt', ui.toggle, { desc = 'Toggle DAP UI' })

    dap.listeners.before.attach.dapui_config = function()
      ui.open()
    end
    dap.listeners.before.launch.dapui_config = function()
      ui.open()
    end
    dap.listeners.before.event_terminated.dapui_config = function()
      ui.close()
    end
    dap.listeners.before.event_exited.dapui_config = function()
      ui.close()
    end
  end,
}
