vim.opt.sessionoptions:append 'globals'

vim.opt.nu = true
vim.opt.relativenumber = true


vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.smartindent = true

vim.opt.wrap = false

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.termguicolors = true

vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

vim.opt.updatetime = 50

vim.opt.colorcolumn = "80"

vim.api.nvim_create_user_command(
    'Mksession',
    function(attr)
        vim.api.nvim_exec_autocmds('User', { pattern = 'SessionSavePre' })

        -- Neovim 0.8+
        vim.cmd.mksession { bang = attr.bang, args = attr.fargs }

        -- Neovim 0.7
        vim.api.nvim_command('mksession ' .. (attr.bang and '!' or '') .. attr.args)
    end,
    { bang = true, complete = 'file', desc = 'Save barbar with :mksession', nargs = '?' }
)

-- vim.cmd([[autocmd BufEnter * silent! lcd %:p:h]])
