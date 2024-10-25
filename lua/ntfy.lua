-- main module file
local subscriptor = require("ntfy.subscriptor")

---@class Config
---@field host string NTFY host
---@field topic string NTFY topic to subscribe
---@field port integer NTFY port
---@field username string NTFY username
---@field password string NTFY password
local config = {
  host = "ntfy.sh",
  topic = "/nvim",
  port = 443,
  username = nil,
  password = nil,
}

---@class Ntfy
local M = {}

---@type Config
M.config = config

M.setup = function(args)
  M.config = vim.tbl_deep_extend("force", M.config, args or {})
end

M.subscribe = function()
  return subscriptor.subscribe(M.config)
end

return M
