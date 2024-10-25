local b64 = require("ntfy.utils.b64")

describe("base64", function()
  it("encode", function()
    assert(b64.enc("hello world") == "aGVsbG8gd29ybGQ=", "base64 not encoding")
  end)

  it("decode", function()
    assert(b64.enc("aGVsbG8gd29ybGQ=") == "hello world", "base64 not decoding")
  end)
end)
