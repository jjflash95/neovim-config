local pickers = require 'telescope.pickers'
local finders = require 'telescope.finders'
local make_entry = require 'telescope.make_entry'
local conf = require('telescope.config').values

local M = {}

local live_multigrep = function(opts)
  opts = opts or {}
  opts.cwd = vim.uv.cwd()

  local finder = finders.new_async_job {
    command_generator = function(prompt)
      if not prompt or prompt == '' then return nil end

      local pieces = vim.split(prompt, '  ')
      local args = { 'rg' }
      if pieces[1] then
        table.insert(args, '-e')
        table.insert(args, pieces[1])
      end

      for i = 2, #pieces do
        local entry = pieces[i]
        table.insert(args, '-g')
        table.insert(args, entry)
      end

      vim.print(args)

      ---@diagnostic disable-next-line: deprecated
      return vim.tbl_flatten {
        args,
        {
          '--color=never',
          '--no-heading',
          '--with-filename',
          '--line-number',
          '--column',
          '--smart-case',
        },
      }
    end,
    entry_maker = make_entry.gen_from_vimgrep(opts),
    cwd = opts.cwd,
  }

  pickers
    .new(
      opts,
      {
        prompt_title = 'Search (some_str  *.include  !*.exclude) double space',
        finder = finder,
        debounce = 100,
        previewer = conf.grep_previewer(opts),
        sorter = require('telescope.sorters').empty(),
      }
    )
    :find()
end

M.setup = function() vim.keymap.set('n', '<leader>pg', live_multigrep) end

return M
