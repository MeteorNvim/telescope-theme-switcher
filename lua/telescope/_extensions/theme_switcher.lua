local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"
local previewers = require "telescope.previewers"
local json = require("core.utils.json")

-- Import required modules and libraries.

local function set_theme(theme)
  vim.cmd(string.format("colorscheme %s", theme))
end

-- Define a function to set the Vim colorscheme using the given theme.

local theme_switcher = function(opts)
  local before_background = vim.o.background
  local before_color = vim.api.nvim_exec("colorscheme", true)
  local need_restore = true

  -- Capture the current background setting and the current Vim colorscheme.

  local colors = opts.colors or { before_color }
  if not vim.tbl_contains(colors, before_color) then
    table.insert(colors, 1, before_color)
  end

  -- Ensure that the current colorscheme is in the list of available colorschemes.

  colors = vim.list_extend(
    colors,
    vim.tbl_filter(function(color)
      return color ~= before_color
    end, vim.fn.getcompletion("", "color"))
  )

  -- Get a list of available colorschemes, excluding the current one.

  local bufnr = vim.api.nvim_get_current_buf()

  -- Get the current buffer number.

  local previewer = previewers.new_buffer_previewer {
    define_preview = function(self, entry)
      local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
      vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)

      local ft = (vim.filetype.match { buf = bufnr } or "diff"):match "%w+"
      require("telescope.previewers.utils").highlighter(self.state.bufnr, ft)

      set_theme(entry.value)
    end,
  }

  -- Define a custom previewer to display the selected colorscheme in the buffer.

  local picker = pickers.new(opts, {
    prompt_title = "Set theme",
    finder = finders.new_table {
      results = colors,
    },
    sorter = conf.generic_sorter(opts),
    previewer = previewer,
    attach_mappings = function(prompt_bufnr, map)
      -- Preview theme on theme searched
      vim.schedule(function()
        vim.api.nvim_create_autocmd("TextChangedI", {
          buffer = prompt_bufnr,
          callback = function()
            if action_state.get_selected_entry() then
              set_theme(action_state.get_selected_entry().value)
            end
          end,
        })
      end)

      -- Set up an autocmd to update the colorscheme when the user types in the search.

      -- Preview theme on key pressed
      map("i", "<C-n>", function()
        actions.move_selection_next(prompt_bufnr)
        set_theme(action_state.get_selected_entry().value)
      end)

      map("i", "<Down>", function()
        actions.move_selection_next(prompt_bufnr)
        set_theme(action_state.get_selected_entry().value)
      end)

      map("i", "<C-p>", function()
        actions.move_selection_previous(prompt_bufnr)
        set_theme(action_state.get_selected_entry().value)
      end)

      map("i", "<Up>", function()
        actions.move_selection_previous(prompt_bufnr)
        set_theme(action_state.get_selected_entry().value)
      end)

      map("n", "<Esc>", function()
        actions.close()
        vim.o.background = before_background
        set_theme(before_color)
      end)

      -- Apply theme
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        set_theme(selection.value)
        json.setValue("theme", selection.value)
      end)

      -- Customize key mappings for selection and theme application.

      return true
    end,
  })

  if opts.enable_preview then
    local close_windows = picker.close_windows
    picker.close_windows = function(status)
      close_windows(status)
      if need_restore then
        vim.o.background = before_background
        vim.cmd("colorscheme " .. before_color)
      end
    end
  end

  picker:find()
end

-- Define a function to create a picker for selecting and applying colorschemes.

return require("telescope").register_extension {
  exports = { theme_switcher = theme_switcher },
}

-- Register the "theme_switcher" extension with Telescope.nvim.
