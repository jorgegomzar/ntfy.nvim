local str_utils = require("ntfy.utils.strings")

describe("is_empty", function()
  it("empty string", function()
    assert(str_utils.is_empty("") == true)
  end)
  it("nil value", function()
    assert(str_utils.is_empty(nil) == true)
  end)
  it("not empty string", function()
    assert(str_utils.is_empty("not empty") == false)
  end)

end)
