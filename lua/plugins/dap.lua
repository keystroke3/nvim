return {
  'mfussenegger/nvim-dap',
  dependencies = {
    'leoluz/nvim-dap-go',
    'rcarriga/nvim-dap-ui',
    'theHamsta/nvim-dap-virtual-text',
    'nvim-neotest/nvim-nio',
    'williamboman/mason.nvim',
    'jay-babu/mason-nvim-dap.nvim',
  },
  config = function()
    local dap = require 'dap'
    local ui = require 'dapui'

    dap.set_log_level 'DEBUG'

    -- Walk up from the current file to find the go.mod root (= module/main package dir)
    local function find_main_package()
      local dir = vim.fn.expand '%:p:h'
      while dir ~= '/' do
        if vim.fn.filereadable(dir .. '/go.mod') == 1 then
          return dir
        end
        dir = vim.fn.fnamemodify(dir, ':h')
      end
      return vim.fn.expand '%:p:h'
    end

    local history_file = vim.fn.stdpath 'data' .. '/dap_launch_history.json'
    local args_history_file = vim.fn.stdpath 'data' .. '/dap_args_history.json'

    local function load_args_history(key)
      local ok, data = pcall(vim.fn.readfile, args_history_file)
      if ok and #data > 0 then
        local ok2, decoded = pcall(vim.fn.json_decode, table.concat(data, ''))
        if ok2 and type(decoded) == 'table' then return decoded[key] or {} end
      end
      return {}
    end

    local function save_args_history(key, args_str)
      local ok, data = pcall(vim.fn.readfile, args_history_file)
      local all = {}
      if ok and #data > 0 then
        local ok2, decoded = pcall(vim.fn.json_decode, table.concat(data, ''))
        if ok2 and type(decoded) == 'table' then all = decoded end
      end
      all[key] = all[key] or {}
      for i, v in ipairs(all[key]) do
        if v == args_str then table.remove(all[key], i) break end
      end
      table.insert(all[key], 1, args_str)
      if #all[key] > 10 then all[key][11] = nil end
      vim.fn.writefile({ vim.fn.json_encode(all) }, args_history_file)
    end

    local function get_args_with_history()
      local key = find_main_package()
      local history = load_args_history(key)
      local co = coroutine.running()
      local choices = vim.list_extend({ '+ Enter new args...' }, history)
      vim.ui.select(choices, { prompt = 'Debug args:' }, function(choice)
        if not choice then coroutine.resume(co, {}) return end
        if choice == '+ Enter new args...' then
          vim.ui.input({ prompt = 'Args: ', default = history[1] or '' }, function(input)
            if not input then coroutine.resume(co, {}) return end
            save_args_history(key, input)
            coroutine.resume(co, vim.tbl_map(vim.fn.expand, vim.split(input, ' ', { trimempty = true })))
          end)
        else
          save_args_history(key, choice)
          coroutine.resume(co, vim.tbl_map(vim.fn.expand, vim.split(choice, ' ', { trimempty = true })))
        end
      end)
      return coroutine.yield()
    end

    local function load_history()
      local ok, data = pcall(vim.fn.readfile, history_file)
      if ok and #data > 0 then
        local ok2, decoded = pcall(vim.fn.json_decode, table.concat(data, ''))
        if ok2 and type(decoded) == 'table' then return decoded end
      end
      return {}
    end

    local function save_history(ft, name)
      local h = load_history()
      h[ft] = h[ft] or {}
      for i, n in ipairs(h[ft]) do
        if n == name then
          table.remove(h[ft], i)
          break
        end
      end
      table.insert(h[ft], 1, name)
      if #h[ft] > 10 then h[ft][11] = nil end
      vim.fn.writefile({ vim.fn.json_encode(h) }, history_file)
    end

    local function launch_picker()
      local ft = vim.bo.filetype
      local configs = dap.configurations[ft] or {}
      if #configs == 0 then
        vim.notify('No DAP configs for filetype: ' .. ft, vim.log.levels.WARN)
        return
      end
      local history = (load_history())[ft] or {}
      local order, seen = {}, {}
      for _, name in ipairs(history) do
        for _, c in ipairs(configs) do
          if c.name == name and not seen[name] then
            table.insert(order, c)
            seen[name] = true
          end
        end
      end
      for _, c in ipairs(configs) do
        if not seen[c.name] then table.insert(order, c) end
      end
      vim.ui.select(order, {
        prompt = 'Debug configuration:',
        format_item = function(c)
          return (c.name == (history[1] or '') and '» ' or '  ') .. c.name
        end,
      }, function(c)
        if c then
          save_history(ft, c.name)
          dap.run(c)
        end
      end)
    end

    require('mason-nvim-dap').setup {
      automatic_installation = true,
      handlers = {},
      ensure_installed = { 'delve' },
    }

    ui.setup {
      icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
      layouts = {
        {
          elements = {
            { id = 'scopes', size = 0.4 },
            { id = 'breakpoints', size = 0.2 },
            { id = 'stacks', size = 0.2 },
            { id = 'watches', size = 0.2 },
          },
          size = 40,
          position = 'left',
        },
        {
          elements = {
            { id = 'console', size = 0.6 },
            { id = 'repl', size = 0.4 },
          },
          size = 12,
          position = 'bottom',
        },
      },
      controls = {
        icons = {
          pause = '⏸',
          play = '▶',
          step_into = '⏎',
          step_over = '⏭',
          step_out = '⏮',
          step_back = 'b',
          run_last = '▶▶',
          terminate = '⏹',
          disconnect = '⏏',
        },
      },
    }

    require('dap-go').setup {
      delve = {
        detached = vim.fn.has 'win32' == 0,
      },
    }

    -- Override adapter as a function so dlv spawns with CWD = go.mod root.
    -- This makes `go build .` resolve correctly regardless of nvim's CWD.
    dap.adapters.go = function(callback, _)
      local tcp = vim.uv.new_tcp()
      tcp:bind('127.0.0.1', 0)
      local port = tcp:getsockname().port
      tcp:close()
      callback {
        type = 'server',
        port = port,
        executable = {
          command = vim.fn.exepath 'dlv',
          args = { 'dap', '-l', '127.0.0.1:' .. port },
          cwd = find_main_package(),
          detached = vim.fn.has 'win32' == 0,
        },
      }
    end

    dap.configurations.go = {
      {
        type = 'go',
        name = 'Debug Package',
        request = 'launch',
        program = '.',
      },
      {
        type = 'go',
        name = 'Debug Package (with args)',
        request = 'launch',
        program = '.',
        args = get_args_with_history,
      },
      {
        type = 'go',
        name = 'Debug Package (Build Flags)',
        request = 'launch',
        program = '.',
        buildFlags = require('dap-go').get_build_flags,
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

    vim.keymap.set('n', '<leader>b', dap.toggle_breakpoint, { desc = 'Debug: Toggle breakpoint' })
    vim.keymap.set('n', '<leader>B', function()
      dap.set_breakpoint(vim.fn.input 'Breakpoint condition: ')
    end, { desc = 'Debug: Set conditional breakpoint' })
    vim.keymap.set('n', '<space>?', function()
      ui.eval(nil, { enter = true })
    end, { desc = 'Debug: Evaluate expression' })
    vim.keymap.set('n', '<leader>dt', ui.toggle, { desc = 'Debug: Toggle DAP UI' })
    vim.keymap.set('n', '<leader>do', function() ui.open { layout = 2 } end, { desc = 'Debug: Open output/console' })
    vim.keymap.set('n', '<leader>dc', function()
      if dap.session() then dap.continue() else launch_picker() end
    end, { desc = 'Debug: Continue / Launch' })

    vim.keymap.set('n', '<F1>', function()
      if dap.session() then dap.continue() else launch_picker() end
    end, { desc = 'Debug: Continue / Launch' })
    vim.keymap.set('n', '<F2>', dap.step_into, { desc = 'Debug: Step into' })
    vim.keymap.set('n', '<F3>', dap.step_over, { desc = 'Debug: Step over' })
    vim.keymap.set('n', '<F4>', dap.step_out, { desc = 'Debug: Step out' })
    vim.keymap.set('n', '<F5>', dap.restart, { desc = 'Debug: Restart' })

    dap.listeners.after.event_initialized['dapui_config'] = ui.open
  end,
}
