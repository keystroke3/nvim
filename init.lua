vim.opt.encoding = 'utf-8'
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.g.have_nerd_font = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = 'a'
vim.opt.showmode = false
vim.opt.spell = true
vim.opt.spelllang = 'en_us'
vim.opt.spelloptions = 'camel'
vim.opt.breakindent = true
vim.opt.undofile = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.signcolumn = 'yes'
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.opt.inccommand = 'split'
vim.opt.cursorline = true
vim.opt.titlestring = [[%f %h%m%r%w %{v:progname} (%{tabpagenr()} of %{tabpagenr('$')})]]
vim.o.foldmethod = 'indent'
vim.o.foldlevel = 50
vim.opt.foldexpr = 'nvim_treesitter#foldexpr()'
vim.o.autoread = true

vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostics' })
vim.keymap.set({ 'n', 'v' }, '<leader>y', [["+y"]])
vim.keymap.set('n', '<leader>Y', [["+Y"]])
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

local opts = { noremap = true, silent = true }
vim.keymap.set('n', '<leader>lr', '<Cmd>LspRestart<CR>', { desc = '[L]sp [R]estart' })
vim.keymap.set('n', '<leader>m', '<Cmd>Markview toggle<CR>')
vim.keymap.set('n', '<leader>1', '<Cmd>BufferGoto 1<CR>', opts)
vim.keymap.set('n', '<leader>2', '<Cmd>BufferGoto 2<CR>', opts)
vim.keymap.set('n', '<leader>3', '<Cmd>BufferGoto 3<CR>', opts)
vim.keymap.set('n', '<leader>4', '<Cmd>BufferGoto 4<CR>', opts)
vim.keymap.set('n', '<leader>5', '<Cmd>BufferGoto 5<CR>', opts)
vim.keymap.set('n', '<leader>6', '<Cmd>BufferGoto 6<CR>', opts)
vim.keymap.set('n', '<leader>7', '<Cmd>BufferGoto 7<CR>', opts)
vim.keymap.set('n', '<leader>8', '<Cmd>BufferGoto 8<CR>', opts)
vim.keymap.set('n', '<leader>9', '<Cmd>BufferGoto 9<CR>', opts)
vim.keymap.set('n', '<leader>0', '<Cmd>BufferLast<CR>', opts)
vim.keymap.set('n', '<leader>w', '<Cmd>BufferClose<CR>', opts)
vim.keymap.set('n', '<leader>n', '<Cmd>NvimTreeToggle<CR>')
vim.keymap.set('n', '<leader>pn', function()
  vim.cmd 'NvimTreeFindFile'
  vim.cmd 'wincmd p'
end, { desc = 'Find in file [N]vimTree' })

local zoomed = false
local zoom_winid = nil

function _G.toggle_zoom()
  if zoomed and zoom_winid == vim.api.nvim_get_current_win() then
    vim.cmd 'wincmd =' -- Equalize all windows
    zoomed = false
  else
    vim.cmd 'wincmd |' -- Maximize width
    vim.cmd 'wincmd _' -- Maximize height
    zoom_winid = vim.api.nvim_get_current_win()
    zoomed = true
    vim.defer_fn(function()
      vim.cmd 'NvimTreeFindFile'
      vim.cmd 'wincmd p'
    end, 50)
  end
end

vim.keymap.set('n', '<leader>v', '<cmd>lua toggle_zoom()<CR>', { desc = 'Toggle zoom' })

local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then
    error('Error cloning lazy.nvim:\n' .. out)
  end
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

-- Auto-highlight current file in NvimTree when switching to a different file
vim.api.nvim_create_autocmd('BufEnter', {
  group = vim.api.nvim_create_augroup('nvimtree-auto-highlight', { clear = true }),
  callback = function()
    local bufname = vim.api.nvim_buf_get_name(0)

    -- Skip if not a real file
    if bufname == '' or vim.fn.filereadable(bufname) ~= 1 then
      return
    end

    -- Skip if this is the NvimTree buffer itself
    if vim.bo.filetype == 'NvimTree' then
      return
    end

    -- Track last highlighted file to avoid redundant updates
    if not vim.g.last_nvimtree_file or vim.g.last_nvimtree_file ~= bufname then
      vim.g.last_nvimtree_file = bufname

      vim.defer_fn(function()
        -- Check if NvimTree window exists
        local nvimtree_open = false
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          local buf = vim.api.nvim_win_get_buf(win)
          if vim.bo[buf].filetype == 'NvimTree' then
            nvimtree_open = true
            break
          end
        end

        if nvimtree_open then
          -- Save current window to return to it
          local current_win = vim.api.nvim_get_current_win()
          vim.cmd 'NvimTreeFindFile'
          -- Return to the window we were in
          vim.api.nvim_set_current_win(current_win)
        end
      end, 50)
    end
  end,
})

vim.api.nvim_create_autocmd({ 'BufEnter', 'FocusGained' }, {
  command = "if mode() != 'c' | checktime | endif",
  pattern = '*',
})

require('lazy').setup('plugins', {
  ui = {
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤 ',
    },
  },
})
