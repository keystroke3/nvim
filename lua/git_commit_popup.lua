local M = {}

local popup_win = nil
local popup_buf = nil
local prev_win = nil

local function get_git_root()
  local root = vim.fn.systemlist('git rev-parse --show-toplevel')[1]
  if vim.v.shell_error ~= 0 or not root or root == '' then
    return nil
  end
  return root
end

local function get_commit_file(git_root)
  return (git_root or vim.fn.getcwd()) .. '/git_commit.md'
end

-- Stored in .git so it's per-repo and ignored automatically
local function get_head_state_file(git_root)
  return git_root .. '/.git/git_commit_popup_head'
end

local function read_file(path)
  local f = io.open(path, 'r')
  if not f then return nil end
  local content = f:read('*l')
  f:close()
  return content
end

local function write_file(path, content)
  local f = io.open(path, 'w')
  if not f then return end
  f:write(content)
  f:close()
end

local function get_current_head(git_root)
  local head = vim.fn.systemlist('git -C ' .. vim.fn.shellescape(git_root) .. ' rev-parse HEAD 2>/dev/null')[1]
  if vim.v.shell_error ~= 0 or not head or head == '' then return nil end
  return head
end

-- If HEAD has changed since the popup last ran, wipe git_commit.md
local function clear_if_committed(commit_file, git_root)
  local current_head = get_current_head(git_root)
  if not current_head then return end

  local state_file = get_head_state_file(git_root)
  local stored_head = read_file(state_file)

  if stored_head == nil then
    -- First time: just record HEAD, don't blank the file
    write_file(state_file, current_head)
  elseif stored_head ~= current_head then
    -- A commit (or rebase, etc.) happened — clear the notes file
    local f = io.open(commit_file, 'w')
    if f then f:close() end
    write_file(state_file, current_head)
  end
end

local function close_popup()
  local win = popup_win
  local buf = popup_buf
  popup_win = nil -- nil early so WinClosed handler is a no-op
  popup_buf = nil

  if buf and vim.api.nvim_buf_is_valid(buf) then
    local path = vim.api.nvim_buf_get_name(buf)
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    vim.fn.writefile(lines, path)
  end
  if win and vim.api.nvim_win_is_valid(win) then
    vim.api.nvim_win_close(win, true)
  end
  if buf and vim.api.nvim_buf_is_valid(buf) then
    vim.api.nvim_buf_delete(buf, { force = true })
  end
  local pw = prev_win
  prev_win = nil
  if pw and vim.api.nvim_win_is_valid(pw) then
    vim.api.nvim_set_current_win(pw)
  end
end

function M.open()
  -- If already open, close it (toggle)
  if popup_win and vim.api.nvim_win_is_valid(popup_win) then
    close_popup()
    return
  end

  local git_root = get_git_root()
  local commit_file = get_commit_file(git_root)

  if git_root then
    clear_if_committed(commit_file, git_root)
  end

  prev_win = vim.api.nvim_get_current_win()

  -- Create a fresh buffer and load file content explicitly
  local bufnr = vim.api.nvim_create_buf(false, false)
  vim.bo[bufnr].swapfile = false
  vim.bo[bufnr].filetype = 'markdown'
  vim.bo[bufnr].buftype = ''
  vim.api.nvim_buf_set_name(bufnr, commit_file)

  local ok, lines = pcall(vim.fn.readfile, commit_file)
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, ok and lines or {})
  vim.bo[bufnr].modified = false

  local width = math.floor(vim.o.columns * 0.7)
  local height = math.floor(vim.o.lines * 0.6)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  popup_win = vim.api.nvim_open_win(bufnr, true, {
    relative = 'editor',
    width = width,
    height = height,
    row = row,
    col = col,
    style = 'minimal',
    border = 'rounded',
    title = ' git_commit.md ',
    title_pos = 'center',
  })
  popup_buf = bufnr

  vim.wo[popup_win].wrap = true
  vim.wo[popup_win].linebreak = true
  vim.wo[popup_win].cursorline = true

  vim.keymap.set('n', '<C-q>', close_popup, { buffer = bufnr, nowait = true, desc = 'Close git commit popup' })
  vim.keymap.set('i', '<C-q>', close_popup, { buffer = bufnr, nowait = true, desc = 'Close git commit popup' })

  -- Save and wipe if closed by any other means
  vim.api.nvim_create_autocmd('WinClosed', {
    pattern = tostring(popup_win),
    once = true,
    callback = function()
      local buf = popup_buf
      local pw = prev_win
      popup_win = nil
      popup_buf = nil
      prev_win = nil
      if buf and vim.api.nvim_buf_is_valid(buf) then
        local path = vim.api.nvim_buf_get_name(buf)
        local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
        vim.fn.writefile(lines, path)
        vim.api.nvim_buf_delete(buf, { force = true })
      end
      if pw and vim.api.nvim_win_is_valid(pw) then
        vim.api.nvim_set_current_win(pw)
      end
    end,
  })

  vim.cmd 'normal! G$'
  vim.cmd 'startinsert!'
end

return M
