-- Store the last search results for navigation
local last_search_results = {}
local current_result_index = 0

local M = {}

function M.search_symbol()
  -- Get references using LSP
  vim.lsp.buf.references(nil, {
    on_list = function(options)
      if not options.items or #options.items == 0 then
        print 'No references found'
        return
      end

      -- Convert LSP results to Telescope format
      local pickers = require 'telescope.pickers'
      local finders = require 'telescope.finders'
      local conf = require('telescope.config').values
      local make_entry = require 'telescope.make_entry'

      pickers
        .new({}, {
          prompt_title = 'LSP References',
          finder = finders.new_table {
            results = options.items,
            entry_maker = make_entry.gen_from_quickfix {},
          },
          previewer = conf.qflist_previewer {},
          sorter = conf.generic_sorter {},
        })
        :find()
    end,
  })
end

return M
