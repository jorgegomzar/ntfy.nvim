-- main module file
local subscriptor = require("ntfy.subscriptor")

---@class Config
---@field subscribe_on_init bool Whether to automatically subcribe to topics on plugin load
---@field host string NTFY host
---@field topics table NTFY topics to subscribe
---@field port integer NTFY port
---@field username string NTFY username
---@field password string NTFY password
local config = {
  subscribe_on_init = true,
  host = "ntfy.sh",
  topics = {"nvim"},
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
  if M.config.subscribe_on_init then
    M.subscribe()
  end
end

M.subscribe = function()
  return subscriptor.subscribe(M.config)
end

return M
