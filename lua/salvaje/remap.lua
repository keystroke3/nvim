vim.g.mapleader = " "
local opts = { noremap = true, silent = true }
local ts_builtin = require('telescope.builtin')

vim.api.nvim_set_keymap('n', '<c-s-c>', '"+y', { noremap = true })
vim.api.nvim_set_keymap('v', '<c-c>', '"+y', { noremap = true })
vim.api.nvim_set_keymap('n', '<c-s-v>', '"+p', { noremap = true })
vim.api.nvim_set_keymap('i', '<c-s-v>', '<c-r>+', { noremap = true })
vim.api.nvim_set_keymap('c', '<c-v>', '<c-r>+', { noremap = true })
-- vim.api.nvim_set_keymap('i', '<c-r>', '<c-v>', { noremap = true })

-- debugging
vim.keymap.set("n", "<F4>", ":lua require'dapui'.toggle()<CR>")
vim.keymap.set("n", "<F5>", ":lua require'dap'.continue()<CR>")
vim.keymap.set("n", "<F10>", ":lua require'dap'.step_over()<CR>")
vim.keymap.set("n", "<F11>", ":lua require'dap'.step_into()<CR>")
vim.keymap.set("n", "<F12>", ":lua require'dap'.step_out()<CR>")
vim.keymap.set("n", "<leader>b", ":lua require'dap'.toggle_breakpoint()<CR>")
vim.keymap.set("n", "<leader>B", ":lua require'dap'.set_breakdpoint(vim.fn.input('Breakpoint condition: '))<CR>")
vim.keymap.set("n", "<leader>lp", ":lua require'dap'.set_breakdpoint(nil, nil, vim.fn.input('Log point message: '))<CR>")
vim.keymap.set('n', '<C-k>', ':wincmd k<CR>', {silent = true})
vim.keymap.set('n', '<C-j>', ':wincmd j<CR>', {silent = true})
vim.keymap.set('n', '<C-h>', ':wincmd h<CR>', {silent = true})
vim.keymap.set('n', '<C-l>', ':wincmd l<CR>', {silent = true})

-- File Opening
function _G.telescope_files_vsplit()
    vim.cmd('vsplit')
    vim.cmd('wincmd l')
    ts_builtin.find_files()
end

vim.api.nvim_set_keymap('n', '<leader>pv', ':lua telescope_files_vsplit()<CR>', opts)

function _G.telescope_files_hsplit()
    vim.cmd('split')
    vim.cmd('wincmd j')
    ts_builtin.find_files()
end

vim.api.nvim_set_keymap('n', '<leader>ph', ':lua telescope_files_hsplit()<CR>', opts)

function _G.telescope_new_tab()
    vim.cmd('tabnew')
    ts_builtin.find_files()
end

-- Tab management

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
vim.keymap.set('n', '<leader>-s-w', '<Cmd>BufferClose<CR>', opts)

-- vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
-- vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- vim.keymap.set("n", "J", "mzJ`z")
-- vim.keymap.set("n", "<C-d>", "<C-d>zz")
-- vim.keymap.set("n", "<C-u>", "<C-u>zz")
-- vim.keymap.set("n", "n", "nzzzv")
-- vim.keymap.set("n", "N", "Nzzzv")

-- greatest remap ever
vim.keymap.set("x", "<leader>p", [["_dP]])

-- next greatest remap ever : asbjornHaland
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])

vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]])

-- This is going to get me cancelled
vim.keymap.set("i", "<C-c>", "<Esc>")

vim.keymap.set("n", "Q", "<nop>")
vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>")
vim.keymap.set("n", "<leader>f", vim.lsp.buf.format)

vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz")
vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz")
vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz")
vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz")

vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })

vim.keymap.set("n", "<leader>vpp", "<cmd>e ~/.dotfiles/nvim/.config/nvim/lua/theprimeagen/packer.lua<CR>");
vim.keymap.set("n", "<C-n>", ":NERDTreeToggle<CR>");
