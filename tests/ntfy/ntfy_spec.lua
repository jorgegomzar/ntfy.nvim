local ntfy = require("ntfy")

local default_config = {
  host = "ntfy.sh",
  topic = "nvim",
  port = 443,
  username = nil,
  password = nil,
}
local custom_config = {
  host = "ntfy.self_hosted.com",
  topic = "topic",
  port = 80,
  username = "username",
  password = "password",
}

describe("setup", function()
  it("default configuration", function()
    assert(ntfy.setup() == default_config, "Default configuration is correct")
  end)

  it("custom configuration", function()
    ntfy.setup(custom_config)
    assert(ntfy.config == custom_config, "Custom configuration is correctly loaded")
  end)
end)
