---@class NtfySubscriptor
local M = {}

local b64 = require("..utils.b64")
local logger = require("..utils.logger")
local isempty = function(s) return s == nil or s == '' end

-- Returns a table from a CSV string
local parse_csv_string = function(s)
  local sep = ","
  local parsed_values = {}
  for value in string.gmatch(s, "([^"..sep.."]+)") do
    table.insert(parsed_values, value)
  end
  return parsed_values
end

-- Handles SSE events
local handle_sse = function(event)
    local decoded_data, pos, err = vim.json.decode(event)

    if decoded_data.event == "keepalive" then
      -- ignore keepalive
      return 0
    end

    if err then
      logger.error("Could not parse JSON: " .. event)
      return -1
    end

    local parsed_event = ""

    if decoded_data.event == "open" then
      local topics = parse_csv_string(decoded_data.topic)
      for _, topic in ipairs(topics) do
        parsed_event = parsed_event .. "\n󱘖  - Subscribed to topic " .. topic
      end

    elseif decoded_data.event == "message" then
      parsed_event = parsed_event .. "󰍨  - [" .. decoded_data.topic .. "] - "

      local msg = ""
      if not isempty(decoded_data.title)  then
        msg = msg .. decoded_data.title
      end

      if not isempty(decoded_data.message)  then
        msg = msg .. decoded_data.message
      else
        msg = msg .. "(empty message)"
      end

      parsed_event = parsed_event .. msg
    end

    if not isempty(parsed_event) then
      logger.info(parsed_event)
    end
end

M.subscribe = function(config)
  vim.loop.getaddrinfo(config.host, nil, {}, function(err, res)
    if err then
      logger.error("DNS resolution failed: " .. err)
      return
    end

    local topics = ""

    for _, topic in ipairs(config.topics) do
      topics = topics .. "," .. topic
    end
    --
    -- trim first comma
    topics = topics:sub(2)

    if isempty(config.topics) then
      logger.warn("No topic configured, please check your configuration")
      return
    end

    local host_ip = res[1].addr
    local client = assert(vim.loop.new_tcp())

    if not client then
      logger.error("Connection failed: " .. err)
      return
    end

    client:connect(host_ip, config.port, function(err)
      if err then
          logger.error("Connection failed: " .. err)
          client:close()
          return
      end

      -- right now we only support 1 topic
      local request = "GET /" .. topics .. "/sse HTTP/1.1\r\n" ..
                      "Host: " .. config.host .. "\r\n" ..
                      "Accept: text/event-stream\r\n"
      -- Basic auth support
      if not isempty(config.username) and not isempty(config.password) then
        request = request .. "Authorization: " .. "Basic " .. b64.enc(config.username .. ":" .. config.password) .. "\r\n"
      end
      request = request .. "Connection: keep-alive\r\n\r\n"

      client:write(request)

      local buffer = ""
      client:read_start(function(err, chunk)
        if err then
            logger.error("Read error: " .. err)
            client:close()
            return
        end

        if chunk then
            buffer = buffer .. chunk
            for line in buffer:gmatch("[^\r\n]+") do
                if line:find("data:") then
                    -- Remove "data: " prefix
                    local event_data = line:sub(6)
                    handle_sse(event_data)
                end
            end
            buffer = ""
        else
          logger.info("Connection closed")
          client:close()
        end

      end)
    end)
  end)
end

return M
