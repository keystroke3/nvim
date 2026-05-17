return { -- Fuzzy Finder (files, lsp, etc)
  'nvim-telescope/telescope.nvim',
  event = 'VimEnter',
  branch = '0.1.x',
  dependencies = {
    'nvim-lua/plenary.nvim',
    { -- If encountering errors, see telescope-fzf-native README for installation instructions
      'nvim-telescope/telescope-fzf-native.nvim',

      build = 'make',

      cond = function()
        return vim.fn.executable 'make' == 1
      end,
    },
    { 'nvim-telescope/telescope-ui-select.nvim' },

    { 'nvim-tree/nvim-web-devicons',            enabled = true },
  },
  config = function()
    local telescopeConfig = require 'telescope.config'

    -- Clone the default values
    local vimgrep_arguments = { unpack(telescopeConfig.values.vimgrep_arguments) }

    -- Custom function to shorten file paths
    local function shorten_path(path)
      if not path or path == '' then
        return ''
      end

      local max_width = 60 -- Maximum width for path display

      if #path > max_width then
        local filename = vim.fn.fnamemodify(path, ':t')
        local available = max_width - #filename - 4 -- 4 for ".../"
        if available > 0 then
          local start_pos = #path - max_width + 4
          return '.../' .. path:sub(start_pos)
        else
          return '.../' .. filename
        end
      end

      return path
    end

    require('telescope').setup {
      defaults = {
        vimgrep_arguments = vimgrep_arguments,
        -- Custom preview title that works for all pickers
        dynamic_preview_title = true,
        preview = {
          treesitter = false,
          -- Custom title function - gets called for every preview
          title = function(entry, bufnr)
            -- Try to get filename from various sources
            local filename = entry.filename or entry.path or entry.value

            -- If we have a buffer, get its name
            if not filename and bufnr then
              filename = vim.api.nvim_buf_get_name(bufnr)
            end

            -- Fallback to default if no filename available
            if not filename or filename == '' then
              return 'Preview'
            end

            -- Shorten the path
            return shorten_path(filename)
          end,
        },
        path_display = function(opts, path)
          return shorten_path(path)
        end,
      },
      pickers = {
        colorscheme = {
          enable_preview = true,
        },
      },
      extensions = {
        ['ui-select'] = {
          require('telescope.themes').get_dropdown(),
        },
      },
    }

    pcall(require('telescope').load_extension, 'fzf')
    pcall(require('telescope').load_extension, 'ui-select')
    local treesitter_search = require 'treesitter-search'

    local builtin = require 'telescope.builtin'
    vim.keymap.set('n', '<leader>ss', function()
      builtin.spell_suggest {
        layout_config = {
          height = 0.25,
          width = 0.25,
        },
      }
    end, { desc = '[S]pell [S]uggest' })
    vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
    vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
    vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
    vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
    vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
    vim.keymap.set('n', '<leader>ps', builtin.live_grep, { desc = '[S]earch by [G]rep' })
    vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
    vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
    vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
    vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })
    vim.keymap.set('n', '<leader>pw', treesitter_search.search_symbol, { desc = '[P]roject [S]earch current symbol' })

    vim.keymap.set('n', '<leader>pf', function()
      builtin.find_files {
        attach_mappings = function(prompt_bufnr, _)
          local actions = require 'telescope.actions'
          local action_state = require 'telescope.actions.state'

          actions.select_default:replace(function()
            local selection = action_state.get_selected_entry()
            actions.close(prompt_bufnr)

            if selection then
              vim.cmd('edit ' .. selection.path)
              vim.defer_fn(function()
                vim.cmd 'NvimTreeFindFile'
                vim.cmd 'wincmd p'
              end, 50)
            end
          end)

          return true
        end,
      }
    end, { desc = '[S]earch [F]iles' })
    vim.keymap.set('n', '<leader>/', function()
      builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
        winblend = 10,
        previewer = false,
      })
    end, { desc = '[/] Fuzzily search in current buffer' })

    vim.keymap.set('n', '<leader>s/', function()
      builtin.live_grep {
        grep_open_files = true,
        prompt_title = 'Live Grep in Open Files',
      }
    end, { desc = '[S]earch [/] in Open Files' })

    vim.keymap.set('n', '<leader>sn', function()
      builtin.find_files { cwd = vim.fn.stdpath 'config' }
    end, { desc = '[S]earch [N]eovim files' })
  end,
}
