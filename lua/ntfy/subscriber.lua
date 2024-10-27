---@class NtfySubscriptor
local M = {}

local b64 = require("ntfy.utils.b64")
local logger = require("ntfy.utils.logger")
local str_utils = require("ntfy.utils.strings")

M.parse_event = function(event)
  local decoded_data, pos, err = vim.json.decode(event)
  local parsed_event = ""

  if decoded_data.event == "keepalive" then
    return parsed_event
  end

  if err then
    logger.error("Could not parse JSON: " .. event)
    return parsed_event
  end

  if decoded_data.event == "open" then
    for _, topic in ipairs(str_utils.csv_to_table(decoded_data.topic)) do
      parsed_event = parsed_event .. "󱘖  - Subscribed to topic " .. topic .. "\n"
    end
    return parsed_event
  end

  if decoded_data.event == "message" then
    parsed_event = parsed_event .. "󰍨  - [" .. decoded_data.topic .. "] - "

    local msg = ""
    if not str_utils.is_empty(decoded_data.title)  then
      msg = msg .. decoded_data.title
    end

    if not str_utils.is_empty(decoded_data.message)  then
      msg = msg .. decoded_data.message
    else
      msg = msg .. "(empty message)"
    end

    parsed_event = parsed_event .. msg
    return parsed_event
  end

  logger.warn(
    "Unknown event. Please open an issue in https://github.com/jorgegomzar/ntfy.nvim/issues\n" ..
    "---\n" ..
    "Event: " .. decoded_data.event .. "\n" ..
    "Original msg: " .. event
  )
  return parsed_event
end

-- Handles SSE events
M.handle_sse = function(event)
  local parsed_event = M.parse_event(event)
  if not str_utils.is_empty(parsed_event) then
    logger.info(parsed_event)
  end
end

M.subscribe = function(config)
  vim.loop.getaddrinfo(config.host, nil, {}, function(err, res)
    if err then
      logger.error("DNS resolution failed: " .. err)
      return
    end

    local topics = str_utils.table_to_csv(config.topics)

    if str_utils.is_empty(topics) then
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
      if not str_utils.is_empty(config.username) and not str_utils.is_empty(config.password) then
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
                    M.handle_sse(event_data)
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
