local logger = require("ntfy.utils.logger")

describe("logger", function()
  it("title", function()
    assert(logger.title == "NTFY")
  end)
end)
