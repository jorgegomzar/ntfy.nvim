local subscriber = require("ntfy.subscriber")

describe("parse_event", function()
  it("event keepalive", function()
    assert(subscriber.parse_event('{"event": "keepalive"}') == "")
  end)

  it("event open with 1 topic", function()
    assert(
      subscriber.parse_event('{"event": "open", "topic": "test_1"}') == "\n󱘖  - Subscribed to topic test_1"
    )
  end)

  it("event open with +1 topic", function()
    assert(
      subscriber.parse_event('{"event": "open", "topic": "test_1,test_2"}') == (
        "\n󱘖  - Subscribed to topic test_1" ..
        "\n󱘖  - Subscribed to topic test_2"
      )
    )
  end)

  it("event message", function()
    assert(
      subscriber.parse_event(
        '{"event": "message", "topic": "test_1", "message": "test message"}'
      ) == "󰍨  - [test_1] - test message"
    )
  end)

  it("unknown event", function()
    assert(subscriber.parse_event('{"event": "whatever"}') == "")
  end)

end)
