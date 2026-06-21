local M = {}

local state = {
  active = false,
  tree_was_open = false,
  laststatus = nil,
  zen_opts = nil,
}

local function save_lualine()
  local ok, lualine = pcall(require, 'lualine')
  if ok and lualine.get_config then
    _G._lualine_config = vim.deepcopy(lualine.get_config())
  end
end

local function restore_lualine()
  if _G._lualine_config then
    local ok, lualine = pcall(require, 'lualine')
    if ok and lualine.setup then
      lualine.setup(_G._lualine_config)
    end
  end
end

local function close_nvim_tree()
  local ok, tree_view = pcall(require, 'nvim-tree.view')
  if ok then
    state.tree_was_open = tree_view.is_visible()
    vim.cmd 'NvimTreeClose'
  end
end

local function open_nvim_tree()
  if state.tree_was_open then
    pcall(vim.cmd, 'NvimTreeOpen')
  end
end

local function make_zen_opts()
  return {
    window = {
      width = 120,
      height = 1,
      options = {
        number = false,
        signcolumn = 'no',
        foldcolumn = '0',
      },
    },
    on_open = function()
      close_nvim_tree()
      state.laststatus = vim.o.laststatus
      vim.o.laststatus = 0
      save_lualine()
      require('lualine').setup {
        options = { component_separators = '', section_separators = '' },
        sections = {
          lualine_a = { 'mode' },
          lualine_b = {},
          lualine_c = { { 'filename', path = 1 }, 'modified' },
          lualine_x = {},
          lualine_y = {},
          lualine_z = {},
        },
        inactive_sections = {
          lualine_a = {}, lualine_b = {}, lualine_c = {},
          lualine_x = {}, lualine_y = {}, lualine_z = {},
        },
        tabline = {},
      }
    end,
    on_close = function()
      vim.o.laststatus = state.laststatus
      open_nvim_tree()
      restore_lualine()
    end,
  }
end

function M.toggle()
  if state.active then
    vim.cmd 'close'
    state.active = false
    return
  end
  state.zen_opts = make_zen_opts()
  require('zen-mode').toggle(state.zen_opts)
  state.active = true
end

function M.open_file(path)
  if state.active then
    vim.cmd 'close'
  end
  state.active = false
  vim.cmd('edit ' .. vim.fn.expand(path))
  state.zen_opts = make_zen_opts()
  require('zen-mode').toggle(state.zen_opts)
  state.active = true
end

function M.setup()
  vim.keymap.set('n', '<leader>z', M.toggle, { desc = 'Toggle memo zen' })

  -- Alt+z in terminal mode: escape terminal insert then open memo
  vim.keymap.set('t', '<M-z>', function()
    vim.api.nvim_feedkeys(
      vim.api.nvim_replace_termcodes('<C-\\><C-n>', true, false, true), 'n', false
    )
    vim.schedule(M.toggle)
  end, { desc = 'Open memo from terminal' })
end

return M
