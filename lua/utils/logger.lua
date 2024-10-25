local M = {}

M.info = function(msg)
  vim.notify("NTFY - " .. msg, vim.log.levels.INFO, { title = "NTFY" })
end

M.error = function(msg)
  vim.notify("NTFY - " .. msg, vim.log.levels.ERROR, { title = "NTFY" })
end

return M

