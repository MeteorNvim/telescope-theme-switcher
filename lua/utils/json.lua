--- Module for reading and modifying JSON configuration in Neovim.
local M = {}

--- Neovim configuration path
local config_path = vim.fn.stdpath('config')
--- Json file path
local path = string.format("%s/settings.json", config_path)

--- Get the value associated with a specified object in the JSON configuration.
---
--- @param object string: The object key to retrieve.
--- @return string: The value associated with the specified object.
function M.getValue(object)
    local handle = io.popen(string.format("jq -r '.%s' %s", object, path))
    if handle then
        local result = handle:read('*a')
        handle:close()
        return result
    else
        return "error"
    end
end

--- Set the value of a specified object in the JSON configuration.
---
--- @param object string: The object key to set.
--- @param value string: The value to assign to the object key.
function M.setValue(object, value)
    local temp_file = os.tmpname()
    local tmp_file = io.open(temp_file, 'w')

    if tmp_file then
        local jq_command = string.format('jq \'.%s = "%s"\' %s > %s', object, value, path, temp_file)
        os.execute(jq_command)

        os.execute(string.format("mv %s %s", temp_file, path))
    end
end


return M
