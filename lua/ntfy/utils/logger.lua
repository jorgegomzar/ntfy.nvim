local M = {}

M.title = "NTFY"

M.info = function(msg)
  vim.notify(M.title .. msg, vim.log.levels.INFO, { title = M.title})
end

M.warn = function(msg)
  vim.notify(M.title .. msg, vim.log.levels.WARN, { title = M.title})
end

M.error = function(msg)
  vim.notify(M.title .. msg, vim.log.levels.ERROR, { title = M.title})
end

return M

