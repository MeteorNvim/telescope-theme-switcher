local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"
local colors = require("core.utils.colors")
local json = require("core.utils.json")

local function set_theme(theme)
    vim.cmd(string.format("colorscheme %s", theme))
end

local theme_swither = function(opts)
    opts = opts or {}
    pickers.new(opts, {
        prompt_title = "Theme Switcher",
        finder = finders.new_table {
            results = colors.get_installed_colorschemes(),
        },
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

            -- Apply theme
            actions.select_default:replace(function()
                actions.close(prompt_bufnr)
                local selection = action_state.get_selected_entry()
                set_theme(selection.value)
                json.setValue("theme", selection.value)
            end)
            return true
        end,
        sorter = conf.generic_sorter(opts),
    }):find()
end

return require("telescope").register_extension {
    exports = { theme_switcher = theme_swither },
}