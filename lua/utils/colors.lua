local M = {}

function M.get_installed_colorschemes(opts)
  local before_background = vim.o.background
  local before_color = vim.api.nvim_exec("colorscheme", true)
  local need_restore = true

  local colors = opts.colors or { before_color }
  if not vim.tbl_contains(colors, before_color) then
    table.insert(colors, 1, before_color)
  end

  colors = vim.list_extend(
    colors,
    vim.tbl_filter(function(color)
      return color ~= before_color
    end, vim.fn.getcompletion("", "color"))
  )

  return colors

end

return M
