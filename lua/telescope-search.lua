-- Store the last search results for navigation
local last_search_results = {}
local current_result_index = 0

local M = {}

function M.search_symbol()
  local builtin = require 'telescope.builtin'
  local word = vim.fn.expand '<cword>'

  -- Search only in current buffer
  builtin.current_buffer_fuzzy_find {
    default_text = word,
    attach_mappings = function(prompt_bufnr, map)
      local actions = require 'telescope.actions'
      local action_state = require 'telescope.actions.state'

      -- Override select action to store results
      actions.select_default:replace(function()
        local current_picker = action_state.get_current_picker(prompt_bufnr)

        -- Store all entries for navigation
        last_search_results = {}
        local current_buf = vim.api.nvim_get_current_buf()

        for entry in current_picker.manager:iter() do
          table.insert(last_search_results, {
            bufnr = current_buf,
            lnum = entry.lnum,
            col = entry.col or 1,
          })
        end

        -- Find which result was selected
        local selection = action_state.get_selected_entry()
        for i, result in ipairs(last_search_results) do
          if result.lnum == selection.lnum then
            current_result_index = i
            break
          end
        end

        actions.close(prompt_bufnr)
        local col = (selection.col or 1) - 1
        vim.api.nvim_win_set_cursor(0, { selection.lnum, col })
      end)

      return true
    end,
  }
end

function M.next_result()
  if #last_search_results == 0 then
    print 'No search results available'
    return
  end

  current_result_index = current_result_index + 1
  if current_result_index > #last_search_results then
    current_result_index = 1
  end

  local result = last_search_results[current_result_index]
  vim.api.nvim_set_current_buf(result.bufnr)
  local col = (result.col or 1) - 1
  vim.api.nvim_win_set_cursor(0, { result.lnum, col })
  print(string.format('Result %d/%d', current_result_index, #last_search_results))
end

function M.prev_result()
  if #last_search_results == 0 then
    print 'No search results available'
    return
  end

  current_result_index = current_result_index - 1
  if current_result_index < 1 then
    current_result_index = #last_search_results
  end

  local result = last_search_results[current_result_index]
  vim.api.nvim_set_current_buf(result.bufnr)
  local col = (result.col or 1) - 1
  vim.api.nvim_win_set_cursor(0, { result.lnum, col })
  print(string.format('Result %d/%d', current_result_index, #last_search_results))
end

return M
