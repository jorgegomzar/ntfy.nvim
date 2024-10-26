local b64 = require("ntfy.utils.b64")

describe("b64", function()
  it("encode", function()
    assert(b64.enc("hello world") == "aGVsbG8gd29ybGQ=")
  end)

  it("decode", function()
    assert(b64.dec("aGVsbG8gd29ybGQ=") == "hello world")
  end)
end)
